using System;
using System.Collections.Generic;

namespace CineVibe.Model.Responses
{
    public class MovieResponse
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public DateTime ReleaseDate { get; set; }
        public string? Description { get; set; }
        public int Duration { get; set; }
        public string? Trailer { get; set; }
        public byte[]? Poster { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedAt { get; set; }
        public List<ActorResponse> Actors { get; set; } = new List<ActorResponse>();
        public int ActorCount { get; set; } // Number of actors in this movie
    }
}
