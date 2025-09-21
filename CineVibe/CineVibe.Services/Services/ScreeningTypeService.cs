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
    public class ScreeningTypeService : BaseCRUDService<ScreeningTypeResponse, ScreeningTypeSearchObject, ScreeningType, ScreeningTypeUpsertRequest, ScreeningTypeUpsertRequest>, IScreeningTypeService
    {
        public ScreeningTypeService(CineVibeDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override ScreeningTypeResponse MapToResponse(ScreeningType entity)
        {
            return new ScreeningTypeResponse
            {
                Id = entity.Id,
                Name = entity.Name,
                Description = entity.Description,
                Price = entity.Price,
                IsActive = entity.IsActive,
                CreatedAt = entity.CreatedAt,
                ScreeningCount = entity.Screenings?.Count ?? 0
            };
        }

        protected override IQueryable<ScreeningType> ApplyFilter(IQueryable<ScreeningType> query, ScreeningTypeSearchObject search)
        {
            // Include navigation properties for proper mapping
            query = query.Include(st => st.Screenings);

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

        public override async Task<ScreeningTypeResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Set<ScreeningType>()
                .Include(st => st.Screenings)
                .FirstOrDefaultAsync(st => st.Id == id);

            if (entity == null)
                return null;

            return MapToResponse(entity);
        }

        protected override async Task BeforeInsert(ScreeningType entity, ScreeningTypeUpsertRequest request)
        {
            if (await _context.ScreeningTypes.AnyAsync(st => st.Name == request.Name))
            {
                throw new InvalidOperationException("A screening type with this name already exists.");
            }
        }

        protected override async Task BeforeUpdate(ScreeningType entity, ScreeningTypeUpsertRequest request)
        {
            if (await _context.ScreeningTypes.AnyAsync(st => st.Name == request.Name && st.Id != entity.Id))
            {
                throw new InvalidOperationException("A screening type with this name already exists.");
            }
        }
    }
}
