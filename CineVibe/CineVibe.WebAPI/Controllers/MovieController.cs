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

        /// <summary>
        /// Get all production companies for a specific movie
        /// </summary>
        /// <param name="movieId">Movie ID</param>
        /// <returns>List of production companies for the movie</returns>
        [HttpGet("{movieId}/production-companies")]
        public async Task<ActionResult<List<ProductionCompanyResponse>>> GetMovieProductionCompanies(int movieId)
        {
            try
            {
                var productionCompanies = await _movieService.GetMovieProductionCompaniesAsync(movieId);
                return Ok(productionCompanies);
            }
            catch (KeyNotFoundException)
            {
                return NotFound($"Movie with ID {movieId} not found");
            }
        }

        /// <summary>
        /// Assign a production company to a movie
        /// </summary>
        /// <param name="movieId">Movie ID</param>
        /// <param name="productionCompanyId">Production Company ID</param>
        /// <returns>Success status</returns>
        [HttpPost("{movieId}/production-companies/{productionCompanyId}")]
        public async Task<ActionResult> AssignProductionCompanyToMovie(int movieId, int productionCompanyId)
        {
            var success = await _movieService.AssignProductionCompanyToMovieAsync(movieId, productionCompanyId);
            
            if (!success)
                return BadRequest("Failed to assign production company to movie. Production company may already be assigned or movie/production company doesn't exist.");
            
            return Ok("Production company successfully assigned to movie");
        }

        /// <summary>
        /// Remove a production company from a movie
        /// </summary>
        /// <param name="movieId">Movie ID</param>
        /// <param name="productionCompanyId">Production Company ID</param>
        /// <returns>Success status</returns>
        [HttpDelete("{movieId}/production-companies/{productionCompanyId}")]
        public async Task<ActionResult> RemoveProductionCompanyFromMovie(int movieId, int productionCompanyId)
        {
            var success = await _movieService.RemoveProductionCompanyFromMovieAsync(movieId, productionCompanyId);
            
            if (!success)
                return NotFound("Production company assignment not found");
            
            return Ok("Production company successfully removed from movie");
        }

        /// <summary>
        /// Get a movie recommendation for a specific user based on their viewing history and preferences
        /// </summary>
        /// <param name="userId">User ID</param>
        /// <returns>Recommended movie</returns>
        [HttpGet("recommend/{userId}")]
        public ActionResult<MovieResponse> GetRecommendation(int userId)
        {
            try
            {
                var recommendation = _movieService.RecommendForUser(userId);
                return Ok(recommendation);
            }
            catch (InvalidOperationException ex)
            {
                return NotFound(ex.Message);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"An error occurred while generating recommendation: {ex.Message}");
            }
        }
    }
}
