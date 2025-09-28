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
        public DateTime? DateOfScreening { get; set; } // For filtering by specific screening date
        public bool? IsActive { get; set; }
        public string? MovieTitle { get; set; } // For searching by movie title
        public string? HallName { get; set; } // For searching by hall name
        public bool? IncludeSeats { get; set; } // Include seat information with tickets
    }
}
