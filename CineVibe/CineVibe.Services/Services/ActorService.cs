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
    public class ActorService : BaseCRUDService<ActorResponse, ActorSearchObject, Actor, ActorUpsertRequest, ActorUpsertRequest>, IActorService
    {
        public ActorService(CineVibeDbContext context, IMapper mapper) : base(context, mapper)
        {
        }


        protected override ActorResponse MapToResponse(Actor entity)
        {
            return new ActorResponse
            {
                Id = entity.Id,
                FirstName = entity.FirstName,
                LastName = entity.LastName,
                IsActive = entity.IsActive,
                CreatedAt = entity.CreatedAt,
                MovieCount = entity.MovieActors?.Count ?? 0
            };
        }

        protected override IQueryable<Actor> ApplyFilter(IQueryable<Actor> query, ActorSearchObject search)
        {
            // Include navigation properties for proper mapping
            query = query.Include(a => a.MovieActors);
            
            // Apply search filters
            if (!string.IsNullOrWhiteSpace(search.FirstName))
            {
                query = query.Where(a => a.FirstName.ToLower().Contains(search.FirstName.ToLower()));
            }

            if (!string.IsNullOrWhiteSpace(search.LastName))
            {
                query = query.Where(a => a.LastName.ToLower().Contains(search.LastName.ToLower()));
            }

            if (!string.IsNullOrWhiteSpace(search.FullName))
            {
                query = query.Where(a => (a.FirstName + " " + a.LastName).ToLower().Contains(search.FullName.ToLower()));
            }

            if (search.IsActive.HasValue)
            {
                query = query.Where(a => a.IsActive == search.IsActive.Value);
            }

            return query;
        }

        public override async Task<ActorResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Set<Actor>()
                .Include(a => a.MovieActors)
                .FirstOrDefaultAsync(a => a.Id == id);

            if (entity == null)
                return null;

            return MapToResponse(entity);
        }
    }
}
