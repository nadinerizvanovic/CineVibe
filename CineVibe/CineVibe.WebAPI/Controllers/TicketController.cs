using CineVibe.Model.Requests;
using CineVibe.Model.Responses;
using CineVibe.Model.SearchObjects;
using CineVibe.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace CineVibe.WebAPI.Controllers
{
    public class TicketController : BaseCRUDController<TicketResponse, TicketSearchObject, TicketUpsertRequest, TicketUpsertRequest>
    {
        public TicketController(ITicketService service) : base(service)
        {
        }
    }
}
