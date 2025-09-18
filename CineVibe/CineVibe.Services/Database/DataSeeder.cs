using CineVibe.Services.Helpers;
using Microsoft.EntityFrameworkCore;
using System;

namespace CineVibe.Services.Database
{
    public static class DataSeeder
    {
        private const string DefaultPhoneNumber = "+387 00 000 000";
        
        private const string TestMailSender = "sender@gmail.com";
        private const string TestMailReceiver = "receiver@gmail.com";

        public static void SeedData(this ModelBuilder modelBuilder)
        {
            // Use a fixed date for all timestamps
            var fixedDate = new DateTime(2025, 10, 10, 0, 0, 0, DateTimeKind.Utc);

            // Seed Roles
            modelBuilder.Entity<Role>().HasData(
                new Role 
                { 
                    Id = 1, 
                    Name = "Administrator", 
                    Description = "System administrator with full access", 
                    CreatedAt = fixedDate, 
                    IsActive = true 
                },
                new Role 
                { 
                    Id = 2, 
                    Name = "User", 
                    Description = "Regular user role", 
                    CreatedAt = fixedDate, 
                    IsActive = true 
                }
            );

            // Seed Users
            modelBuilder.Entity<User>().HasData(
                new User 
                {
                    Id = 1,
                    FirstName = "Denis",
                    LastName = "Mušić",
                    Email = TestMailReceiver,
                    Username = "admin",
                    PasswordHash = "3KbrBi5n9zdQnceWWOK5zaeAwfEjsluyhRQUbNkcgLQ=",
                    PasswordSalt = "6raKZCuEsvnBBxPKHGpRtA==",
                    IsActive = true,
                    CreatedAt = fixedDate,
                    PhoneNumber = DefaultPhoneNumber,
                    GenderId = 1, // Male
                    CityId = 5, // Sarajevo
                    Picture = ImageConversion.ConvertImageToByteArray("Assets", "denis.png")
                },
                new User 
                { 
                    Id = 2, 
                    FirstName = "Amel", 
                    LastName = "Musić",
                    Email = "example1@gmail.com",
                    Username = "user", 
                    PasswordHash = "kDPVcZaikiII7vXJbMEw6B0xZ245I29ocaxBjLaoAC0=", 
                    PasswordSalt = "O5R9WmM6IPCCMci/BCG/eg==", 
                    IsActive = true, 
                    CreatedAt = fixedDate,
                    PhoneNumber = DefaultPhoneNumber,
                    GenderId = 1, // Male
                    CityId = 5, // Mostar
                    Picture = ImageConversion.ConvertImageToByteArray("Assets", "amel.png")
                },
                new User 
                { 
                    Id = 3, 
                    FirstName = "Adil", 
                    LastName = "Joldić",
                    Email = "example2@gmail.com",
                    Username = "admin2", 
                    PasswordHash = "BiWDuil9svAKOYzii5wopQW3YqjVfQrzGE2iwH/ylY4=", 
                    PasswordSalt = "pfNS+OLBaQeGqBIzXXcWuA==", 
                    IsActive = true, 
                    CreatedAt = fixedDate,
                    PhoneNumber = DefaultPhoneNumber,
                    GenderId = 1, // Male
                    CityId = 3, // Tuzla
                    Picture = ImageConversion.ConvertImageToByteArray("Assets", "adil.png")
                },
                new User 
                { 
                    Id = 4, 
                    FirstName = "Nadine", 
                    LastName = "Rizvanović", 
                    Email = TestMailSender, 
                    Username = "user2", 
                    PasswordHash = "KUF0Jsocq9AqdwR9JnT2OrAqm5gDj7ecQvNwh6fW/Bs=", 
                    PasswordSalt = "c3ZKo0va3tYfnYuNKkHDbQ==", 
                    IsActive = true, 
                    CreatedAt = fixedDate,
                    PhoneNumber = DefaultPhoneNumber,
                    GenderId = 2, // Female
                    CityId = 1, // Sarajevo
                    //Picture = ImageConversion.ConvertImageToByteArray("Assets", "test.png")
                }
            );

            // Seed UserRoles
            modelBuilder.Entity<UserRole>().HasData(
                new UserRole { Id = 1, UserId = 1, RoleId = 1, DateAssigned = fixedDate }, 
                new UserRole { Id = 2, UserId = 2, RoleId = 1, DateAssigned = fixedDate }, 
                new UserRole { Id = 3, UserId = 3, RoleId = 2, DateAssigned = fixedDate }, 
                new UserRole { Id = 4, UserId = 4, RoleId = 2, DateAssigned = fixedDate }  
            );

            // Seed Genders
            modelBuilder.Entity<Gender>().HasData(
                new Gender { Id = 1, Name = "Male" },
                new Gender { Id = 2, Name = "Female" }
            );

            // Seed Cities
            modelBuilder.Entity<City>().HasData(
                new City { Id = 1, Name = "Sarajevo" },
                new City { Id = 2, Name = "Banja Luka" },
                new City { Id = 3, Name = "Tuzla" },
                new City { Id = 4, Name = "Zenica" },
                new City { Id = 5, Name = "Mostar" },
                new City { Id = 6, Name = "Bijeljina" },
                new City { Id = 7, Name = "Prijedor" },
                new City { Id = 8, Name = "Brčko" },
                new City { Id = 9, Name = "Doboj" },
                new City { Id = 10, Name = "Zvornik" }
            );

            // Seed Actors
            modelBuilder.Entity<Actor>().HasData(
                // Fantastic Four: First Steps actors
                new Actor { Id = 1, FirstName = "Pedro", LastName = "Pascal", IsActive = true, CreatedAt = fixedDate },
                new Actor { Id = 2, FirstName = "Vanessa", LastName = "Kirby", IsActive = true, CreatedAt = fixedDate },
                new Actor { Id = 3, FirstName = "Joseph", LastName = "Quinn", IsActive = true, CreatedAt = fixedDate },
                new Actor { Id = 4, FirstName = "Ebon", LastName = "Moss-Bachrach", IsActive = true, CreatedAt = fixedDate },
                
                // Superman (2025) actors
                new Actor { Id = 5, FirstName = "David", LastName = "Corenswet", IsActive = true, CreatedAt = fixedDate },
                new Actor { Id = 6, FirstName = "Rachel", LastName = "Brosnahan", IsActive = true, CreatedAt = fixedDate },
                new Actor { Id = 7, FirstName = "Nicholas", LastName = "Hoult", IsActive = true, CreatedAt = fixedDate },
                
                // F1 Movie (2025) actors
                new Actor { Id = 8, FirstName = "Brad", LastName = "Pitt", IsActive = true, CreatedAt = fixedDate },
                new Actor { Id = 9, FirstName = "Damson", LastName = "Idris", IsActive = true, CreatedAt = fixedDate },
                new Actor { Id = 10, FirstName = "Kerry", LastName = "Condon", IsActive = true, CreatedAt = fixedDate },
                
                // Elio actors
                new Actor { Id = 11, FirstName = "Yonas", LastName = "Kibreab", IsActive = true, CreatedAt = fixedDate },
                new Actor { Id = 12, FirstName = "Zoe", LastName = "Saldana", IsActive = true, CreatedAt = fixedDate },
                
                // Spider-Man: Brand New Day actors
                new Actor { Id = 13, FirstName = "Tom", LastName = "Holland", IsActive = true, CreatedAt = fixedDate },
                new Actor { Id = 14, FirstName = "Zendaya", LastName = "Coleman", IsActive = true, CreatedAt = fixedDate },
                new Actor { Id = 15, FirstName = "Jacob", LastName = "Batalon", IsActive = true, CreatedAt = fixedDate },
                
                // Avatar: Fire and Ash actors
                new Actor { Id = 16, FirstName = "Sam", LastName = "Worthington", IsActive = true, CreatedAt = fixedDate },
                new Actor { Id = 17, FirstName = "Zoe", LastName = "Saldana", IsActive = true, CreatedAt = fixedDate },
                new Actor { Id = 18, FirstName = "Sigourney", LastName = "Weaver", IsActive = true, CreatedAt = fixedDate },
                new Actor { Id = 19, FirstName = "Kate", LastName = "Winslet", IsActive = true, CreatedAt = fixedDate },
                
                // Titanic actors
                new Actor { Id = 20, FirstName = "Leonardo", LastName = "DiCaprio", IsActive = true, CreatedAt = fixedDate },
                new Actor { Id = 21, FirstName = "Kate", LastName = "Winslet", IsActive = true, CreatedAt = fixedDate },
                new Actor { Id = 22, FirstName = "Billy", LastName = "Zane", IsActive = true, CreatedAt = fixedDate },
                new Actor { Id = 23, FirstName = "Gloria", LastName = "Stuart", IsActive = true, CreatedAt = fixedDate },
                
                // Cast Away actors
                new Actor { Id = 24, FirstName = "Tom", LastName = "Hanks", IsActive = true, CreatedAt = fixedDate },
                new Actor { Id = 25, FirstName = "Helen", LastName = "Hunt", IsActive = true, CreatedAt = fixedDate },
                
                // Additional actors for variety
                new Actor { Id = 26, FirstName = "Robert", LastName = "Downey Jr.", IsActive = true, CreatedAt = fixedDate },
                new Actor { Id = 27, FirstName = "Scarlett", LastName = "Johansson", IsActive = true, CreatedAt = fixedDate },
                new Actor { Id = 28, FirstName = "Chris", LastName = "Evans", IsActive = true, CreatedAt = fixedDate },
                new Actor { Id = 29, FirstName = "Ryan", LastName = "Reynolds", IsActive = true, CreatedAt = fixedDate },
                new Actor { Id = 30, FirstName = "Emma", LastName = "Stone", IsActive = true, CreatedAt = fixedDate }
            );

            // Seed Movies
            modelBuilder.Entity<Movie>().HasData(
                new Movie 
                { 
                    Id = 1, 
                    Title = "Fantastic Four: First Steps", 
                    ReleaseDate = new DateTime(2025, 7, 25), 
                    Description = "The first family of superheroes, the Fantastic Four, gain their powers and learn to work together to stop the world-devouring Galactus.",
                    Duration = 125, 
                    IsActive = true, 
                    CreatedAt = fixedDate 
                },
                new Movie 
                { 
                    Id = 2, 
                    Title = "Superman", 
                    ReleaseDate = new DateTime(2025, 7, 11), 
                    Description = "Superman navigates his dual identity as Clark Kent and the Man of Steel, while facing new challenges in Metropolis.",
                    Duration = 140, 
                    IsActive = true, 
                    CreatedAt = fixedDate 
                },
                new Movie 
                { 
                    Id = 3, 
                    Title = "F1", 
                    ReleaseDate = new DateTime(2025, 6, 27), 
                    Description = "A seasoned Formula 1 driver comes out of retirement to mentor a young rookie and compete at the highest level of motorsport.",
                    Duration = 130, 
                    IsActive = true, 
                    CreatedAt = fixedDate 
                },
                new Movie 
                { 
                    Id = 4, 
                    Title = "Elio", 
                    ReleaseDate = new DateTime(2025, 6, 13), 
                    Description = "A young boy with an active imagination accidentally becomes Earth's intergalactic representative and must navigate alien politics.",
                    Duration = 100, 
                    IsActive = true, 
                    CreatedAt = fixedDate 
                },
                new Movie 
                { 
                    Id = 5, 
                    Title = "Spider-Man: Brand New Day", 
                    ReleaseDate = new DateTime(2026, 7, 24), 
                    Description = "Peter Parker faces his greatest challenge yet as he balances his life as Spider-Man with new threats emerging in New York City.",
                    Duration = 135, 
                    IsActive = true, 
                    CreatedAt = fixedDate 
                },
                new Movie 
                { 
                    Id = 6, 
                    Title = "Avatar: Fire and Ash", 
                    ReleaseDate = new DateTime(2025, 12, 19), 
                    Description = "Jake Sully and his family continue their fight for survival on Pandora as they face new threats from the fire and ash regions.",
                    Duration = 190, 
                    IsActive = true, 
                    CreatedAt = fixedDate 
                },
                new Movie 
                { 
                    Id = 7, 
                    Title = "Titanic", 
                    ReleaseDate = new DateTime(1997, 12, 19), 
                    Description = "A seventeen-year-old aristocrat falls in love with a kind but poor artist aboard the luxurious, ill-fated R.M.S. Titanic.",
                    Duration = 195, 
                    IsActive = true, 
                    CreatedAt = fixedDate 
                },
                new Movie 
                { 
                    Id = 8, 
                    Title = "Cast Away", 
                    ReleaseDate = new DateTime(2000, 12, 22), 
                    Description = "A FedEx executive undergoes a physical and emotional transformation after crash landing on a deserted island.",
                    Duration = 143, 
                    IsActive = true, 
                    CreatedAt = fixedDate 
                }
            );

            // Seed MovieActors
            modelBuilder.Entity<MovieActor>().HasData(
                // Fantastic Four: First Steps
                new MovieActor { Id = 1, MovieId = 1, ActorId = 1, DateAssigned = fixedDate }, // Pedro Pascal
                new MovieActor { Id = 2, MovieId = 1, ActorId = 2, DateAssigned = fixedDate }, // Vanessa Kirby
                new MovieActor { Id = 3, MovieId = 1, ActorId = 3, DateAssigned = fixedDate }, // Joseph Quinn
                new MovieActor { Id = 4, MovieId = 1, ActorId = 4, DateAssigned = fixedDate }, // Ebon Moss-Bachrach

                // Superman (2025)
                new MovieActor { Id = 5, MovieId = 2, ActorId = 5, DateAssigned = fixedDate }, // David Corenswet
                new MovieActor { Id = 6, MovieId = 2, ActorId = 6, DateAssigned = fixedDate }, // Rachel Brosnahan
                new MovieActor { Id = 7, MovieId = 2, ActorId = 7, DateAssigned = fixedDate }, // Nicholas Hoult

                // F1 Movie (2025)
                new MovieActor { Id = 8, MovieId = 3, ActorId = 8, DateAssigned = fixedDate }, // Brad Pitt
                new MovieActor { Id = 9, MovieId = 3, ActorId = 9, DateAssigned = fixedDate }, // Damson Idris
                new MovieActor { Id = 10, MovieId = 3, ActorId = 10, DateAssigned = fixedDate }, // Kerry Condon

                // Elio
                new MovieActor { Id = 11, MovieId = 4, ActorId = 11, DateAssigned = fixedDate }, // Yonas Kibreab
                new MovieActor { Id = 12, MovieId = 4, ActorId = 12, DateAssigned = fixedDate }, // Zoe Saldana

                // Spider-Man: Brand New Day
                new MovieActor { Id = 13, MovieId = 5, ActorId = 13, DateAssigned = fixedDate }, // Tom Holland
                new MovieActor { Id = 14, MovieId = 5, ActorId = 14, DateAssigned = fixedDate }, // Zendaya
                new MovieActor { Id = 15, MovieId = 5, ActorId = 15, DateAssigned = fixedDate }, // Jacob Batalon

                // Avatar: Fire and Ash
                new MovieActor { Id = 16, MovieId = 6, ActorId = 16, DateAssigned = fixedDate }, // Sam Worthington
                new MovieActor { Id = 17, MovieId = 6, ActorId = 17, DateAssigned = fixedDate }, // Zoe Saldana
                new MovieActor { Id = 18, MovieId = 6, ActorId = 18, DateAssigned = fixedDate }, // Sigourney Weaver
                new MovieActor { Id = 19, MovieId = 6, ActorId = 19, DateAssigned = fixedDate }, // Kate Winslet

                // Titanic
                new MovieActor { Id = 20, MovieId = 7, ActorId = 20, DateAssigned = fixedDate }, // Leonardo DiCaprio
                new MovieActor { Id = 21, MovieId = 7, ActorId = 21, DateAssigned = fixedDate }, // Kate Winslet
                new MovieActor { Id = 22, MovieId = 7, ActorId = 22, DateAssigned = fixedDate }, // Billy Zane
                new MovieActor { Id = 23, MovieId = 7, ActorId = 23, DateAssigned = fixedDate }, // Gloria Stuart

                // Cast Away
                new MovieActor { Id = 24, MovieId = 8, ActorId = 24, DateAssigned = fixedDate }, // Tom Hanks
                new MovieActor { Id = 25, MovieId = 8, ActorId = 25, DateAssigned = fixedDate }  // Helen Hunt
            );
        }
    }
} 