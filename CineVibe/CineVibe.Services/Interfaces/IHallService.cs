using CineVibe.Model.Requests;
using CineVibe.Model.Responses;
using CineVibe.Model.SearchObjects;

namespace CineVibe.Services.Interfaces
{
    public interface IHallService : ICRUDService<HallResponse, HallSearchObject, HallUpsertRequest, HallUpsertRequest>
    {
        Task<bool> GenerateSeatsForHallAsync(int hallId, int rows, int seatsPerRow);
        Task<List<SeatResponse>> GetHallSeatsAsync(int hallId);
    }
}
