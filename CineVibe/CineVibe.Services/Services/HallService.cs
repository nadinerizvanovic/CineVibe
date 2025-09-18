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
    public class HallService : BaseCRUDService<HallResponse, HallSearchObject, Hall, HallUpsertRequest, HallUpsertRequest>, IHallService
    {
        public HallService(CineVibeDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override HallResponse MapToResponse(Hall entity)
        {
            return new HallResponse
            {
                Id = entity.Id,
                Name = entity.Name,
                IsActive = entity.IsActive,
                CreatedAt = entity.CreatedAt,
                SeatCount = entity.Seats?.Count ?? 0
            };
        }

        protected override IQueryable<Hall> ApplyFilter(IQueryable<Hall> query, HallSearchObject search)
        {
            // Include navigation properties for proper mapping
            query = query.Include(h => h.Seats);

            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(h => h.Name.Contains(search.Name));
            }

            if (search.IsActive.HasValue)
            {
                query = query.Where(h => h.IsActive == search.IsActive.Value);
            }

            return query;
        }

        public override async Task<HallResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Set<Hall>()
                .Include(h => h.Seats)
                .FirstOrDefaultAsync(h => h.Id == id);

            if (entity == null)
                return null;

            return MapToResponse(entity);
        }

        public async Task<bool> GenerateSeatsForHallAsync(int hallId, int rows, int seatsPerRow)
        {
            var hall = await _context.Halls.FindAsync(hallId);
            if (hall == null)
                return false;

            // Clear existing seats
            var existingSeats = await _context.Seats.Where(s => s.HallId == hallId).ToListAsync();
            _context.Seats.RemoveRange(existingSeats);

            // Generate new seats
            var seats = new List<Seat>();
            for (int row = 0; row < rows; row++)
            {
                char rowLetter = (char)('A' + row);
                for (int seatNum = 1; seatNum <= seatsPerRow; seatNum++)
                {
                    seats.Add(new Seat
                    {
                        SeatNumber = $"{rowLetter}{seatNum}",
                        HallId = hallId,
                        IsActive = true,
                        CreatedAt = DateTime.Now
                    });
                }
            }

            _context.Seats.AddRange(seats);
            await _context.SaveChangesAsync();

            return true;
        }

        public async Task<List<SeatResponse>> GetHallSeatsAsync(int hallId)
        {
            var seats = await _context.Seats
                .Where(s => s.HallId == hallId)
                .Include(s => s.Hall)
                .Include(s => s.SeatType)
                .ToListAsync();

            return seats.Select(s => new SeatResponse
            {
                Id = s.Id,
                SeatNumber = s.SeatNumber,
                IsActive = s.IsActive,
                CreatedAt = s.CreatedAt,
                HallId = s.HallId,
                HallName = s.Hall.Name,
                SeatTypeId = s.SeatTypeId,
                SeatTypeName = s.SeatType?.Name
            }).ToList();
        }

        protected override async Task BeforeInsert(Hall entity, HallUpsertRequest request)
        {
            if (await _context.Halls.AnyAsync(h => h.Name == request.Name))
            {
                throw new InvalidOperationException("A hall with this name already exists.");
            }
        }

        protected override async Task BeforeUpdate(Hall entity, HallUpsertRequest request)
        {
            if (await _context.Halls.AnyAsync(h => h.Name == request.Name && h.Id != entity.Id))
            {
                throw new InvalidOperationException("A hall with this name already exists.");
            }
        }
    }
}
