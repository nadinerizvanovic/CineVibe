using System;
using System.ComponentModel.DataAnnotations;

namespace CineVibe.Services.Database
{
    public class Review
    {
        [Key]
        public int Id { get; set; }
        
        [Required]
        [Range(1, 5, ErrorMessage = "Rating must be between 1 and 5")]
        public int Rating { get; set; }
        
        [MaxLength(1000)]
        public string? Comment { get; set; }
        
        public bool IsActive { get; set; } = true;
        
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        
        // Foreign keys
        [Required]
        public int ScreeningId { get; set; }
        
        [Required]
        public int UserId { get; set; }
        
        // Navigation properties
        public virtual Screening Screening { get; set; } = null!;
        public virtual User User { get; set; } = null!;
    }
}
