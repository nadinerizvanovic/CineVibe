using System.ComponentModel.DataAnnotations;

namespace CineVibe.Model.Requests
{
    public class TicketUpsertRequest
    {
        public bool IsActive { get; set; } = true;
        
        [Required]
        public int SeatId { get; set; }
        
        [Required]
        public int ScreeningId { get; set; }
        
        [Required]
        public int UserId { get; set; }
    }
}
