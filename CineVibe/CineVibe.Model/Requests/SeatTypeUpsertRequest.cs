using System.ComponentModel.DataAnnotations;

namespace CineVibe.Model.Requests
{
    public class SeatTypeUpsertRequest
    {
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;
        
        public bool IsActive { get; set; } = true;
    }
}
