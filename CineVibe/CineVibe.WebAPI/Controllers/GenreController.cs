using CineVibe.Model.Requests;
using CineVibe.Model.Responses;
using CineVibe.Model.SearchObjects;
using CineVibe.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace CineVibe.WebAPI.Controllers
{
    public class GenreController : BaseCRUDController<GenreResponse, GenreSearchObject, GenreUpsertRequest, GenreUpsertRequest>
    {
        public GenreController(IGenreService service) : base(service)
        {
        }
    }
}
