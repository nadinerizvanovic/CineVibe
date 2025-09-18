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
    public class ProductionCompanyService : BaseCRUDService<ProductionCompanyResponse, ProductionCompanySearchObject, ProductionCompany, ProductionCompanyUpsertRequest, ProductionCompanyUpsertRequest>, IProductionCompanyService
    {
        public ProductionCompanyService(CineVibeDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override ProductionCompanyResponse MapToResponse(ProductionCompany entity)
        {
            return new ProductionCompanyResponse
            {
                Id = entity.Id,
                Name = entity.Name,
                Description = entity.Description,
                Country = entity.Country,
                IsActive = entity.IsActive,
                CreatedAt = entity.CreatedAt,
                MovieCount = entity.MovieProductionCompanies?.Count ?? 0
            };
        }

        protected override IQueryable<ProductionCompany> ApplyFilter(IQueryable<ProductionCompany> query, ProductionCompanySearchObject search)
        {
            // Include navigation properties for proper mapping
            query = query.Include(pc => pc.MovieProductionCompanies);

            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(pc => pc.Name.Contains(search.Name));
            }

            if (!string.IsNullOrEmpty(search.Country))
            {
                query = query.Where(pc => pc.Country != null && pc.Country.Contains(search.Country));
            }

            if (search.IsActive.HasValue)
            {
                query = query.Where(pc => pc.IsActive == search.IsActive.Value);
            }

            return query;
        }

        public override async Task<ProductionCompanyResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Set<ProductionCompany>()
                .Include(pc => pc.MovieProductionCompanies)
                .FirstOrDefaultAsync(pc => pc.Id == id);

            if (entity == null)
                return null;

            return MapToResponse(entity);
        }

        protected override async Task BeforeInsert(ProductionCompany entity, ProductionCompanyUpsertRequest request)
        {
            if (await _context.ProductionCompanies.AnyAsync(pc => pc.Name == request.Name))
            {
                throw new InvalidOperationException("A production company with this name already exists.");
            }
        }

        protected override async Task BeforeUpdate(ProductionCompany entity, ProductionCompanyUpsertRequest request)
        {
            if (await _context.ProductionCompanies.AnyAsync(pc => pc.Name == request.Name && pc.Id != entity.Id))
            {
                throw new InvalidOperationException("A production company with this name already exists.");
            }
        }
    }
}
