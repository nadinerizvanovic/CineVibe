using CineVibe.Model.Responses;

namespace CineVibe.Services.Interfaces
{
    public interface IAnalyticsService
    {
        Task<AnalyticsResponse> GetAnalyticsAsync();
    }
}
