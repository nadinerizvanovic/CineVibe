using System;

namespace CineVibe.Model.SearchObjects
{
    public class MovieSearchObject : BaseSearchObject
    {
        public string? Title { get; set; }
        public DateTime? ReleaseDateFrom { get; set; }
        public DateTime? ReleaseDateTo { get; set; }
        public int? MinDuration { get; set; }
        public int? MaxDuration { get; set; }
        public bool? IsActive { get; set; }
        public int? CategoryId { get; set; }
        public int? GenreId { get; set; }
        public int? DirectorId { get; set; }
        public int? ActorId { get; set; } // Filter movies by specific actor
        public int? ProductionCompanyId { get; set; } // Filter movies by specific production company
    }
}
