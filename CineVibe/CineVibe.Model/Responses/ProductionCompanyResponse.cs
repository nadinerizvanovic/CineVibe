using System;

namespace CineVibe.Model.Responses
{
    public class ProductionCompanyResponse
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string? Country { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedAt { get; set; }
        public int MovieCount { get; set; } // Number of movies produced
    }
}
