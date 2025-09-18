using System;
using System.ComponentModel.DataAnnotations;

namespace CineVibe.Services.Database
{
    public class MovieProductionCompany
    {
        [Key]
        public int Id { get; set; }
        
        [Required]
        public int MovieId { get; set; }
        
        [Required]
        public int ProductionCompanyId { get; set; }
        
        public DateTime DateAssigned { get; set; } = DateTime.Now;
    
        
        // Navigation properties
        public virtual Movie Movie { get; set; } = null!;
        public virtual ProductionCompany ProductionCompany { get; set; } = null!;
    }
}
