using CineVibe.Services.Database;
using CineVibe.Model.Responses;
using CineVibe.Model.Requests;
using CineVibe.Model.SearchObjects;
using CineVibe.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System.Linq;
using EasyNetQ;
using CineVibe.Subscriber.Models;
using Microsoft.ML;
using Microsoft.ML.Data;
using Microsoft.Extensions.DependencyInjection;

namespace CineVibe.Services.Services
{
    public class MovieService : BaseCRUDService<MovieResponse, MovieSearchObject, Movie, MovieUpsertRequest, MovieUpsertRequest>, IMovieService
    {
        private static MLContext _mlContext = null;
        private static object _mlLock = new object();
        private static ITransformer? _model = null;

        public MovieService(CineVibeDbContext context, IMapper mapper) : base(context, mapper)
        {
            if (_mlContext == null)
            {
                lock (_mlLock)
                {
                    if (_mlContext == null)
                    {
                        _mlContext = new MLContext();
                    }
                }
            }
        }


        protected override MovieResponse MapToResponse(Movie entity)
        {
            var actors = entity.MovieActors?.Select(ma => new ActorResponse
            {
                Id = ma.Actor.Id,
                FirstName = ma.Actor.FirstName,
                LastName = ma.Actor.LastName,
                IsActive = ma.Actor.IsActive,
                CreatedAt = ma.Actor.CreatedAt,
                MovieCount = 0 // We don't load this here to avoid circular loading
            }).ToList() ?? new List<ActorResponse>();

            var productionCompanies = entity.MovieProductionCompanies?.Select(mpc => new ProductionCompanyResponse
            {
                Id = mpc.ProductionCompany.Id,
                Name = mpc.ProductionCompany.Name,
                Description = mpc.ProductionCompany.Description,    
                Country = mpc.ProductionCompany.Country,
                IsActive = mpc.ProductionCompany.IsActive,
                CreatedAt = mpc.ProductionCompany.CreatedAt,
                MovieCount = 0 // We don't load this here to avoid circular loading
            }).ToList() ?? new List<ProductionCompanyResponse>();

            return new MovieResponse
            {
                Id = entity.Id,
                Title = entity.Title,
                ReleaseDate = entity.ReleaseDate,
                Description = entity.Description,
                Duration = entity.Duration,
                Trailer = entity.Trailer,
                Poster = entity.Poster,
                IsActive = entity.IsActive,
                CreatedAt = entity.CreatedAt,
                CategoryId = entity.CategoryId,
                CategoryName = entity.Category?.Name ?? string.Empty,
                GenreId = entity.GenreId,
                GenreName = entity.Genre?.Name ?? string.Empty,
                DirectorId = entity.DirectorId,
                DirectorName = entity.Director?.FirstName + " " + entity.Director?.LastName ?? string.Empty,
                Actors = actors,
                ProductionCompanies = productionCompanies,
                ActorCount = entity.MovieActors?.Count ?? 0,
                ProductionCompanyCount = entity.MovieProductionCompanies?.Count ?? 0
            };
        }

        protected override IQueryable<Movie> ApplyFilter(IQueryable<Movie> query, MovieSearchObject search)
        {
            // Include navigation properties for proper mapping
            query = query.Include(m => m.MovieActors).ThenInclude(ma => ma.Actor)
                         .Include(m => m.Category)
                         .Include(m => m.Genre)
                         .Include(m => m.Director)
                         .Include(m => m.MovieProductionCompanies).ThenInclude(mpc => mpc.ProductionCompany);
            
            // Apply search filters
            if (!string.IsNullOrWhiteSpace(search.Title))
            {
                query = query.Where(m => m.Title.ToLower().Contains(search.Title.ToLower()));
            }

            if (search.ReleaseDateFrom.HasValue)
            {
                query = query.Where(m => m.ReleaseDate >= search.ReleaseDateFrom.Value);
            }

            if (search.ReleaseDateTo.HasValue)
            {
                query = query.Where(m => m.ReleaseDate <= search.ReleaseDateTo.Value);
            }

            if (search.MinDuration.HasValue)
            {
                query = query.Where(m => m.Duration >= search.MinDuration.Value);
            }

            if (search.MaxDuration.HasValue)
            {
                query = query.Where(m => m.Duration <= search.MaxDuration.Value);
            }

            if (search.IsActive.HasValue)
            {
                query = query.Where(m => m.IsActive == search.IsActive.Value);
            }

            if (search.ActorId.HasValue)
            {
                query = query.Where(m => m.MovieActors.Any(ma => ma.ActorId == search.ActorId.Value));
            }

            if (search.CategoryId.HasValue)
            {
                query = query.Where(m => m.CategoryId == search.CategoryId.Value);
            }

            if (search.GenreId.HasValue)
            {
                query = query.Where(m => m.GenreId == search.GenreId.Value);
            }

            if (search.DirectorId.HasValue)
            {
                query = query.Where(m => m.DirectorId == search.DirectorId.Value);
            }

            if (search.ProductionCompanyId.HasValue)
            {
                query = query.Where(m => m.MovieProductionCompanies.Any(mpc => mpc.ProductionCompanyId == search.ProductionCompanyId.Value));
            }

            return query;
        }

