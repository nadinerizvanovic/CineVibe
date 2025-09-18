using System;
using System.ComponentModel.DataAnnotations;

namespace CineVibe.Model.Requests
{
    public class DirectorUpsertRequest
    {
        [Required]
        [MaxLength(100)]
        public string FirstName { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(100)]
        public string LastName { get; set; } = string.Empty;
        
        
        public bool IsActive { get; set; } = true;
    }
}
