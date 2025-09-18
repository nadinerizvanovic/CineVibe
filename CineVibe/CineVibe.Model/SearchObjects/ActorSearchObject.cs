namespace CineVibe.Model.SearchObjects
{
    public class ActorSearchObject : BaseSearchObject
    {
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public string? FullName { get; set; }
        public bool? IsActive { get; set; }
    }
}