        public override async Task<MovieResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Set<Movie>()
                .Include(m => m.MovieActors)
                .ThenInclude(ma => ma.Actor)
                .Include(m => m.Category)
                .Include(m => m.Genre)
                .Include(m => m.Director)
                .Include(m => m.MovieProductionCompanies)
                .ThenInclude(mpc => mpc.ProductionCompany)
                .FirstOrDefaultAsync(m => m.Id == id);

            if (entity == null)
                return null;

            return MapToResponse(entity);
        }

        public async Task<List<ActorResponse>> GetMovieActorsAsync(int movieId)
        {
            var actors = await _context.MovieActors
                .Where(ma => ma.MovieId == movieId)
                .Include(ma => ma.Actor)
                .Select(ma => ma.Actor)
                .ToListAsync();

            return actors.Select(a => _mapper.Map<ActorResponse>(a)).ToList();
        }

        public async Task<bool> AssignActorToMovieAsync(int movieId, int actorId)
        {
            // Check if assignment already exists
            var existingAssignment = await _context.MovieActors
                .FirstOrDefaultAsync(ma => ma.MovieId == movieId && ma.ActorId == actorId);

            if (existingAssignment != null)
                return false; // Assignment already exists

            // Verify movie and actor exist
            var movieExists = await _context.Movies.AnyAsync(m => m.Id == movieId);
            var actorExists = await _context.Actors.AnyAsync(a => a.Id == actorId);

            if (!movieExists || !actorExists)
                return false;

            var movieActor = new MovieActor
            {
                MovieId = movieId,
                ActorId = actorId,
                DateAssigned = DateTime.Now
            };

            _context.MovieActors.Add(movieActor);
            await _context.SaveChangesAsync();

            return true;
        }

        public async Task<bool> RemoveActorFromMovieAsync(int movieId, int actorId)
        {
            var assignment = await _context.MovieActors
                .FirstOrDefaultAsync(ma => ma.MovieId == movieId && ma.ActorId == actorId);

            if (assignment == null)
                return false;

            _context.MovieActors.Remove(assignment);
            await _context.SaveChangesAsync();

            return true;
        }

        public async Task<List<ProductionCompanyResponse>> GetMovieProductionCompaniesAsync(int movieId)
        {
            var productionCompanies = await _context.MovieProductionCompanies
                .Where(mpc => mpc.MovieId == movieId)
                .Include(mpc => mpc.ProductionCompany)
                .Select(mpc => mpc.ProductionCompany)
                .ToListAsync();

            return productionCompanies.Select(pc => _mapper.Map<ProductionCompanyResponse>(pc)).ToList();
        }

        public async Task<bool> AssignProductionCompanyToMovieAsync(int movieId, int productionCompanyId)
        {
            // Check if assignment already exists
            var existingAssignment = await _context.MovieProductionCompanies
                .FirstOrDefaultAsync(mpc => mpc.MovieId == movieId && mpc.ProductionCompanyId == productionCompanyId);

            if (existingAssignment != null)
                return false; // Assignment already exists

            // Verify movie and production company exist
            var movieExists = await _context.Movies.AnyAsync(m => m.Id == movieId);
            var productionCompanyExists = await _context.ProductionCompanies.AnyAsync(pc => pc.Id == productionCompanyId);

            if (!movieExists || !productionCompanyExists)
                return false;

            var movieProductionCompany = new MovieProductionCompany
            {
                MovieId = movieId,
                ProductionCompanyId = productionCompanyId,
                DateAssigned = DateTime.Now
            };

            _context.MovieProductionCompanies.Add(movieProductionCompany);
            await _context.SaveChangesAsync();

            return true;
        }

        public async Task<bool> RemoveProductionCompanyFromMovieAsync(int movieId, int productionCompanyId)
        {
            var assignment = await _context.MovieProductionCompanies
                .FirstOrDefaultAsync(mpc => mpc.MovieId == movieId && mpc.ProductionCompanyId == productionCompanyId);

            if (assignment == null)
                return false;

            _context.MovieProductionCompanies.Remove(assignment);
            await _context.SaveChangesAsync();

            return true;
        }

