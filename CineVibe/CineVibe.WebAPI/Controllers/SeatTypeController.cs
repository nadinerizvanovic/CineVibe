using CineVibe.Model.Requests;
using CineVibe.Model.Responses;
using CineVibe.Model.SearchObjects;
using CineVibe.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace CineVibe.WebAPI.Controllers
{
    public class SeatTypeController : BaseCRUDController<SeatTypeResponse, SeatTypeSearchObject, SeatTypeUpsertRequest, SeatTypeUpsertRequest>
    {
        public SeatTypeController(ISeatTypeService service) : base(service)
        {
        }
    }
}
