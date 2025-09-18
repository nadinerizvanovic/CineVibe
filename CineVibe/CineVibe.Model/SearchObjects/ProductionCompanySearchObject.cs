using System;

namespace CineVibe.Model.SearchObjects
{
    public class ProductionCompanySearchObject : BaseSearchObject
    {
        public string? Name { get; set; }
        public string? Country { get; set; }
        public bool? IsActive { get; set; }
    }
}
