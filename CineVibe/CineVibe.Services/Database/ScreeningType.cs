using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace CineVibe.Services.Database
{
    public class ScreeningType
    {
        [Key]
        public int Id { get; set; }
        
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;
        
        [MaxLength(500)]
        public string? Description { get; set; }
        
        public bool IsActive { get; set; } = true;
        
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        
        // Navigation properties
        public virtual ICollection<Screening> Screenings { get; set; } = new List<Screening>();
    }
}
