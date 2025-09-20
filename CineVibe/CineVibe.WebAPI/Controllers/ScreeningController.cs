using CineVibe.Model.Requests;
using CineVibe.Model.Responses;
using CineVibe.Model.SearchObjects;
using CineVibe.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace CineVibe.WebAPI.Controllers
{
    public class ScreeningController : BaseCRUDController<ScreeningResponse, ScreeningSearchObject, ScreeningUpsertRequest, ScreeningUpsertRequest>
    {
        public ScreeningController(IScreeningService service) : base(service)
        {
        }
    }
}
