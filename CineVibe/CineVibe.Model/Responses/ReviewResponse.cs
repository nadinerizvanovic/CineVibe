using System;

namespace CineVibe.Model.Responses
{
    public class ReviewResponse
    {
        public int Id { get; set; }
        public int Rating { get; set; }
        public string? Comment { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedAt { get; set; }
        public int ScreeningId { get; set; }
        public DateTime ScreeningStartTime { get; set; }
        public int MovieId { get; set; }
        public string MovieTitle { get; set; } = string.Empty;
        public string HallName { get; set; } = string.Empty;
        public string ScreeningTypeName { get; set; } = string.Empty;
        public int UserId { get; set; }
        public string UserFullName { get; set; } = string.Empty;
        public byte[] MoviePoster { get; set; } = Array.Empty<byte>();
    }
}
