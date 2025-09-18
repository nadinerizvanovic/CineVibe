using CineVibe.Model.Requests;
using CineVibe.Model.Responses;
using CineVibe.Model.SearchObjects;
using CineVibe.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace CineVibe.WebAPI.Controllers
{
    public class DirectorController : BaseCRUDController<DirectorResponse, DirectorSearchObject, DirectorUpsertRequest, DirectorUpsertRequest>
    {
        public DirectorController(IDirectorService service) : base(service)
        {
        }
    }
}
