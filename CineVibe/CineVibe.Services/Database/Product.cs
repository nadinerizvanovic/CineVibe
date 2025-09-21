using System;
using System.ComponentModel.DataAnnotations;

namespace CineVibe.Services.Database
{
    public class Product
    {
        [Key]
        public int Id { get; set; }
        
        [Required]
        [MaxLength(200)]
        public string Name { get; set; } = string.Empty;
        
        [Required]
        public decimal Price { get; set; }
        
        public byte[]? Picture { get; set; }
        
        public bool IsActive { get; set; } = true;
        
        public DateTime CreatedAt { get; set; } = DateTime.Now;
    }
}
