using System;
using System.ComponentModel.DataAnnotations;

namespace CineVibe.Services.Database
{
    public class Seat
    {
        [Key]
        public int Id { get; set; }
        
        [Required]
        [MaxLength(10)]
        public string SeatNumber { get; set; } = string.Empty;
        
        public bool IsActive { get; set; } = true;
        
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        
        // Foreign keys
        [Required]
        public int HallId { get; set; }
        
        public int? SeatTypeId { get; set; } // Optional as mentioned
        
        // Navigation properties
        public virtual Hall Hall { get; set; } = null!;
        public virtual SeatType? SeatType { get; set; }
    }
}
