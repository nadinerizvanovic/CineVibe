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
    public class GenreService : BaseCRUDService<GenreResponse, GenreSearchObject, Genre, GenreUpsertRequest, GenreUpsertRequest>, IGenreService
    {
        public GenreService(CineVibeDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Genre> ApplyFilter(IQueryable<Genre> query, GenreSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(x => x.Name.Contains(search.Name));
            }

            if (search.IsActive.HasValue)
            {
                query = query.Where(x => x.IsActive == search.IsActive.Value);
            }

            return query;
        }

        protected override async Task BeforeInsert(Genre entity, GenreUpsertRequest request)
        {
            if (await _context.Genres.AnyAsync(g => g.Name == request.Name))
            {
                throw new InvalidOperationException("A genre with this name already exists.");
            }
        }

        protected override async Task BeforeUpdate(Genre entity, GenreUpsertRequest request)
        {
            if (await _context.Genres.AnyAsync(g => g.Name == request.Name && g.Id != entity.Id))
            {
                throw new InvalidOperationException("A genre with this name already exists.");
            }
        }
    }
}
