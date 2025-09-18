using System.ComponentModel.DataAnnotations;

namespace CineVibe.Model.Requests
{
    public class MovieActorUpsertRequest
    {
        [Required]
        public int MovieId { get; set; }
        
        [Required]
        public int ActorId { get; set; }
    }
}
