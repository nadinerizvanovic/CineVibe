using System;
using System.ComponentModel.DataAnnotations;

namespace CineVibe.Model.Requests
{
    public class ProductionCompanyUpsertRequest
    {
        [Required]
        [MaxLength(200)]
        public string Name { get; set; } = string.Empty;
        
        [MaxLength(1000)]
        public string? Description { get; set; }

        
        [MaxLength(100)]
        public string? Country { get; set; }
        
        public bool IsActive { get; set; } = true;
    }
}
