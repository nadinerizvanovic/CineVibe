using CineVibe.Model.Requests;
using CineVibe.Model.Responses;
using CineVibe.Model.SearchObjects;

namespace CineVibe.Services.Interfaces
{
    public interface IOrderService : ICRUDService<OrderResponse, OrderSearchObject, OrderUpsertRequest, OrderUpsertRequest>
    {
        Task<OrderResponse> CreateOrderFromCartAsync(int userId);
        Task<List<OrderResponse>> GetOrdersByUserAsync(int userId);
    }
}
