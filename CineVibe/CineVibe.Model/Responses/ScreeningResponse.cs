using System;

namespace CineVibe.Model.Responses
{
    public class ScreeningResponse
    {
        public int Id { get; set; }
        public DateTime StartTime { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedAt { get; set; }
        public int MovieId { get; set; }
        public string MovieTitle { get; set; } = string.Empty;
        public int MovieDuration { get; set; } // For calculating end time
        public int HallId { get; set; }
        public string HallName { get; set; } = string.Empty;
        public int ScreeningTypeId { get; set; }
        public string ScreeningTypeName { get; set; } = string.Empty;
        public decimal Price { get; set; } // Price from ScreeningType
        public DateTime EndTime => StartTime.AddMinutes(MovieDuration); // Calculated property
        public int OccupiedSeatsCount { get; set; } // Number of occupied seats
    }
}
