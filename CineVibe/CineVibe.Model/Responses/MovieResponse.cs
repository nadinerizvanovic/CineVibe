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
        public int CategoryId { get; set; }
        public string CategoryName { get; set; } = string.Empty;
        public int GenreId { get; set; }
        public string GenreName { get; set; } = string.Empty;
        public int DirectorId { get; set; }
        public string DirectorName { get; set; } = string.Empty;
        public List<ActorResponse> Actors { get; set; } = new List<ActorResponse>();
        public List<ProductionCompanyResponse> ProductionCompanies { get; set; } = new List<ProductionCompanyResponse>();
        public int ActorCount { get; set; } // Number of actors in this movie
        public int ProductionCompanyCount { get; set; } // Number of production companies
    }
}
