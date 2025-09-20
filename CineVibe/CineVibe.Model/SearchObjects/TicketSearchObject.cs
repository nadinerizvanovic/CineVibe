using System;

namespace CineVibe.Model.SearchObjects
{
    public class TicketSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public int? ScreeningId { get; set; }
        public int? MovieId { get; set; }
        public int? HallId { get; set; }
        public int? SeatId { get; set; }
        public DateTime? ScreeningDateFrom { get; set; }
        public DateTime? ScreeningDateTo { get; set; }
        public bool? IsActive { get; set; }
    }
}
