using System;

namespace CineVibe.Model.Responses
{
    public class ActorResponse
    {
        public int Id { get; set; }
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string FullName => $"{FirstName} {LastName}";
        public bool IsActive { get; set; }
        public DateTime CreatedAt { get; set; }
        public int MovieCount { get; set; } // Number of movies this actor appears in
    }
}
