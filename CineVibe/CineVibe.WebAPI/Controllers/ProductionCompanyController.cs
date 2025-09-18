using CineVibe.Model.Requests;
using CineVibe.Model.Responses;
using CineVibe.Model.SearchObjects;
using CineVibe.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace CineVibe.WebAPI.Controllers
{
    public class ProductionCompanyController : BaseCRUDController<ProductionCompanyResponse, ProductionCompanySearchObject, ProductionCompanyUpsertRequest, ProductionCompanyUpsertRequest>
    {
        public ProductionCompanyController(IProductionCompanyService service) : base(service)
        {
        }
    }
}
