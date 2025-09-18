using CineVibe.Model.Requests;
using CineVibe.Model.Responses;
using CineVibe.Model.SearchObjects;

namespace CineVibe.Services.Interfaces
{
    public interface ISeatService : ICRUDService<SeatResponse, SeatSearchObject, SeatUpsertRequest, SeatUpsertRequest>
    {
        Task<bool> UpdateSeatTypeAsync(int seatId, int? seatTypeId);
        Task<List<SeatResponse>> GetSeatsByHallAsync(int hallId);
    }
}
