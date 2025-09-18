using CineVibe.Model;
using CineVibe.Model.SearchObjects;
using CineVibe.Model.Responses;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using CineVibe.Services.Interfaces;

namespace CineVibe.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    //[Authorize]
    [AllowAnonymous]
    public class BaseController<T, TSearch> : ControllerBase where T : class where TSearch : BaseSearchObject, new()
    {
        protected readonly IService<T, TSearch> _service;
        
        public BaseController(IService<T, TSearch> service) {
            _service = service;
        }

        [HttpGet("")]
        public virtual async Task<PagedResult<T>> Get([FromQuery]TSearch? search = null)
        {
            return await _service.GetAsync(search ?? new TSearch());
        }

        [HttpGet("{id}")]
        public virtual async Task<T?> GetById(int id)
        {
            return await _service.GetByIdAsync(id);
        }
    }
}
