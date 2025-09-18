using System;

namespace CineVibe.Model.SearchObjects
{
    public class MovieActorSearchObject : BaseSearchObject
    {
        public int? MovieId { get; set; }
        public int? ActorId { get; set; }
        public DateTime? DateAssignedFrom { get; set; }
        public DateTime? DateAssignedTo { get; set; }
    }
}
