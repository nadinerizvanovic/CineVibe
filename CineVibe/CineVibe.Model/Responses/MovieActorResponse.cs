using System;

namespace CineVibe.Model.Responses
{
    public class MovieActorResponse
    {
        public int Id { get; set; }
        public int MovieId { get; set; }
        public int ActorId { get; set; }
        public DateTime DateAssigned { get; set; }
        public string MovieTitle { get; set; } = string.Empty;
        public string ActorFullName { get; set; } = string.Empty;
    }
}
