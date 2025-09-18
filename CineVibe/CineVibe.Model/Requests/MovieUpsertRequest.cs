using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace CineVibe.Model.Requests
{
    public class MovieUpsertRequest
    {
        [Required]
        [MaxLength(200)]
        public string Title { get; set; } = string.Empty;
        
        [Required]
        public DateTime ReleaseDate { get; set; }
        
        [MaxLength(1000)]
        public string? Description { get; set; }
        
        [Required]
        [Range(1, int.MaxValue, ErrorMessage = "Duration must be greater than 0")]
        public int Duration { get; set; }
        
        [MaxLength(500)]
        public string? Trailer { get; set; }
        
        public byte[]? Poster { get; set; }
        
        public bool IsActive { get; set; } = true;
        
        public List<int>? ActorIds { get; set; } // For managing movie-actor relationships
    }
}
