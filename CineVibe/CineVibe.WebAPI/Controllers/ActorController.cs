using CineVibe.Model.Requests;
using CineVibe.Model.Responses;
using CineVibe.Model.SearchObjects;
using CineVibe.Services.Interfaces;

namespace CineVibe.WebAPI.Controllers
{
    public class ActorController : BaseCRUDController<ActorResponse, ActorSearchObject, ActorUpsertRequest, ActorUpsertRequest>
    {
        public ActorController(IActorService service) : base(service)
        {
        }
    }
}
