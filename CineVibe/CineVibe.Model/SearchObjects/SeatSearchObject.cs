namespace CineVibe.Model.SearchObjects
{
    public class SeatSearchObject : BaseSearchObject
    {
        public string? SeatNumber { get; set; }
        public int? HallId { get; set; }
        public int? SeatTypeId { get; set; }
        public bool? IsActive { get; set; }
    }
}
