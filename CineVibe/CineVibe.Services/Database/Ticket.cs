using System;
using System.ComponentModel.DataAnnotations;

namespace CineVibe.Services.Database
{
    public class Ticket
    {
        [Key]
        public int Id { get; set; }
        
        public bool IsActive { get; set; } = true;
        
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        
        // Foreign keys
        [Required]
        public int SeatId { get; set; }
        
        [Required]
        public int ScreeningId { get; set; }
        
        [Required]
        public int UserId { get; set; }
        
        // Navigation properties
        public virtual Seat Seat { get; set; } = null!;
        public virtual Screening Screening { get; set; } = null!;
        public virtual User User { get; set; } = null!;
    }
}
