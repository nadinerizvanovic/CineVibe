using System;

namespace CineVibe.Model.Responses
{
    public class HallResponse
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public bool IsActive { get; set; }
        public DateTime CreatedAt { get; set; }
        public int SeatCount { get; set; } // Number of seats in this hall
    }
}
