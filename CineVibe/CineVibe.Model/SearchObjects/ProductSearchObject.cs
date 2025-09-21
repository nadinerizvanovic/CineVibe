namespace CineVibe.Model.SearchObjects
{
    public class ProductSearchObject : BaseSearchObject
    {
        public string? Name { get; set; }
        public decimal? MinPrice { get; set; }
        public decimal? MaxPrice { get; set; }
        public bool? IsActive { get; set; }
    }
}
