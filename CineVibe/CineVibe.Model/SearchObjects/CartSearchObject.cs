using System;

namespace CineVibe.Model.SearchObjects
{
    public class CartSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public bool? IsActive { get; set; }
        public DateTime? CreatedFrom { get; set; }
        public DateTime? CreatedTo { get; set; }
        public string? FTS { get; set; } // Full text search for user info
    }
}
