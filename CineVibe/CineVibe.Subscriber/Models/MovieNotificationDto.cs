using System;
using System.Collections.Generic;

namespace CineVibe.Subscriber.Models
{
    public class MovieNotificationDto
    {
        public string Title { get; set; } = null!;
        public string Description { get; set; } = null!;
        public DateTime ReleaseDate { get; set; }
        public string DirectorName { get; set; } = null!;
        public string GenreName { get; set; } = null!;
        public string CategoryName { get; set; } = null!;
        public List<string> UserEmails { get; set; } = new List<string>();
    }
}
