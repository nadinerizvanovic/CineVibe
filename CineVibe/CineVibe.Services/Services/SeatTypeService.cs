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
    public class SeatTypeService : BaseCRUDService<SeatTypeResponse, SeatTypeSearchObject, SeatType, SeatTypeUpsertRequest, SeatTypeUpsertRequest>, ISeatTypeService
    {
        public SeatTypeService(CineVibeDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override SeatTypeResponse MapToResponse(SeatType entity)
        {
            return new SeatTypeResponse
            {
                Id = entity.Id,
                Name = entity.Name,
                IsActive = entity.IsActive,
                CreatedAt = entity.CreatedAt,
                SeatCount = entity.Seats?.Count ?? 0
            };
        }

        protected override IQueryable<SeatType> ApplyFilter(IQueryable<SeatType> query, SeatTypeSearchObject search)
        {
            // Include navigation properties for proper mapping
            query = query.Include(st => st.Seats);

            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(st => st.Name.Contains(search.Name));
            }

            if (search.IsActive.HasValue)
            {
                query = query.Where(st => st.IsActive == search.IsActive.Value);
            }

            return query;
        }

        public override async Task<SeatTypeResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Set<SeatType>()
                .Include(st => st.Seats)
                .FirstOrDefaultAsync(st => st.Id == id);

            if (entity == null)
                return null;

            return MapToResponse(entity);
        }

        protected override async Task BeforeInsert(SeatType entity, SeatTypeUpsertRequest request)
        {
            if (await _context.SeatTypes.AnyAsync(st => st.Name == request.Name))
            {
                throw new InvalidOperationException("A seat type with this name already exists.");
            }
        }

        protected override async Task BeforeUpdate(SeatType entity, SeatTypeUpsertRequest request)
        {
            if (await _context.SeatTypes.AnyAsync(st => st.Name == request.Name && st.Id != entity.Id))
            {
                throw new InvalidOperationException("A seat type with this name already exists.");
            }
        }
    }
}
