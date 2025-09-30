using System;

namespace CineVibe.Model.Responses
{
    public class TicketResponse
    {
        public int Id { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedAt { get; set; }
        public int SeatId { get; set; }
        public string SeatNumber { get; set; } = string.Empty;
        public int ScreeningId { get; set; }
        public DateTime ScreeningStartTime { get; set; }
        public string MovieTitle { get; set; } = string.Empty;
        public string HallName { get; set; } = string.Empty;
        public string ScreeningTypeName { get; set; } = string.Empty;
        public int UserId { get; set; }
        public string UserFullName { get; set; } = string.Empty;
        public byte[] MoviePoster { get; set; } = Array.Empty<byte>();
    }
}
