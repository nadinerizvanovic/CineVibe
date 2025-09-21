using System;
using System.ComponentModel.DataAnnotations;

namespace CineVibe.Model.Requests
{
    public class CartUpsertRequest
    {
        [Required]
        public int UserId { get; set; }
        
        public DateTime? ExpiresAt { get; set; }
        
        public bool IsActive { get; set; } = true;
    }
}
