using CineVibe.Model.Requests;
using CineVibe.Model.Responses;
using CineVibe.Model.SearchObjects;
using CineVibe.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace CineVibe.WebAPI.Controllers
{
    public class ScreeningController : BaseCRUDController<ScreeningResponse, ScreeningSearchObject, ScreeningUpsertRequest, ScreeningUpsertRequest>
    {
        private readonly IScreeningService _service;

        public ScreeningController(IScreeningService service) : base(service)
        {
            _service = service;
        }

        [HttpGet("{id}/seats")]
        public async Task<ActionResult<ScreeningWithSeatsResponse>> GetScreeningWithSeats(int id)
        {
            var result = await _service.GetScreeningWithSeatsAsync(id);
            if (result == null)
                return NotFound();
            
            return Ok(result);
        }
    }
}
