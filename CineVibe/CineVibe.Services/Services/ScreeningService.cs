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
                Price = entity.ScreeningType?.Price ?? 0,
                OccupiedSeatsCount = 0 // Will be set in ApplyFilter for list operations
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

            if (search.DateOfScreening.HasValue)
            {
                query = query.Where(s => s.StartTime.Date == search.DateOfScreening.Value.Date);
            }

            if (search.IsActive.HasValue)
            {
                query = query.Where(s => s.IsActive == search.IsActive.Value);
            }

            if (!string.IsNullOrEmpty(search.MovieTitle))
            {
                query = query.Where(s => s.Movie.Title.Contains(search.MovieTitle));
            }

            if (!string.IsNullOrEmpty(search.HallName))
            {
                query = query.Where(s => s.Hall.Name.Contains(search.HallName));
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

            var response = MapToResponse(entity);
            response.OccupiedSeatsCount = await GetOccupiedSeatsCountAsync(id);
            return response;
        }

        public override async Task<PagedResult<ScreeningResponse>> GetAsync(ScreeningSearchObject search)
        {
            var query = _context.Set<Screening>().AsQueryable();
            query = ApplyFilter(query, search);

            int? totalCount = null;
            if (search.IncludeTotalCount)
            {
                totalCount = await query.CountAsync();
            }

            if (!search.RetrieveAll)
            {
                if (search.Page.HasValue)
                {
                    query = query.Skip(search.Page.Value * search.PageSize.Value);
                }
                if (search.PageSize.HasValue)
                {
                    query = query.Take(search.PageSize.Value);
                }
            }

            var entities = await query.ToListAsync();
            var responses = new List<ScreeningResponse>();
            
            foreach (var entity in entities)
            {
                var response = MapToResponse(entity);
                response.OccupiedSeatsCount = await GetOccupiedSeatsCountAsync(entity.Id);
                responses.Add(response);
            }

            return new PagedResult<ScreeningResponse>
            {
                Items = responses,
                TotalCount = totalCount
            };
        }

        private async Task<int> GetOccupiedSeatsCountAsync(int screeningId)
        {
            return await _context.Tickets
                .Where(t => t.ScreeningId == screeningId && t.IsActive)
                .CountAsync();
        }

        public async Task<ScreeningWithSeatsResponse?> GetScreeningWithSeatsAsync(int id)
        {
            var screening = await _context.Set<Screening>()
                .Include(s => s.Movie)
                .Include(s => s.Hall)
                .Include(s => s.ScreeningType)
                .FirstOrDefaultAsync(s => s.Id == id);

            if (screening == null)
                return null;

            // Get all seats for the hall
            var seats = await _context.Seats
                .Include(s => s.SeatType)
                .Where(s => s.HallId == screening.HallId)
                .ToListAsync();

            // Get all tickets for this screening
            var tickets = await _context.Tickets
                .Include(t => t.User)
                .Where(t => t.ScreeningId == id && t.IsActive)
                .ToListAsync();

            // Create a map of occupied seats
            var occupiedSeats = tickets.ToDictionary(t => t.SeatId, t => new { t.Id, UserFullName = $"{t.User.FirstName} {t.User.LastName}" });

            var response = new ScreeningWithSeatsResponse
            {
                Id = screening.Id,
                StartTime = screening.StartTime,
                IsActive = screening.IsActive,
                CreatedAt = screening.CreatedAt,
                MovieId = screening.MovieId,
                MovieTitle = screening.Movie?.Title ?? string.Empty,
                MovieDuration = screening.Movie?.Duration ?? 0,
                HallId = screening.HallId,
                HallName = screening.Hall?.Name ?? string.Empty,
                ScreeningTypeId = screening.ScreeningTypeId,
                ScreeningTypeName = screening.ScreeningType?.Name ?? string.Empty,
                Price = screening.ScreeningType?.Price ?? 0,
                Seats = seats.Select(seat => new SeatWithTicketInfo
                {
                    Id = seat.Id,
                    SeatNumber = seat.SeatNumber,
                    IsActive = seat.IsActive,
                    HallId = seat.HallId,
                    SeatTypeId = seat.SeatTypeId,
                    SeatTypeName = seat.SeatType?.Name,
                    IsOccupied = occupiedSeats.ContainsKey(seat.Id),
                    TicketId = occupiedSeats.ContainsKey(seat.Id) ? occupiedSeats[seat.Id].Id : null,
                    UserFullName = occupiedSeats.ContainsKey(seat.Id) ? occupiedSeats[seat.Id].UserFullName : null
                }).ToList()
            };

            return response;
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
