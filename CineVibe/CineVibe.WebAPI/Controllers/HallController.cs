using CineVibe.Model.Requests;
using CineVibe.Model.Responses;
using CineVibe.Model.SearchObjects;
using CineVibe.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace CineVibe.WebAPI.Controllers
{
    public class HallController : BaseCRUDController<HallResponse, HallSearchObject, HallUpsertRequest, HallUpsertRequest>
    {
        private readonly IHallService _hallService;

        public HallController(IHallService service) : base(service)
        {
            _hallService = service;
        }

        [HttpPost("{id}/generate-seats")]
        public async Task<IActionResult> GenerateSeats(int id, [FromBody] GenerateSeatsRequest request)
        {
            var result = await _hallService.GenerateSeatsForHallAsync(id, request.Rows, request.SeatsPerRow);
            if (result)
                return Ok(new { message = "Seats generated successfully" });
            
            return BadRequest(new { message = "Failed to generate seats" });
        }

        [HttpGet("{id}/seats")]
        public async Task<ActionResult<List<SeatResponse>>> GetHallSeats(int id)
        {
            var seats = await _hallService.GetHallSeatsAsync(id);
            return Ok(seats);
        }
    }

    public class GenerateSeatsRequest
    {
        public int Rows { get; set; }
        public int SeatsPerRow { get; set; }
    }
}
