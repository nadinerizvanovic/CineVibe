using System;

namespace CineVibe.Model.SearchObjects
{
    public class OrderSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public decimal? MinTotalAmount { get; set; }
        public decimal? MaxTotalAmount { get; set; }
        public DateTime? CreatedFrom { get; set; }
        public DateTime? CreatedTo { get; set; }
        public bool? IsActive { get; set; }
    }
}
