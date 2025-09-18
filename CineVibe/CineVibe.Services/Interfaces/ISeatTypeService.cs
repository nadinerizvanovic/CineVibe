using CineVibe.Model.Requests;
using CineVibe.Model.Responses;
using CineVibe.Model.SearchObjects;

namespace CineVibe.Services.Interfaces
{
    public interface ISeatTypeService : ICRUDService<SeatTypeResponse, SeatTypeSearchObject, SeatTypeUpsertRequest, SeatTypeUpsertRequest>
    {
    }
}
