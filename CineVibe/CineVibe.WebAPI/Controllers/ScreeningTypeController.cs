using CineVibe.Model.Requests;
using CineVibe.Model.Responses;
using CineVibe.Model.SearchObjects;
using CineVibe.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace CineVibe.WebAPI.Controllers
{
    public class ScreeningTypeController : BaseCRUDController<ScreeningTypeResponse, ScreeningTypeSearchObject, ScreeningTypeUpsertRequest, ScreeningTypeUpsertRequest>
    {
        public ScreeningTypeController(IScreeningTypeService service) : base(service)
        {
        }
    }
}
