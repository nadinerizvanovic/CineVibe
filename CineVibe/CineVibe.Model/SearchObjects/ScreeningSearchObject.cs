using System;

namespace CineVibe.Model.SearchObjects
{
    public class ScreeningSearchObject : BaseSearchObject
    {
        public int? MovieId { get; set; }
        public int? HallId { get; set; }
        public int? ScreeningTypeId { get; set; }
        public DateTime? StartTimeFrom { get; set; }
        public DateTime? StartTimeTo { get; set; }
        public DateTime? DateFrom { get; set; } // For filtering by date only
        public DateTime? DateTo { get; set; } // For filtering by date only
        public bool? IsActive { get; set; }
    }
}
