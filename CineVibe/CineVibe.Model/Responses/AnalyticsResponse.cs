using System.Collections.Generic;

namespace CineVibe.Model.Responses
{
    public class AnalyticsResponse
    {
        public List<TopProductResponse> TopProducts { get; set; } = new List<TopProductResponse>();
        public List<TopMovieResponse> TopMovies { get; set; } = new List<TopMovieResponse>();
        public decimal TicketRevenue { get; set; }
        public decimal ProductRevenue { get; set; }
        public BestReviewedMovieResponse? BestReviewedMovie { get; set; }
        public TopCustomerResponse? TopCustomer { get; set; }
    }

    public class TopProductResponse
    {
        public int ProductId { get; set; }
        public string ProductName { get; set; } = string.Empty;
        public int TotalQuantitySold { get; set; }
        public decimal TotalRevenue { get; set; }
    }

    public class TopMovieResponse
    {
        public int MovieId { get; set; }
        public string MovieTitle { get; set; } = string.Empty;
        public int TotalTicketsSold { get; set; }
        public decimal TotalRevenue { get; set; }
    }

    public class BestReviewedMovieResponse
    {
        public int MovieId { get; set; }
        public byte[]? Poster { get; set; }
        public string MovieTitle { get; set; } = string.Empty;
        public double AverageRating { get; set; }
        public int TotalReviews { get; set; }
    }

    public class TopCustomerResponse
    {
        public int UserId { get; set; }
        public byte[]? Picture { get; set; }
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string Username { get; set; } = string.Empty;
        public int TotalTicketsPurchased { get; set; }
    }
}