        public override async Task<MovieResponse> CreateAsync(MovieUpsertRequest request)
        {
            // Create the movie first
            var movieResponse = await base.CreateAsync(request);

            try
            {
                // Get all user emails with User role for notification
                var userEmails = await _context.Users
                    .Where(u => u.UserRoles.Any(ur => ur.Role.Name == "User") && u.IsActive)
                    .Select(u => u.Email)
                    .ToListAsync();

                // Get the full movie entity with all relationships for notification
                var movieEntity = await _context.Movies
                    .Include(m => m.Director)
                    .Include(m => m.Genre)
                    .Include(m => m.Category)
                    .FirstOrDefaultAsync(m => m.Id == movieResponse.Id);

                if (movieEntity != null && userEmails.Any())
                {
                    // Setup RabbitMQ connection
                    var host = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "localhost";
                    var username = Environment.GetEnvironmentVariable("RABBITMQ_USERNAME") ?? "guest";
                    var password = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD") ?? "guest";
                    var virtualhost = Environment.GetEnvironmentVariable("RABBITMQ_VIRTUALHOST") ?? "/";
                    
                    using var bus = RabbitHutch.CreateBus($"host={host};virtualHost={virtualhost};username={username};password={password}");

                    // Create RabbitMQ notification DTO
                    var notificationDto = new MovieNotificationDto
                    {
                        Title = movieEntity.Title,
                        Description = movieEntity.Description ?? "An exciting new movie is coming to theaters!",
                        ReleaseDate = movieEntity.ReleaseDate,
                        DirectorName = $"{movieEntity.Director?.FirstName} {movieEntity.Director?.LastName}".Trim(),
                        GenreName = movieEntity.Genre?.Name ?? "---",
                        CategoryName = movieEntity.Category?.Name ?? "---",
                        UserEmails = userEmails
                    };

                    var movieNotification = new MovieNotification
                    {
                        Movie = notificationDto
                    };

                    await bus.PubSub.PublishAsync(movieNotification);
                }
            }
            catch (Exception ex)
            {
                // Log the error but don't fail the movie creation
                // You might want to inject ILogger here for proper logging
                Console.WriteLine($"Failed to send movie notification: {ex.Message}");
            }

            return movieResponse;
        }

        // Train a recommender using Matrix Factorization on (User, Movie) implicit feedback
        public static void TrainRecommenderAtStartup(IServiceProvider serviceProvider)
        {
            lock (_mlLock)
            {
                if (_mlContext == null)
                {
                    _mlContext = new MLContext();
                }
                using var scope = serviceProvider.CreateScope();
                var db = scope.ServiceProvider.GetRequiredService<CineVibeDbContext>();

                // Build implicit feedback dataset combining tickets and positive reviews
                var positiveEntries =
                    db.Tickets.Select(t => new FeedbackEntry
                    {
                        UserId = (uint)t.UserId,
                        MovieId = (uint)t.Screening.MovieId,
                        Label = 1f
                    }).ToList();

                var positiveReviewEntries = db.Reviews
                    .Where(r => r.Rating >= 4)
                    .Select(r => new FeedbackEntry
                    {
                        UserId = (uint)r.UserId,
                        MovieId = (uint)r.Screening.MovieId,
                        Label = 1f
                    }).ToList();

                positiveEntries.AddRange(positiveReviewEntries);

                if (!positiveEntries.Any())
                {
                    _model = null;
                    return;
                }

                var trainData = _mlContext.Data.LoadFromEnumerable(positiveEntries);
                var options = new Microsoft.ML.Trainers.MatrixFactorizationTrainer.Options
                {
                    MatrixColumnIndexColumnName = nameof(FeedbackEntry.UserId),
                    MatrixRowIndexColumnName = nameof(FeedbackEntry.MovieId),
                    LabelColumnName = nameof(FeedbackEntry.Label),
                    LossFunction = Microsoft.ML.Trainers.MatrixFactorizationTrainer.LossFunctionType.SquareLossOneClass,
                    Alpha = 0.01,
                    Lambda = 0.025,
                    NumberOfIterations = 50,
                    C = 0.00001
                };

                var estimator = _mlContext.Recommendation().Trainers.MatrixFactorization(options);
                _model = estimator.Fit(trainData);
            }
        }

