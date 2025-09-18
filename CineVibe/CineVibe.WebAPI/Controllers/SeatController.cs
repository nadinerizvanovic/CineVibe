using CineVibe.Model.Requests;
using CineVibe.Model.Responses;
using CineVibe.Model.SearchObjects;
using CineVibe.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace CineVibe.WebAPI.Controllers
{
    public class SeatController : BaseCRUDController<SeatResponse, SeatSearchObject, SeatUpsertRequest, SeatUpsertRequest>
    {
        private readonly ISeatService _seatService;

        public SeatController(ISeatService service) : base(service)
        {
            _seatService = service;
        }

        [HttpPut("{id}/seat-type")]
        public async Task<IActionResult> UpdateSeatType(int id, [FromBody] UpdateSeatTypeRequest request)
        {
            var result = await _seatService.UpdateSeatTypeAsync(id, request.SeatTypeId);
            if (result)
                return Ok(new { message = "Seat type updated successfully" });
            
            return BadRequest(new { message = "Failed to update seat type" });
        }

        [HttpGet("by-hall/{hallId}")]
        public async Task<ActionResult<List<SeatResponse>>> GetSeatsByHall(int hallId)
        {
            var seats = await _seatService.GetSeatsByHallAsync(hallId);
            return Ok(seats);
        }
    }

    public class UpdateSeatTypeRequest
    {
        public int? SeatTypeId { get; set; }
    }
}
