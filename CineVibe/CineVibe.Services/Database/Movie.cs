using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace CineVibe.Services.Database
{
    public class Movie
    {
        [Key]
        public int Id { get; set; }
        
        [Required]
        [MaxLength(200)]
        public string Title { get; set; } = string.Empty;
        
        public DateTime ReleaseDate { get; set; }
        
        [MaxLength(1000)]
        public string? Description { get; set; }
        
        public int Duration { get; set; } // Duration in minutes
        
        [MaxLength(500)]
        public string? Trailer { get; set; } // URL to trailer
        
        public byte[]? Poster { get; set; } // Movie poster image
        
        public bool IsActive { get; set; } = true;
        
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        
        // Foreign keys
        public int CategoryId { get; set; }
        public int GenreId { get; set; }
        public int DirectorId { get; set; }
        
        // Navigation properties
        public virtual Category Category { get; set; } = null!;
        public virtual Genre Genre { get; set; } = null!;
        public virtual Director Director { get; set; } = null!;
        public virtual ICollection<MovieActor> MovieActors { get; set; } = new List<MovieActor>();
        public virtual ICollection<MovieProductionCompany> MovieProductionCompanies { get; set; } = new List<MovieProductionCompany>();
    }
}
