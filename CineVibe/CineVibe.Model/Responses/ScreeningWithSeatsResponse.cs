using System;
using System.Collections.Generic;

namespace CineVibe.Model.Responses
{
    public class ScreeningWithSeatsResponse
    {
        public int Id { get; set; }
        public DateTime StartTime { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedAt { get; set; }
        public int MovieId { get; set; }
        public string MovieTitle { get; set; } = string.Empty;
        public int MovieDuration { get; set; }
        public int HallId { get; set; }
        public string HallName { get; set; } = string.Empty;
        public int ScreeningTypeId { get; set; }
        public string ScreeningTypeName { get; set; } = string.Empty;
        public decimal Price { get; set; }
        public DateTime EndTime => StartTime.AddMinutes(MovieDuration);
        public List<SeatWithTicketInfo> Seats { get; set; } = new List<SeatWithTicketInfo>();
    }

    public class SeatWithTicketInfo
    {
        public int Id { get; set; }
        public string SeatNumber { get; set; } = string.Empty;
        public bool IsActive { get; set; }
        public int HallId { get; set; }
        public int? SeatTypeId { get; set; }
        public string? SeatTypeName { get; set; }
        public bool IsOccupied { get; set; }
        public int? TicketId { get; set; }
        public string? UserFullName { get; set; }
    }
}
