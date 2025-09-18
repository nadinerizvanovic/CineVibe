using System.ComponentModel.DataAnnotations;

namespace CineVibe.Model.Requests
{
    public class SeatUpsertRequest
    {
        [Required]
        [MaxLength(10)]
        public string SeatNumber { get; set; } = string.Empty;
        
        public bool IsActive { get; set; } = true;
        
        [Required]
        public int HallId { get; set; }
        
        public int? SeatTypeId { get; set; }
    }
}
