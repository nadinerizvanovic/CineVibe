using System;

namespace CineVibe.Model.SearchObjects
{
    public class ReviewSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public int? ScreeningId { get; set; }
        public int? MovieId { get; set; }
        public int? HallId { get; set; }
        public int? MinRating { get; set; }
        public int? MaxRating { get; set; }
        public DateTime? ScreeningDateFrom { get; set; }
        public DateTime? ScreeningDateTo { get; set; }
        public bool? IsActive { get; set; }
        public string? MovieName { get; set; }
        public string? UserFullName { get; set; }
    }
}
