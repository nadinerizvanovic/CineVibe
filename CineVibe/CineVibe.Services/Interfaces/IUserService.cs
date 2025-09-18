using CineVibe.Services.Database;
using System.Collections.Generic;
using System.Threading.Tasks;
using CineVibe.Model.Responses;
using CineVibe.Model.Requests;
using CineVibe.Model.SearchObjects;
using CineVibe.Services.Services;

namespace CineVibe.Services.Interfaces
{
    public interface IUserService : IService<UserResponse, UserSearchObject>
    {
        Task<UserResponse?> AuthenticateAsync(UserLoginRequest request);
        Task<UserResponse> CreateAsync(UserUpsertRequest request);
        Task<UserResponse?> UpdateAsync(int id, UserUpsertRequest request);
        Task<bool> DeleteAsync(int id);
    }
}