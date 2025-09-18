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
    public class SeatService : BaseCRUDService<SeatResponse, SeatSearchObject, Seat, SeatUpsertRequest, SeatUpsertRequest>, ISeatService
    {
        public SeatService(CineVibeDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override SeatResponse MapToResponse(Seat entity)
        {
            return new SeatResponse
            {
                Id = entity.Id,
                SeatNumber = entity.SeatNumber,
                IsActive = entity.IsActive,
                CreatedAt = entity.CreatedAt,
                HallId = entity.HallId,
                HallName = entity.Hall?.Name ?? string.Empty,
                SeatTypeId = entity.SeatTypeId,
                SeatTypeName = entity.SeatType?.Name
            };
        }

        protected override IQueryable<Seat> ApplyFilter(IQueryable<Seat> query, SeatSearchObject search)
        {
            // Include navigation properties for proper mapping
            query = query.Include(s => s.Hall).Include(s => s.SeatType);

            if (!string.IsNullOrEmpty(search.SeatNumber))
            {
                query = query.Where(s => s.SeatNumber.Contains(search.SeatNumber));
            }

            if (search.HallId.HasValue)
            {
                query = query.Where(s => s.HallId == search.HallId.Value);
            }

            if (search.SeatTypeId.HasValue)
            {
                query = query.Where(s => s.SeatTypeId == search.SeatTypeId.Value);
            }

            if (search.IsActive.HasValue)
            {
                query = query.Where(s => s.IsActive == search.IsActive.Value);
            }

            return query;
        }

        public override async Task<SeatResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Set<Seat>()
                .Include(s => s.Hall)
                .Include(s => s.SeatType)
                .FirstOrDefaultAsync(s => s.Id == id);

            if (entity == null)
                return null;

            return MapToResponse(entity);
        }

        public async Task<bool> UpdateSeatTypeAsync(int seatId, int? seatTypeId)
        {
            var seat = await _context.Seats.FindAsync(seatId);
            if (seat == null)
                return false;

            // Verify seat type exists if provided
            if (seatTypeId.HasValue)
            {
                var seatTypeExists = await _context.SeatTypes.AnyAsync(st => st.Id == seatTypeId.Value);
                if (!seatTypeExists)
                    return false;
            }

            seat.SeatTypeId = seatTypeId;
            await _context.SaveChangesAsync();

            return true;
        }

        public async Task<List<SeatResponse>> GetSeatsByHallAsync(int hallId)
        {
            var seats = await _context.Seats
                .Where(s => s.HallId == hallId)
                .Include(s => s.Hall)
                .Include(s => s.SeatType)
                .ToListAsync();

            return seats.Select(s => MapToResponse(s)).ToList();
        }

        protected override async Task BeforeInsert(Seat entity, SeatUpsertRequest request)
        {
            // Verify hall exists
            var hallExists = await _context.Halls.AnyAsync(h => h.Id == request.HallId);
            if (!hallExists)
            {
                throw new InvalidOperationException("The specified hall does not exist.");
            }

            // Check if seat number already exists in the hall
            if (await _context.Seats.AnyAsync(s => s.SeatNumber == request.SeatNumber && s.HallId == request.HallId))
            {
                throw new InvalidOperationException("A seat with this number already exists in the hall.");
            }

            // Verify seat type exists if provided
            if (request.SeatTypeId.HasValue)
            {
                var seatTypeExists = await _context.SeatTypes.AnyAsync(st => st.Id == request.SeatTypeId.Value);
                if (!seatTypeExists)
                {
                    throw new InvalidOperationException("The specified seat type does not exist.");
                }
            }
        }

        protected override async Task BeforeUpdate(Seat entity, SeatUpsertRequest request)
        {
            // Verify hall exists
            var hallExists = await _context.Halls.AnyAsync(h => h.Id == request.HallId);
            if (!hallExists)
            {
                throw new InvalidOperationException("The specified hall does not exist.");
            }

            // Check if seat number already exists in the hall (excluding current seat)
            if (await _context.Seats.AnyAsync(s => s.SeatNumber == request.SeatNumber && s.HallId == request.HallId && s.Id != entity.Id))
            {
                throw new InvalidOperationException("A seat with this number already exists in the hall.");
            }

            // Verify seat type exists if provided
            if (request.SeatTypeId.HasValue)
            {
                var seatTypeExists = await _context.SeatTypes.AnyAsync(st => st.Id == request.SeatTypeId.Value);
                if (!seatTypeExists)
                {
                    throw new InvalidOperationException("The specified seat type does not exist.");
                }
            }
        }
    }
}
