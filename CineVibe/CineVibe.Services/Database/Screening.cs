using System;
using System.ComponentModel.DataAnnotations;

namespace CineVibe.Services.Database
{
    public class Screening
    {
        [Key]
        public int Id { get; set; }
        
        [Required]
        public DateTime StartTime { get; set; }
        
        public bool IsActive { get; set; } = true;
        
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        
        // Foreign keys
        [Required]
        public int MovieId { get; set; }
        
        [Required]
        public int HallId { get; set; }
        
        [Required]
        public int ScreeningTypeId { get; set; }
        
        // Navigation properties
        public virtual Movie Movie { get; set; } = null!;
        public virtual Hall Hall { get; set; } = null!;
        public virtual ScreeningType ScreeningType { get; set; } = null!;
    }
}
