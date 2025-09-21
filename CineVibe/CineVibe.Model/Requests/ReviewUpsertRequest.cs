using System.ComponentModel.DataAnnotations;

namespace CineVibe.Model.Requests
{
    public class ReviewUpsertRequest
    {
        [Required]
        [Range(1, 5, ErrorMessage = "Rating must be between 1 and 5")]
        public int Rating { get; set; }
        
        [MaxLength(1000)]
        public string? Comment { get; set; }
        
        public bool IsActive { get; set; } = true;
        
        [Required]
        public int ScreeningId { get; set; }
        
        [Required]
        public int UserId { get; set; }
    }
}
