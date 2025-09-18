using CineVibe.Model.Requests;
using CineVibe.Model.Responses;
using CineVibe.Model.SearchObjects;
using CineVibe.Services.Interfaces;

namespace CineVibe.WebAPI.Controllers
{
    public class MovieActorController : BaseCRUDController<MovieActorResponse, MovieActorSearchObject, MovieActorUpsertRequest, MovieActorUpsertRequest>
    {
        public MovieActorController(IMovieActorService service) : base(service)
        {
        }
    }
}
