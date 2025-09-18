using CineVibe.Model.Requests;
using CineVibe.Model.Responses;
using CineVibe.Model.SearchObjects;

namespace CineVibe.Services.Interfaces
{
    public interface IMovieService : ICRUDService<MovieResponse, MovieSearchObject, MovieUpsertRequest, MovieUpsertRequest>
    {
        Task<List<ActorResponse>> GetMovieActorsAsync(int movieId);
        Task<bool> AssignActorToMovieAsync(int movieId, int actorId);
        Task<bool> RemoveActorFromMovieAsync(int movieId, int actorId);
    }
}
