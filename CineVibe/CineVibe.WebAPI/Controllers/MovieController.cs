using CineVibe.Model.Requests;
using CineVibe.Model.Responses;
using CineVibe.Model.SearchObjects;
using CineVibe.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace CineVibe.WebAPI.Controllers
{
    public class MovieController : BaseCRUDController<MovieResponse, MovieSearchObject, MovieUpsertRequest, MovieUpsertRequest>
    {
        private readonly IMovieService _movieService;

        public MovieController(IMovieService service) : base(service)
        {
            _movieService = service;
        }

        /// <summary>
        /// Get all actors for a specific movie
        /// </summary>
        /// <param name="movieId">Movie ID</param>
        /// <returns>List of actors in the movie</returns>
        [HttpGet("{movieId}/actors")]
        public async Task<ActionResult<List<ActorResponse>>> GetMovieActors(int movieId)
        {
            try
            {
                var actors = await _movieService.GetMovieActorsAsync(movieId);
                return Ok(actors);
            }
            catch (KeyNotFoundException)
            {
                return NotFound($"Movie with ID {movieId} not found");
            }
        }

        /// <summary>
        /// Assign an actor to a movie
        /// </summary>
        /// <param name="movieId">Movie ID</param>
        /// <param name="actorId">Actor ID</param>
        /// <returns>Success status</returns>
        [HttpPost("{movieId}/actors/{actorId}")]
        public async Task<ActionResult> AssignActorToMovie(int movieId, int actorId)
        {
            var success = await _movieService.AssignActorToMovieAsync(movieId, actorId);
            
            if (!success)
                return BadRequest("Failed to assign actor to movie. Actor may already be assigned or movie/actor doesn't exist.");
            
            return Ok("Actor successfully assigned to movie");
        }

        /// <summary>
        /// Remove an actor from a movie
        /// </summary>
        /// <param name="movieId">Movie ID</param>
        /// <param name="actorId">Actor ID</param>
        /// <returns>Success status</returns>
        [HttpDelete("{movieId}/actors/{actorId}")]
        public async Task<ActionResult> RemoveActorFromMovie(int movieId, int actorId)
        {
            var success = await _movieService.RemoveActorFromMovieAsync(movieId, actorId);
            
            if (!success)
                return NotFound("Actor assignment not found");
            
            return Ok("Actor successfully removed from movie");
        }
    }
}
