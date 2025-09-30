using CineVibe.Model.Requests;
using CineVibe.Model.Responses;
using CineVibe.Model.SearchObjects;
using CineVibe.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CineVibe.WebAPI.Controllers
{
    public class GenderController : BaseCRUDController<GenderResponse, GenderSearchObject, GenderUpsertRequest, GenderUpsertRequest>
    {
        public GenderController(IGenderService service) : base(service)
        {
        }

        [AllowAnonymous]
        public override async Task<PagedResult<GenderResponse>> Get([FromQuery] GenderSearchObject? search = null)
        {
            return await base.Get(search);
        }

        [AllowAnonymous]
        public override async Task<GenderResponse?> GetById(int id)
        {
            return await base.GetById(id);
        }
    }
} 