using CineVibe.Services.Database;
using System.Collections.Generic;
using System.Threading.Tasks;
using CineVibe.Model.Responses;
using CineVibe.Model.Requests;
using CineVibe.Model.SearchObjects;

namespace CineVibe.Services.Interfaces
{
    public interface IService<T, TSearch> where T : class where TSearch : BaseSearchObject
    {
        Task<PagedResult<T>> GetAsync(TSearch search);
        Task<T?> GetByIdAsync(int id);
    }
}