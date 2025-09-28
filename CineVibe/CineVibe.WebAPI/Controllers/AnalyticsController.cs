using Microsoft.AspNetCore.Mvc;
using CineVibe.Services.Interfaces;
using CineVibe.Model.Responses;

namespace CineVibe.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class AnalyticsController : ControllerBase
    {
        private readonly IAnalyticsService _analyticsService;

        public AnalyticsController(IAnalyticsService analyticsService)
        {
            _analyticsService = analyticsService;
        }

        /// <summary>
        /// Get comprehensive analytics data including top products, movies, revenue, and customer insights
        /// </summary>
        /// <returns>AnalyticsResponse containing all analytics data</returns>
        [HttpGet]
        public async Task<ActionResult<AnalyticsResponse>> GetAnalytics()
        {
            try
            {
                var analytics = await _analyticsService.GetAnalyticsAsync();
                return Ok(analytics);
            }
            catch (Exception ex)
            {
                return BadRequest($"Error retrieving analytics: {ex.Message}");
            }
        }
    }
}
