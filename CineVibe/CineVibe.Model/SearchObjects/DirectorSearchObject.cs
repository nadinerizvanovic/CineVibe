using System;

namespace CineVibe.Model.SearchObjects
{
    public class DirectorSearchObject : BaseSearchObject
    {
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public string? FullName { get; set; }
        public string? Nationality { get; set; }
        public bool? IsActive { get; set; }
    }
}
