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
    public class DirectorService : BaseCRUDService<DirectorResponse, DirectorSearchObject, Director, DirectorUpsertRequest, DirectorUpsertRequest>, IDirectorService
    {
        public DirectorService(CineVibeDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override DirectorResponse MapToResponse(Director entity)
        {
            return new DirectorResponse
            {
                Id = entity.Id,
                FirstName = entity.FirstName,
                LastName = entity.LastName,
                Nationality = entity.Nationality,
                IsActive = entity.IsActive,
                CreatedAt = entity.CreatedAt,
                MovieCount = entity.Movies?.Count ?? 0
            };
        }

        protected override IQueryable<Director> ApplyFilter(IQueryable<Director> query, DirectorSearchObject search)
        {
            // Include navigation properties for proper mapping
            query = query.Include(d => d.Movies);

            if (!string.IsNullOrEmpty(search.FirstName))
            {
                query = query.Where(d => d.FirstName.Contains(search.FirstName));
            }

            if (!string.IsNullOrEmpty(search.LastName))
            {
                query = query.Where(d => d.LastName.Contains(search.LastName));
            }

            if (!string.IsNullOrEmpty(search.FullName))
            {
                query = query.Where(d => (d.FirstName + " " + d.LastName).Contains(search.FullName));
            }

            if (!string.IsNullOrEmpty(search.Nationality))
            {
                query = query.Where(d => d.Nationality != null && d.Nationality.Contains(search.Nationality));
            }

            if (search.IsActive.HasValue)
            {
                query = query.Where(d => d.IsActive == search.IsActive.Value);
            }


            return query;
        }

        public override async Task<DirectorResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Set<Director>()
                .Include(d => d.Movies)
                .FirstOrDefaultAsync(d => d.Id == id);

            if (entity == null)
                return null;

            return MapToResponse(entity);
        }
    }
}
