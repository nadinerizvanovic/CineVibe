using CineVibe.Model.Requests;
using CineVibe.Model.Responses;
using CineVibe.Model.SearchObjects;
using CineVibe.Services.Database;
using CineVibe.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace CineVibe.Services.Services
{
    public class ScreeningService : BaseCRUDService<ScreeningResponse, ScreeningSearchObject, Screening, ScreeningUpsertRequest, ScreeningUpsertRequest>, IScreeningService
    {
        public ScreeningService(CineVibeDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override ScreeningResponse MapToResponse(Screening entity)
        {
            return new ScreeningResponse
            {
                Id = entity.Id,
                StartTime = entity.StartTime,
                IsActive = entity.IsActive,
                CreatedAt = entity.CreatedAt,
                MovieId = entity.MovieId,
                MovieTitle = entity.Movie?.Title ?? string.Empty,
                MovieDuration = entity.Movie?.Duration ?? 0,
                HallId = entity.HallId,
                HallName = entity.Hall?.Name ?? string.Empty,
                ScreeningTypeId = entity.ScreeningTypeId,
                ScreeningTypeName = entity.ScreeningType?.Name ?? string.Empty,
                Price = entity.ScreeningType?.Price ?? 0
            };
        }

        protected override IQueryable<Screening> ApplyFilter(IQueryable<Screening> query, ScreeningSearchObject search)
        {
            // Include navigation properties for proper mapping
            query = query.Include(s => s.Movie)
                         .Include(s => s.Hall)
                         .Include(s => s.ScreeningType);

            if (search.MovieId.HasValue)
            {
                query = query.Where(s => s.MovieId == search.MovieId.Value);
            }

            if (search.HallId.HasValue)
            {
                query = query.Where(s => s.HallId == search.HallId.Value);
            }

            if (search.ScreeningTypeId.HasValue)
            {
                query = query.Where(s => s.ScreeningTypeId == search.ScreeningTypeId.Value);
            }

            if (search.StartTimeFrom.HasValue)
            {
                query = query.Where(s => s.StartTime >= search.StartTimeFrom.Value);
            }

            if (search.StartTimeTo.HasValue)
            {
                query = query.Where(s => s.StartTime <= search.StartTimeTo.Value);
            }

            if (search.DateFrom.HasValue)
            {
                query = query.Where(s => s.StartTime.Date >= search.DateFrom.Value.Date);
            }

            if (search.DateTo.HasValue)
            {
                query = query.Where(s => s.StartTime.Date <= search.DateTo.Value.Date);
            }

            if (search.IsActive.HasValue)
            {
                query = query.Where(s => s.IsActive == search.IsActive.Value);
            }

            return query;
        }

        public override async Task<ScreeningResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Set<Screening>()
                .Include(s => s.Movie)
                .Include(s => s.Hall)
                .Include(s => s.ScreeningType)
                .FirstOrDefaultAsync(s => s.Id == id);

            if (entity == null)
                return null;

            return MapToResponse(entity);
        }

        private async Task<bool> CheckScreeningConflictAsync(int hallId, DateTime startTime, int movieDuration, int? excludeScreeningId = null)
        {
            var endTime = startTime.AddMinutes(movieDuration);

            var query = _context.Screenings
                .Include(s => s.Movie)
                .Where(s => s.HallId == hallId && s.IsActive);

            if (excludeScreeningId.HasValue)
            {
                query = query.Where(s => s.Id != excludeScreeningId.Value);
            }

            var conflictingScreenings = await query
                .Where(s => 
                    // New screening starts during existing screening
                    (startTime >= s.StartTime && startTime < s.StartTime.AddMinutes(s.Movie.Duration)) ||
                    // New screening ends during existing screening  
                    (endTime > s.StartTime && endTime <= s.StartTime.AddMinutes(s.Movie.Duration)) ||
                    // New screening completely encompasses existing screening
                    (startTime <= s.StartTime && endTime >= s.StartTime.AddMinutes(s.Movie.Duration)))
                .AnyAsync();

            return conflictingScreenings;
        }

        protected override async Task BeforeInsert(Screening entity, ScreeningUpsertRequest request)
        {
            // Verify movie, hall, and screening type exist
            var movie = await _context.Movies.FindAsync(request.MovieId);
            if (movie == null)
            {
                throw new InvalidOperationException("The specified movie does not exist.");
            }

            var hallExists = await _context.Halls.AnyAsync(h => h.Id == request.HallId);
            if (!hallExists)
            {
                throw new InvalidOperationException("The specified hall does not exist.");
            }

            var screeningTypeExists = await _context.ScreeningTypes.AnyAsync(st => st.Id == request.ScreeningTypeId);
            if (!screeningTypeExists)
            {
                throw new InvalidOperationException("The specified screening type does not exist.");
            }

            // Check for scheduling conflicts
            var hasConflict = await CheckScreeningConflictAsync(request.HallId, request.StartTime, movie.Duration);
            if (hasConflict)
            {
                throw new InvalidOperationException("This screening conflicts with an existing screening in the same hall.");
            }
        }

        protected override async Task BeforeUpdate(Screening entity, ScreeningUpsertRequest request)
        {
            // Verify movie, hall, and screening type exist
            var movie = await _context.Movies.FindAsync(request.MovieId);
            if (movie == null)
            {
                throw new InvalidOperationException("The specified movie does not exist.");
            }

            var hallExists = await _context.Halls.AnyAsync(h => h.Id == request.HallId);
            if (!hallExists)
            {
                throw new InvalidOperationException("The specified hall does not exist.");
            }

            var screeningTypeExists = await _context.ScreeningTypes.AnyAsync(st => st.Id == request.ScreeningTypeId);
            if (!screeningTypeExists)
            {
                throw new InvalidOperationException("The specified screening type does not exist.");
            }

            // Check for scheduling conflicts (excluding current screening)
            var hasConflict = await CheckScreeningConflictAsync(request.HallId, request.StartTime, movie.Duration, entity.Id);
            if (hasConflict)
            {
                throw new InvalidOperationException("This screening conflicts with an existing screening in the same hall.");
            }
        }
    }
}
