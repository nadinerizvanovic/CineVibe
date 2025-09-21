using System;
using System.Collections.Generic;

namespace CineVibe.Model.Responses
{
    public class OrderResponse
    {
        public int Id { get; set; }
        public decimal TotalAmount { get; set; }
        public DateTime CreatedAt { get; set; }
        public bool IsActive { get; set; }
        public int UserId { get; set; }
        public string UserFullName { get; set; } = string.Empty;
        public List<OrderItemResponse> OrderItems { get; set; } = new List<OrderItemResponse>();
        public int TotalItems => OrderItems.Count;
    }
}
