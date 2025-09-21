using CineVibe.Model.Requests;
using CineVibe.Model.Responses;
using CineVibe.Model.SearchObjects;
using CineVibe.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace CineVibe.WebAPI.Controllers
{
    public class CartItemController : BaseCRUDController<CartItemResponse, CartItemSearchObject, CartItemUpsertRequest, CartItemUpsertRequest>
    {
        public CartItemController(ICartItemService service) : base(service)
        {
        }
    }
}
