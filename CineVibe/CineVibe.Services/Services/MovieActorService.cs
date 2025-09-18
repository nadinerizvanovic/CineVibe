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
    public class MovieActorService : BaseCRUDService<MovieActorResponse, MovieActorSearchObject, MovieActor, MovieActorUpsertRequest, MovieActorUpsertRequest>, IMovieActorService
    {
        public MovieActorService(CineVibeDbContext context, IMapper mapper) : base(context, mapper)
        {
        }


        protected override MovieActorResponse MapToResponse(MovieActor entity)
        {
            return new MovieActorResponse
            {
                Id = entity.Id,
                MovieId = entity.MovieId,
                ActorId = entity.ActorId,
                DateAssigned = entity.DateAssigned,
                MovieTitle = entity.Movie?.Title ?? string.Empty,
                ActorFullName = entity.Actor != null ? $"{entity.Actor.FirstName} {entity.Actor.LastName}" : string.Empty
            };
        }

        protected override IQueryable<MovieActor> ApplyFilter(IQueryable<MovieActor> query, MovieActorSearchObject search)
        {
            // Include navigation properties for proper mapping
            query = query.Include(ma => ma.Movie).Include(ma => ma.Actor);
            
            // Apply search filters
            if (search.MovieId.HasValue)
            {
                query = query.Where(ma => ma.MovieId == search.MovieId.Value);
            }

            if (search.ActorId.HasValue)
            {
                query = query.Where(ma => ma.ActorId == search.ActorId.Value);
            }

            if (search.DateAssignedFrom.HasValue)
            {
                query = query.Where(ma => ma.DateAssigned >= search.DateAssignedFrom.Value);
            }

            if (search.DateAssignedTo.HasValue)
            {
                query = query.Where(ma => ma.DateAssigned <= search.DateAssignedTo.Value);
            }

            return query;
        }

        public override async Task<MovieActorResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Set<MovieActor>()
                .Include(ma => ma.Movie)
                .Include(ma => ma.Actor)
                .FirstOrDefaultAsync(ma => ma.Id == id);

            if (entity == null)
                return null;

            return MapToResponse(entity);
        }
    }
}
