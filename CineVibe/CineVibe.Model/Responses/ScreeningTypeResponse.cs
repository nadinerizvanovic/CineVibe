using System;

namespace CineVibe.Model.Responses
{
    public class ScreeningTypeResponse
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedAt { get; set; }
        public int ScreeningCount { get; set; } // Number of screenings with this type
    }
}
