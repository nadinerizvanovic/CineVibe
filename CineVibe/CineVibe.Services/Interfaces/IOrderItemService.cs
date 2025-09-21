using CineVibe.Model.Requests;
using CineVibe.Model.Responses;
using CineVibe.Model.SearchObjects;

namespace CineVibe.Services.Interfaces
{
    public interface IOrderItemService : ICRUDService<OrderItemResponse, OrderItemSearchObject, OrderItemUpsertRequest, OrderItemUpsertRequest>
    {
    }
}
