using Microsoft.EntityFrameworkCore;
using CineVibe.Services.Database;
using CineVibe.Services.Interfaces;
using CineVibe.Model.Responses;

namespace CineVibe.Services.Services
{
    public class AnalyticsService : IAnalyticsService
    {
        private readonly CineVibeDbContext _context;

        public AnalyticsService(CineVibeDbContext context)
        {
            _context = context;
        }

        public async Task<AnalyticsResponse> GetAnalyticsAsync()
        {
            var analytics = new AnalyticsResponse();

            // Get top 3 most sold products
            analytics.TopProducts = await GetTopProductsAsync();

            // Get top 3 most bought movies (by tickets)
            analytics.TopMovies = await GetTopMoviesAsync();

            // Calculate total revenue from tickets
            analytics.TicketRevenue = await GetTicketRevenueAsync();

            // Calculate total revenue from products
            analytics.ProductRevenue = await GetProductRevenueAsync();

            // Get best average reviewed movie
            analytics.BestReviewedMovie = await GetBestReviewedMovieAsync();

            // Get user with most bought tickets
            analytics.TopCustomer = await GetTopCustomerAsync();

            return analytics;
        }

        private async Task<List<TopProductResponse>> GetTopProductsAsync()
        {
            return await _context.OrderItems
                .Include(oi => oi.Product)
                .Where(oi => oi.Product.IsActive)
                .GroupBy(oi => new { oi.ProductId, oi.Product.Name })
                .Select(g => new TopProductResponse
                {
                    ProductId = g.Key.ProductId,
                    ProductName = g.Key.Name,
                    TotalQuantitySold = g.Sum(oi => oi.Quantity),
                    TotalRevenue = g.Sum(oi => oi.TotalPrice)
                })
                .OrderByDescending(p => p.TotalQuantitySold)
                .Take(3)
                .ToListAsync();
        }

        private async Task<List<TopMovieResponse>> GetTopMoviesAsync()
        {
            return await _context.Tickets
                .Include(t => t.Screening)
                .ThenInclude(s => s.Movie)
                .Where(t => t.Screening.Movie.IsActive)
                .GroupBy(t => new { t.Screening.MovieId, t.Screening.Movie.Title })
                .Select(g => new TopMovieResponse
                {
                    MovieId = g.Key.MovieId,
                    MovieTitle = g.Key.Title,
                    TotalTicketsSold = g.Count(),
                    TotalRevenue = g.Count() * 15.0m // Assuming average ticket price of $15
                })
                .OrderByDescending(m => m.TotalTicketsSold)
                .Take(3)
                .ToListAsync();
        }

        private async Task<decimal> GetTicketRevenueAsync()
        {
            // Since tickets don't have individual prices, we'll calculate based on seat types
            // For simplicity, we'll use a base price calculation
            var ticketCount = await _context.Tickets.CountAsync();
            return ticketCount * 15.0m; // Assuming average ticket price of $15
        }

        private async Task<decimal> GetProductRevenueAsync()
        {
            return await _context.OrderItems
                .SumAsync(oi => oi.TotalPrice);
        }

        private async Task<BestReviewedMovieResponse?> GetBestReviewedMovieAsync()
        {
            var bestMovie = await _context.Reviews
                .Include(r => r.Screening)
                .ThenInclude(s => s.Movie)
                .Where(r => r.Screening.Movie.IsActive)
                .GroupBy(r => new { r.Screening.MovieId, r.Screening.Movie.Title, r.Screening.Movie.Poster })
                .Select(g => new BestReviewedMovieResponse
                {
                    MovieId = g.Key.MovieId,
                    MovieTitle = g.Key.Title,
                    Poster = g.Key.Poster,
                    AverageRating = g.Average(r => r.Rating),
                    TotalReviews = g.Count()
                })
                .Where(m => m.TotalReviews >= 1) // At least 1 review
                .OrderByDescending(m => m.AverageRating)
                .ThenByDescending(m => m.TotalReviews)
                .FirstOrDefaultAsync();

            return bestMovie;
        }

        private async Task<TopCustomerResponse?> GetTopCustomerAsync()
        {
            var topCustomer = await _context.Tickets
                .Include(t => t.User)
                .GroupBy(t => new { t.UserId, t.User.FirstName, t.User.LastName, t.User.Username, t.User.Picture })
                .Select(g => new TopCustomerResponse
                {
                    UserId = g.Key.UserId,
                    FirstName = g.Key.FirstName,
                    LastName = g.Key.LastName,
                    Username = g.Key.Username,
                    Picture = g.Key.Picture,
                    TotalTicketsPurchased = g.Count()
                })
                .OrderByDescending(c => c.TotalTicketsPurchased)
                .FirstOrDefaultAsync();

            return topCustomer;
        }
    }
}
