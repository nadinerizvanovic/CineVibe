using CineVibe.Model.Requests;
using CineVibe.Model.Responses;
using CineVibe.Model.SearchObjects;
using CineVibe.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CineVibe.WebAPI.Controllers
{
    public class CityController : BaseCRUDController<CityResponse, CitySearchObject, CityUpsertRequest, CityUpsertRequest>
    {
        public CityController(ICityService service) : base(service)
        {
        }

        [AllowAnonymous]
        public override async Task<PagedResult<CityResponse>> Get([FromQuery] CitySearchObject? search = null)
        {
            return await base.Get(search);
        }

        [AllowAnonymous]
        public override async Task<CityResponse?> GetById(int id)
        {
            return await base.GetById(id);
        }
    }
} 