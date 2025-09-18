using System.ComponentModel.DataAnnotations;

namespace CineVibe.Model.Requests
{
    public class ActorUpsertRequest
    {
        [Required]
        [MaxLength(50)]
        public string FirstName { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(50)]
        public string LastName { get; set; } = string.Empty;
        
        public bool IsActive { get; set; } = true;
    }
}
