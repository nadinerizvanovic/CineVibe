using System;

namespace CineVibe.Model.Responses
{
    public class SeatResponse
    {
        public int Id { get; set; }
        public string SeatNumber { get; set; } = string.Empty;
        public bool IsActive { get; set; }
        public DateTime CreatedAt { get; set; }
        public int HallId { get; set; }
        public string HallName { get; set; } = string.Empty;
        public int? SeatTypeId { get; set; }
        public string? SeatTypeName { get; set; }
    }
}
