using CineVibe.Model.Requests;
using CineVibe.Model.Responses;
using CineVibe.Model.SearchObjects;
using CineVibe.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace CineVibe.WebAPI.Controllers
{
    public class OrderItemController : BaseCRUDController<OrderItemResponse, OrderItemSearchObject, OrderItemUpsertRequest, OrderItemUpsertRequest>
    {
        public OrderItemController(IOrderItemService service) : base(service)
        {
        }
    }
}
