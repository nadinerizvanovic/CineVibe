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
    public class ProductService : BaseCRUDService<ProductResponse, ProductSearchObject, Product, ProductUpsertRequest, ProductUpsertRequest>, IProductService
    {
        public ProductService(CineVibeDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Product> ApplyFilter(IQueryable<Product> query, ProductSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(p => p.Name.Contains(search.Name));
            }

            if (search.MinPrice.HasValue)
            {
                query = query.Where(p => p.Price >= search.MinPrice.Value);
            }

            if (search.MaxPrice.HasValue)
            {
                query = query.Where(p => p.Price <= search.MaxPrice.Value);
            }

            if (search.IsActive.HasValue)
            {
                query = query.Where(p => p.IsActive == search.IsActive.Value);
            }

            return query;
        }

        protected override async Task BeforeInsert(Product entity, ProductUpsertRequest request)
        {
            if (await _context.Products.AnyAsync(p => p.Name == request.Name))
            {
                throw new InvalidOperationException("A product with this name already exists.");
            }
        }

        protected override async Task BeforeUpdate(Product entity, ProductUpsertRequest request)
        {
            if (await _context.Products.AnyAsync(p => p.Name == request.Name && p.Id != entity.Id))
            {
                throw new InvalidOperationException("A product with this name already exists.");
            }
        }
    }
}
