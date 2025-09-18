using CineVibe.Services.Database;
using CineVibe.Model.Responses;
using CineVibe.Model.Requests;
using CineVibe.Model.SearchObjects;
using CineVibe.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System.Linq;

namespace CineVibe.Services.Services
{
    public class MovieService : BaseCRUDService<MovieResponse, MovieSearchObject, Movie, MovieUpsertRequest, MovieUpsertRequest>, IMovieService
    {
        public MovieService(CineVibeDbContext context, IMapper mapper) : base(context, mapper)
        {
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
    }
}
