using System;
using System.ComponentModel.DataAnnotations;

namespace CineVibe.Model.Requests
{
    public class ScreeningUpsertRequest
    {
        [Required]
        public DateTime StartTime { get; set; }
        
        public bool IsActive { get; set; } = true;
        
        [Required]
        public int MovieId { get; set; }
        
        [Required]
        public int HallId { get; set; }
        
        [Required]
        public int ScreeningTypeId { get; set; }
    }
}
