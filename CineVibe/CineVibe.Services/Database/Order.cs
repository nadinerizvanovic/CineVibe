using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace CineVibe.Services.Database
{
    public class Order
    {
        [Key]
        public int Id { get; set; }
        
        [Required]
        public decimal TotalAmount { get; set; }
        
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        
        public bool IsActive { get; set; } = true;
        
        // Foreign keys
        [Required]
        public int UserId { get; set; }
        
        // Navigation properties
        public virtual User User { get; set; } = null!;
        public virtual ICollection<OrderItem> OrderItems { get; set; } = new List<OrderItem>();
    }
}
