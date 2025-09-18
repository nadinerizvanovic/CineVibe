using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CineVibe.Services.Database
{
    public class MovieActor
    {
        [Key]
        public int Id { get; set; }
        
        [Required]
        public int MovieId { get; set; }
        
        [Required]
        public int ActorId { get; set; }
        
        public DateTime DateAssigned { get; set; } = DateTime.Now;
        
        // Navigation properties
        [ForeignKey("MovieId")]
        public virtual Movie Movie { get; set; } = null!;
        
        [ForeignKey("ActorId")]
        public virtual Actor Actor { get; set; } = null!;
    }
}