        public MovieResponse RecommendForUser(int userId)
        {
            if (_model == null)
            {
                // Fallback: recommend based on user's preferences
                return RecommendHeuristic(userId);
            }

            var predictionEngine = _mlContext.Model.CreatePredictionEngine<FeedbackEntry, MovieScorePrediction>(_model);

            // Get movies the user has already watched (bought tickets for)
            var watchedMovieIds = _context.Tickets
                .Where(t => t.UserId == userId)
                .Select(t => t.Screening.MovieId)
                .Distinct()
                .ToHashSet();

            // Get movies with upcoming/current screenings (so user can actually watch them)
            var moviesWithAvailableScreenings = _context.Screenings
                .Where(s => s.IsActive && s.StartTime >= DateTime.Now)
                .Select(s => s.MovieId)
                .Distinct()
                .ToHashSet();

            // Get candidate movies (active movies user hasn't watched yet and have available screenings)
            var candidateMovies = _context.Movies
                .Include(m => m.MovieActors)
                    .ThenInclude(ma => ma.Actor)
                .Include(m => m.Category)
                .Include(m => m.Genre)
                .Include(m => m.Director)
                .Include(m => m.MovieProductionCompanies)
                    .ThenInclude(mpc => mpc.ProductionCompany)
                .Where(m => m.IsActive 
                    && !watchedMovieIds.Contains(m.Id)
                    && moviesWithAvailableScreenings.Contains(m.Id))
                .ToList();

            if (!candidateMovies.Any())
            {
                return RecommendHeuristic(userId);
            }

            // Score all candidates and pick best
            var scored = candidateMovies
                .Select(m => new
                {
                    Movie = m,
                    Score = predictionEngine.Predict(new FeedbackEntry
                    {
                        UserId = (uint)userId,
                        MovieId = (uint)m.Id
                    }).Score
                })
                .OrderByDescending(x => x.Score)
                .First().Movie;

            return MapToResponse(scored);
        }

        private MovieResponse RecommendHeuristic(int userId)
        {
            // Get movies the user has already watched
            var watchedMovieIds = _context.Tickets
                .Where(t => t.UserId == userId)
                .Select(t => t.Screening.MovieId)
                .Distinct()
                .ToHashSet();

            // Get movies with upcoming/current screenings (so user can actually watch them)
            var moviesWithAvailableScreenings = _context.Screenings
                .Where(s => s.IsActive && s.StartTime >= DateTime.Now)
                .Select(s => s.MovieId)
                .Distinct()
                .ToHashSet();

            // Get user's preferred genres (from highly rated movies)
            var likedGenreIds = _context.Reviews
                .Where(r => r.UserId == userId && r.Rating >= 4)
                .Select(r => r.Screening.Movie.GenreId)
                .ToList();

            // Get user's preferred directors
            var likedDirectorIds = _context.Reviews
                .Where(r => r.UserId == userId && r.Rating >= 4)
                .Select(r => r.Screening.Movie.DirectorId)
                .ToList();

            // Get user's preferred actors (from movies they watched)
            var likedActorIds = _context.Tickets
                .Where(t => t.UserId == userId)
                .SelectMany(t => t.Screening.Movie.MovieActors.Select(ma => ma.ActorId))
                .ToList();

            // Get user's preferred production companies
            var likedProductionCompanyIds = _context.Tickets
                .Where(t => t.UserId == userId)
                .SelectMany(t => t.Screening.Movie.MovieProductionCompanies.Select(mpc => mpc.ProductionCompanyId))
                .ToList();

            var candidate = _context.Movies
                .Include(m => m.MovieActors)
                    .ThenInclude(ma => ma.Actor)
                .Include(m => m.Category)
                .Include(m => m.Genre)
                .Include(m => m.Director)
                .Include(m => m.MovieProductionCompanies)
                    .ThenInclude(mpc => mpc.ProductionCompany)
                .Where(m => m.IsActive 
                    && !watchedMovieIds.Contains(m.Id)
                    && moviesWithAvailableScreenings.Contains(m.Id))
                .OrderByDescending(m => likedGenreIds.Contains(m.GenreId) ? 3 : 0)
                .ThenByDescending(m => likedDirectorIds.Contains(m.DirectorId) ? 2 : 0)
                .ThenByDescending(m => m.MovieActors.Any(ma => likedActorIds.Contains(ma.ActorId)) ? 2 : 0)
                .ThenByDescending(m => m.MovieProductionCompanies.Any(mpc => likedProductionCompanyIds.Contains(mpc.ProductionCompanyId)) ? 1 : 0)
                .ThenByDescending(m => m.ReleaseDate)
                .FirstOrDefault();

            if (candidate == null) 
                throw new InvalidOperationException("No suitable movie found for recommendation.");
            
            return MapToResponse(candidate);
        }

        private class FeedbackEntry
        {
            [KeyType(count: 100000)]
            public uint UserId { get; set; }
            [KeyType(count: 100000)]
            public uint MovieId { get; set; }
            public float Label { get; set; }
        }

        private class MovieScorePrediction
        {
            public float Score { get; set; }
        }
    }
}
