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

            // Seed Categories
            modelBuilder.Entity<Category>().HasData(
                new Category 
                { 
                    Id = 1, 
                    Name = "In Theaters", 
                    Description = "Movies currently playing in theaters",
                    IsActive = true, 
                    CreatedAt = fixedDate 
                },
                new Category 
                { 
                    Id = 2, 
                    Name = "Upcoming", 
                    Description = "Movies coming soon to theaters",
                    IsActive = true, 
                    CreatedAt = fixedDate 
                },
                new Category 
                { 
                    Id = 3, 
                    Name = "Classics", 
                    Description = "Classic movies from the past",
                    IsActive = true, 
                    CreatedAt = fixedDate 
                }
            );

            // Seed Genres
            modelBuilder.Entity<Genre>().HasData(
                new Genre { Id = 1, Name = "Action", Description = "High-energy films with physical stunts and chases", IsActive = true, CreatedAt = fixedDate },
                new Genre { Id = 2, Name = "Adventure", Description = "Exciting journeys and quests", IsActive = true, CreatedAt = fixedDate },
                new Genre { Id = 3, Name = "Comedy", Description = "Humorous films intended to make audiences laugh", IsActive = true, CreatedAt = fixedDate },
                new Genre { Id = 4, Name = "Drama", Description = "Serious, plot-driven films focusing on realistic characters", IsActive = true, CreatedAt = fixedDate },
                new Genre { Id = 5, Name = "Horror", Description = "Films intended to frighten and create suspense", IsActive = true, CreatedAt = fixedDate },
                new Genre { Id = 6, Name = "Romance", Description = "Films focusing on love stories and relationships", IsActive = true, CreatedAt = fixedDate },
                new Genre { Id = 7, Name = "Thriller", Description = "Suspenseful films that keep audiences on edge", IsActive = true, CreatedAt = fixedDate },
                new Genre { Id = 8, Name = "Science Fiction", Description = "Films with futuristic or scientific themes", IsActive = true, CreatedAt = fixedDate },
                new Genre { Id = 9, Name = "Fantasy", Description = "Films with magical or supernatural elements", IsActive = true, CreatedAt = fixedDate },
                new Genre { Id = 10, Name = "Animation", Description = "Films created using animation techniques", IsActive = true, CreatedAt = fixedDate },
                new Genre { Id = 11, Name = "Documentary", Description = "Non-fiction films about real events or people", IsActive = true, CreatedAt = fixedDate },
                new Genre { Id = 12, Name = "Musical", Description = "Films featuring songs and musical numbers", IsActive = true, CreatedAt = fixedDate },
                new Genre { Id = 13, Name = "Western", Description = "Films set in the American Old West", IsActive = true, CreatedAt = fixedDate },
                new Genre { Id = 14, Name = "Crime", Description = "Films about criminal activities and law enforcement", IsActive = true, CreatedAt = fixedDate },
                new Genre { Id = 15, Name = "Mystery", Description = "Films involving puzzles or unsolved crimes", IsActive = true, CreatedAt = fixedDate },
                new Genre { Id = 16, Name = "War", Description = "Films set during wartime or about military conflicts", IsActive = true, CreatedAt = fixedDate },
                new Genre { Id = 17, Name = "Biography", Description = "Films based on real people's lives", IsActive = true, CreatedAt = fixedDate },
                new Genre { Id = 18, Name = "History", Description = "Films set in historical periods", IsActive = true, CreatedAt = fixedDate },
                new Genre { Id = 19, Name = "Sport", Description = "Films centered around sports and athletic competition", IsActive = true, CreatedAt = fixedDate },
                new Genre { Id = 20, Name = "Family", Description = "Films suitable for all family members", IsActive = true, CreatedAt = fixedDate }
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

            // Seed Directors
            modelBuilder.Entity<Director>().HasData(
                new Director { Id = 1, FirstName = "Matt", LastName = "Shakman", Nationality = "American", IsActive = true, CreatedAt = fixedDate },
                new Director { Id = 2, FirstName = "James", LastName = "Gunn", Nationality = "American", IsActive = true, CreatedAt = fixedDate },
                new Director { Id = 3, FirstName = "Joseph", LastName = "Kosinski", Nationality = "American", IsActive = true, CreatedAt = fixedDate },
                new Director { Id = 4, FirstName = "Adrian", LastName = "Molina", Nationality = "American", IsActive = true, CreatedAt = fixedDate },
                new Director { Id = 5, FirstName = "Jon", LastName = "Watts", Nationality = "American", IsActive = true, CreatedAt = fixedDate },
                new Director { Id = 6, FirstName = "James", LastName = "Cameron", Nationality = "Canadian", IsActive = true, CreatedAt = fixedDate },
                new Director { Id = 7, FirstName = "Robert", LastName = "Zemeckis", Nationality = "American", IsActive = true, CreatedAt = fixedDate },
                new Director { Id = 8, FirstName = "Christopher", LastName = "Nolan", Nationality = "British-American", IsActive = true, CreatedAt = fixedDate },
                new Director { Id = 9, FirstName = "Quentin", LastName = "Tarantino", Nationality = "American", IsActive = true, CreatedAt = fixedDate },
                new Director { Id = 10, FirstName = "Steven", LastName = "Spielberg", Nationality = "American", IsActive = true, CreatedAt = fixedDate },
                new Director { Id = 11, FirstName = "Martin", LastName = "Scorsese", Nationality = "American", IsActive = true, CreatedAt = fixedDate },
                new Director { Id = 12, FirstName = "Ridley", LastName = "Scott", Nationality = "British", IsActive = true, CreatedAt = fixedDate },
                new Director { Id = 13, FirstName = "Denis", LastName = "Villeneuve", Nationality = "Canadian", IsActive = true, CreatedAt = fixedDate },
                new Director { Id = 14, FirstName = "Greta", LastName = "Gerwig", Nationality = "American", IsActive = true, CreatedAt = fixedDate },
                new Director { Id = 15, FirstName = "Jordan", LastName = "Peele", Nationality = "American", IsActive = true, CreatedAt = fixedDate },
                new Director { Id = 16, FirstName = "Rian", LastName = "Johnson", Nationality = "American", IsActive = true, CreatedAt = fixedDate },
                new Director { Id = 17, FirstName = "Chloe", LastName = "Zhao", Nationality = "Chinese", IsActive = true, CreatedAt = fixedDate },
                new Director { Id = 18, FirstName = "Damien", LastName = "Chazelle", Nationality = "American", IsActive = true, CreatedAt = fixedDate },
                new Director { Id = 19, FirstName = "Bong", LastName = "Joon-ho", Nationality = "South Korean", IsActive = true, CreatedAt = fixedDate },
                new Director { Id = 20, FirstName = "Patty", LastName = "Jenkins", Nationality = "American", IsActive = true, CreatedAt = fixedDate }
            );

            // Seed Production Companies
            modelBuilder.Entity<ProductionCompany>().HasData(
                new ProductionCompany { Id = 1, Name = "Marvel Studios", Description = "American film and television production company", Country = "United States", IsActive = true, CreatedAt = fixedDate },
                new ProductionCompany { Id = 2, Name = "DC Studios", Description = "American film and television production company", Country = "United States", IsActive = true, CreatedAt = fixedDate },
                new ProductionCompany { Id = 3, Name = "Warner Bros. Pictures", Description = "American film production and distribution company", Country = "United States", IsActive = true, CreatedAt = fixedDate },
                new ProductionCompany { Id = 4, Name = "Universal Pictures", Description = "American film production and distribution company", Country = "United States", IsActive = true, CreatedAt = fixedDate },
                new ProductionCompany { Id = 5, Name = "Sony Pictures", Description = "American entertainment company", Country = "United States", IsActive = true, CreatedAt = fixedDate },
                new ProductionCompany { Id = 6, Name = "Paramount Pictures", Description = "American film and television production company", Country = "United States", IsActive = true, CreatedAt = fixedDate },
                new ProductionCompany { Id = 7, Name = "20th Century Studios", Description = "American film production company", Country = "United States", IsActive = true, CreatedAt = fixedDate },
                new ProductionCompany { Id = 8, Name = "Walt Disney Pictures", Description = "American film production company", Country = "United States", IsActive = true, CreatedAt = fixedDate },
                new ProductionCompany { Id = 9, Name = "Pixar Animation Studios", Description = "American computer animation studio", Country = "United States", IsActive = true, CreatedAt = fixedDate },
                new ProductionCompany { Id = 10, Name = "Legendary Entertainment", Description = "American film production and mass media company", Country = "United States", IsActive = true, CreatedAt = fixedDate },
                new ProductionCompany { Id = 11, Name = "Lionsgate Films", Description = "American entertainment company", Country = "United States", IsActive = true, CreatedAt = fixedDate },
                new ProductionCompany { Id = 12, Name = "A24", Description = "American independent entertainment company", Country = "United States", IsActive = true, CreatedAt = fixedDate },
                new ProductionCompany { Id = 13, Name = "Netflix", Description = "American streaming service and production company", Country = "United States", IsActive = true, CreatedAt = fixedDate },
                new ProductionCompany { Id = 14, Name = "Amazon Studios", Description = "American television and film producer and distributor", Country = "United States", IsActive = true, CreatedAt = fixedDate },
                new ProductionCompany { Id = 15, Name = "Apple Studios", Description = "American film and television production company", Country = "United States", IsActive = true, CreatedAt = fixedDate },
                new ProductionCompany { Id = 16, Name = "Blumhouse Productions", Description = "American film and television production company", Country = "United States", IsActive = true, CreatedAt = fixedDate },
                new ProductionCompany { Id = 17, Name = "Plan B Entertainment", Description = "American film production company", Country = "United States", IsActive = true, CreatedAt = fixedDate },
                new ProductionCompany { Id = 18, Name = "Bad Robot Productions", Description = "American film and television production company", Country = "United States", IsActive = true, CreatedAt = fixedDate },
                new ProductionCompany { Id = 19, Name = "Lucasfilm", Description = "American film and television production company", Country = "United States", IsActive = true, CreatedAt = fixedDate },
                new ProductionCompany { Id = 20, Name = "Amblin Entertainment", Description = "American film production company", Country = "United States", IsActive = true, CreatedAt = fixedDate }
            );

            // Seed Movies
            modelBuilder.Entity<Movie>().HasData(
                // In Theaters (first 4 movies)
                new Movie 
                { 
                    Id = 1, 
                    Title = "Fantastic Four: First Steps", 
                    ReleaseDate = new DateTime(2025, 7, 25), 
                    Description = "The first family of superheroes, the Fantastic Four, gain their powers and learn to work together to stop the world-devouring Galactus.",
                    Duration = 125, 
                    IsActive = true, 
                    CreatedAt = fixedDate,
                    CategoryId = 1, // In Theaters
                    GenreId = 1, // Action
                    DirectorId = 1, // Matt Shakman
                    Poster = ImageConversion.ConvertImageToByteArray("Assets", "1.jpg"),
                    Trailer = "https://www.youtube.com/watch?v=pAsmrKyMqaA"
                },
                new Movie 
                { 
                    Id = 2, 
                    Title = "Superman", 
                    ReleaseDate = new DateTime(2025, 7, 11), 
                    Description = "Superman navigates his dual identity as Clark Kent and the Man of Steel, while facing new challenges in Metropolis.",
                    Duration = 140, 
                    IsActive = true, 
                    CreatedAt = fixedDate,
                    CategoryId = 1, // In Theaters
                    GenreId = 1, // Action
                    DirectorId = 2, // James Gunn
                    Poster = ImageConversion.ConvertImageToByteArray("Assets", "2.jpg"),
                    Trailer = "https://www.youtube.com/watch?v=Ox8ZLF6cGM0"
                },
                new Movie 
                { 
                    Id = 3, 
                    Title = "F1", 
                    ReleaseDate = new DateTime(2025, 6, 27), 
                    Description = "A seasoned Formula 1 driver comes out of retirement to mentor a young rookie and compete at the highest level of motorsport.",
                    Duration = 130, 
                    IsActive = true, 
                    CreatedAt = fixedDate,
                    CategoryId = 1, // In Theaters
                    GenreId = 19, // Sport
                    DirectorId = 3, // Joseph Kosinski
                    Poster = ImageConversion.ConvertImageToByteArray("Assets", "3.jpg"),
                    Trailer = "https://www.youtube.com/watch?v=69ffwl-8pCU"
                },
                new Movie 
                { 
                    Id = 4, 
                    Title = "Elio", 
                    ReleaseDate = new DateTime(2025, 6, 13), 
                    Description = "A young boy with an active imagination accidentally becomes Earth's intergalactic representative and must navigate alien politics.",
                    Duration = 100, 
                    IsActive = true, 
                    CreatedAt = fixedDate,
                    CategoryId = 1, // In Theaters
                    GenreId = 10, // Animation
                    DirectorId = 4, // Adrian Molina
                    Poster = ImageConversion.ConvertImageToByteArray("Assets", "4.jpg"),
                    Trailer = "https://www.youtube.com/watch?v=ETVi5_cnnaE"

                },
                // Upcoming (Spider-Man and Avatar)
                new Movie 
                { 
                    Id = 5, 
                    Title = "Spider-Man: Brand New Day", 
                    ReleaseDate = new DateTime(2026, 7, 24), 
                    Description = "Peter Parker faces his greatest challenge yet as he balances his life as Spider-Man with new threats emerging in New York City.",
                    Duration = 135, 
                    IsActive = true, 
                    CreatedAt = fixedDate,
                    CategoryId = 2, // Upcoming
                    GenreId = 1, // Action
                    DirectorId = 5, // Jon Watts
                    Poster = ImageConversion.ConvertImageToByteArray("Assets", "5.jpg")
                },
                new Movie 
                { 
                    Id = 6, 
                    Title = "Avatar: Fire and Ash", 
                    ReleaseDate = new DateTime(2025, 12, 19), 
                    Description = "Jake Sully and his family continue their fight for survival on Pandora as they face new threats from the fire and ash regions.",
                    Duration = 190, 
                    IsActive = true, 
                    CreatedAt = fixedDate,
                    CategoryId = 2, // Upcoming
                    GenreId = 8, // Science Fiction
                    DirectorId = 6, // James Cameron
                    Poster = ImageConversion.ConvertImageToByteArray("Assets", "6.jpg"),
                    Trailer = "https://www.youtube.com/watch?v=nb_fFj_0rq8"
                },
                // Classics (Titanic and Cast Away)
                new Movie 
                { 
                    Id = 7, 
                    Title = "Titanic", 
                    ReleaseDate = new DateTime(1997, 12, 19), 
                    Description = "A seventeen-year-old aristocrat falls in love with a kind but poor artist aboard the luxurious, ill-fated R.M.S. Titanic.",
                    Duration = 195, 
                    IsActive = true, 
                    CreatedAt = fixedDate,
                    CategoryId = 3, // Classics
                    GenreId = 6, // Romance
                    DirectorId = 6, // James Cameron
                    Poster = ImageConversion.ConvertImageToByteArray("Assets", "7.jpg"),
                    Trailer = "https://www.youtube.com/watch?v=kVrqfYjkTdQ"
                },
                new Movie 
                { 
                    Id = 8, 
                    Title = "Cast Away", 
                    ReleaseDate = new DateTime(2000, 12, 22), 
                    Description = "A FedEx executive undergoes a physical and emotional transformation after crash landing on a deserted island.",
                    Duration = 143, 
                    IsActive = true, 
                    CreatedAt = fixedDate,
                    CategoryId = 3, // Classics
                    GenreId = 4, // Drama
                    DirectorId = 7, // Robert Zemeckis
                    Poster = ImageConversion.ConvertImageToByteArray("Assets", "8.jpg"),
                    Trailer = "https://www.youtube.com/watch?v=qGuOZPwLayY"
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

            // Seed MovieProductionCompanies
            modelBuilder.Entity<MovieProductionCompany>().HasData(
                // Fantastic Four: First Steps - Marvel Studios + Disney
                new MovieProductionCompany { Id = 1, MovieId = 1, ProductionCompanyId = 1, DateAssigned = fixedDate }, // Marvel Studios
                new MovieProductionCompany { Id = 2, MovieId = 1, ProductionCompanyId = 8, DateAssigned = fixedDate }, // Walt Disney Pictures

                // Superman - DC Studios + Warner Bros
                new MovieProductionCompany { Id = 3, MovieId = 2, ProductionCompanyId = 2, DateAssigned = fixedDate }, // DC Studios
                new MovieProductionCompany { Id = 4, MovieId = 2, ProductionCompanyId = 3, DateAssigned = fixedDate }, // Warner Bros

                // F1 - Apple Studios + Plan B Entertainment
                new MovieProductionCompany { Id = 5, MovieId = 3, ProductionCompanyId = 15, DateAssigned = fixedDate }, // Apple Studios
                new MovieProductionCompany { Id = 6, MovieId = 3, ProductionCompanyId = 17, DateAssigned = fixedDate }, // Plan B Entertainment

                // Elio - Pixar + Disney
                new MovieProductionCompany { Id = 7, MovieId = 4, ProductionCompanyId = 9, DateAssigned = fixedDate }, // Pixar
                new MovieProductionCompany { Id = 8, MovieId = 4, ProductionCompanyId = 8, DateAssigned = fixedDate }, // Disney

                // Spider-Man: Brand New Day - Marvel Studios + Sony Pictures
                new MovieProductionCompany { Id = 9, MovieId = 5, ProductionCompanyId = 1, DateAssigned = fixedDate }, // Marvel Studios
                new MovieProductionCompany { Id = 10, MovieId = 5, ProductionCompanyId = 5, DateAssigned = fixedDate }, // Sony Pictures

                // Avatar: Fire and Ash - 20th Century Studios + Lightstorm Entertainment
                new MovieProductionCompany { Id = 11, MovieId = 6, ProductionCompanyId = 7, DateAssigned = fixedDate }, // 20th Century Studios
                new MovieProductionCompany { Id = 12, MovieId = 6, ProductionCompanyId = 8, DateAssigned = fixedDate}, // Disney

                // Titanic - 20th Century Studios + Paramount Pictures
                new MovieProductionCompany { Id = 13, MovieId = 7, ProductionCompanyId = 7, DateAssigned = fixedDate }, // 20th Century Studios
                new MovieProductionCompany { Id = 14, MovieId = 7, ProductionCompanyId = 6, DateAssigned = fixedDate }, // Paramount Pictures

                // Cast Away - 20th Century Studios + Amblin Entertainment
                new MovieProductionCompany { Id = 15, MovieId = 8, ProductionCompanyId = 7, DateAssigned = fixedDate }, // 20th Century Studios
                new MovieProductionCompany { Id = 16, MovieId = 8, ProductionCompanyId = 20, DateAssigned = fixedDate } // Amblin Entertainment
            );

            // Seed Halls
            modelBuilder.Entity<Hall>().HasData(
                new Hall { Id = 1, Name = "Hall 1", IsActive = true, CreatedAt = fixedDate },
                new Hall { Id = 2, Name = "Hall 2", IsActive = true, CreatedAt = fixedDate },
                new Hall { Id = 3, Name = "4DX Hall", IsActive = true, CreatedAt = fixedDate },
                new Hall { Id = 4, Name = "IMAX Hall", IsActive = true, CreatedAt = fixedDate }
            );

            // Seed SeatTypes
            modelBuilder.Entity<SeatType>().HasData(
                new SeatType { Id = 1, Name = "Standard", IsActive = true, CreatedAt = fixedDate },
                new SeatType { Id = 2, Name = "Love Seat", IsActive = true, CreatedAt = fixedDate },
                new SeatType { Id = 3, Name = "Wheelchair", IsActive = true, CreatedAt = fixedDate }
            );

            // Seed Seats for all halls (10x10 grid for each hall)
            var seats = new List<Seat>();
            int seatId = 1;

            for (int hallId = 1; hallId <= 4; hallId++)
            {
                for (int row = 0; row < 10; row++)
                {
                    char rowLetter = (char)('A' + row);
                    for (int seatNum = 1; seatNum <= 10; seatNum++)
                    {
                        int? seatTypeId = null;

                        // Assign special seat types strategically
                        // Wheelchair seats at the back row (J) positions 1-2
                        if (rowLetter == 'J' && seatNum <= 2)
                        {
                            seatTypeId = 3; // Wheelchair
                        }
                        // Love seats in middle rows (E, F, G) at positions 4-5 and 6-7
                        else if ((rowLetter == 'E' || rowLetter == 'F' || rowLetter == 'G') && 
                                (seatNum == 4 || seatNum == 5 || seatNum == 6 || seatNum == 7))
                        {
                            seatTypeId = 2; // Love Seat
                        }
                        // All other seats are Standard (will be null initially as requested)
                        else
                        {
                            seatTypeId = 1; // Standard
                        }

                        seats.Add(new Seat
                        {
                            Id = seatId++,
                            SeatNumber = $"{rowLetter}{seatNum}",
                            HallId = hallId,
                            SeatTypeId = seatTypeId,
                            IsActive = true,
                            CreatedAt = fixedDate
                        });
                    }
                }
            }

            modelBuilder.Entity<Seat>().HasData(seats);

            // Seed ScreeningTypes
            modelBuilder.Entity<ScreeningType>().HasData(
                new ScreeningType { Id = 1, Name = "2D", Description = "Standard 2D screening", Price = 5.00m, IsActive = true, CreatedAt = fixedDate },
                new ScreeningType { Id = 2, Name = "3D", Description = "3D screening with special glasses", Price = 8.00m, IsActive = true, CreatedAt = fixedDate },
                new ScreeningType { Id = 3, Name = "4DX", Description = "4DX experience with motion seats and environmental effects", Price = 15.00m, IsActive = true, CreatedAt = fixedDate },
                new ScreeningType { Id = 4, Name = "IMAX", Description = "IMAX large format screening", Price = 12.00m, IsActive = true, CreatedAt = fixedDate }
            );

            // Seed Screenings for next 3 days (3 screenings per movie per day)
            var screenings = new List<Screening>();
            int screeningId = 1;
            var today = fixedDate.Date; // Use fixed date for consistency

            // Screening times: 13:00, 17:30, 21:00
            var screeningTimes = new TimeSpan[] 
            {
                new TimeSpan(13, 0, 0), // 1:00 PM
                new TimeSpan(17, 30, 0), // 5:30 PM
                new TimeSpan(21, 0, 0)   // 9:00 PM
            };

            // Hall assignments based on screening type
            var hallAssignments = new Dictionary<int, int[]>
            {
                { 1, new[] { 1, 2 } }, // 2D -> Hall 1, Hall 2
                { 2, new[] { 1, 2 } }, // 3D -> Hall 1, Hall 2  
                { 3, new[] { 3 } },    // 4DX -> 4DX Hall
                { 4, new[] { 4 } }     // IMAX -> IMAX Hall
            };

            // Movie to screening type mapping (varied for each movie)
            var movieScreeningTypes = new Dictionary<int, int[]>
            {
                { 1, new[] { 1, 2 } }, // Fantastic Four: 2D, 3D
                { 2, new[] { 1, 4 } }, // Superman: 2D, IMAX
                { 3, new[] { 1, 3 } }, // F1: 2D, 4DX
                { 4, new[] { 1, 2 } }, // Elio: 2D, 3D
                { 5, new[] { 1, 4 } }, // Spider-Man: 2D, IMAX
                { 6, new[] { 1, 3 } }, // Avatar: 2D, 4DX
                { 7, new[] { 1, 2 } }, // Titanic: 2D, 3D
                { 8, new[] { 1 } }     // Cast Away: 2D only
            };

            for (int day = 0; day < 3; day++) // Next 3 days
            {
                var currentDate = today.AddDays(day);
                
                foreach (var movieEntry in movieScreeningTypes)
                {
                    int movieId = movieEntry.Key;
                    int[] screeningTypeIds = movieEntry.Value;

                    foreach (int screeningTypeId in screeningTypeIds)
                    {
                        int[] availableHalls = hallAssignments[screeningTypeId];
                        
                        for (int timeIndex = 0; timeIndex < screeningTimes.Length; timeIndex++)
                        {
                            // Distribute across available halls to avoid conflicts
                            int hallId = availableHalls[timeIndex % availableHalls.Length];
                            
                            var startTime = currentDate.Add(screeningTimes[timeIndex]);
                            
                            screenings.Add(new Screening
                            {
                                Id = screeningId++,
                                MovieId = movieId,
                                HallId = hallId,
                                ScreeningTypeId = screeningTypeId,
                                StartTime = startTime,
                                IsActive = true,
                                CreatedAt = fixedDate
                            });
                        }
                    }
                }
            }

            modelBuilder.Entity<Screening>().HasData(screenings);

            // Seed Tickets for users with User role (3 tickets each)
            // Based on seeding: User IDs 3 and 4 have User role (Role ID 2)
            var tickets = new List<Ticket>();
            int ticketId = 1;
            var userIds = new[] { 3, 4 }; // Users with User role

            foreach (int userId in userIds)
            {
                // Give each user 3 tickets for different screenings
                // Ticket 1: First screening of first movie
                tickets.Add(new Ticket
                {
                    Id = ticketId++,
                    UserId = userId,
                    ScreeningId = 1, // First screening in the list
                    SeatId = userId == 3 ? 1 : 2, // Different seats (A1, A2)
                    IsActive = true,
                    CreatedAt = fixedDate
                });

                // Ticket 2: Different screening
                tickets.Add(new Ticket
                {
                    Id = ticketId++,
                    UserId = userId,
                    ScreeningId = userId == 3 ? 10 : 15, // Different screenings
                    SeatId = userId == 3 ? 11 : 12, // Different seats (B1, B2)
                    IsActive = true,
                    CreatedAt = fixedDate
                });

                // Ticket 3: Another different screening
                tickets.Add(new Ticket
                {
                    Id = ticketId++,
                    UserId = userId,
                    ScreeningId = userId == 3 ? 25 : 30, // Different screenings
                    SeatId = userId == 3 ? 21 : 22, // Different seats (C1, C2)
                    IsActive = true,
                    CreatedAt = fixedDate
                });
            }

            modelBuilder.Entity<Ticket>().HasData(tickets);

            // Seed Reviews for every purchased ticket
            var reviews = new List<Review>();
            int reviewId = 1;
            
            // Sample review comments
            var reviewComments = new[]
            {
                "Amazing movie! Great experience.",
                "Loved the story and acting. Highly recommend!",
                "Good movie, enjoyed it with family.",
                "Excellent cinematography and sound quality.",
                "Great entertainment, worth watching.",
                "Fantastic visual effects and storyline."
            };

            // Create a review for each ticket
            foreach (var ticket in tickets)
            {
                var random = new Random(ticket.Id); // Use ticket ID as seed for consistent results
                var rating = random.Next(3, 6); // Random rating between 3-5 (positive reviews)
                var comment = reviewComments[random.Next(reviewComments.Length)];

                reviews.Add(new Review
                {
                    Id = reviewId++,
                    UserId = ticket.UserId,
                    ScreeningId = ticket.ScreeningId,
                    Rating = rating,
                    Comment = comment,
                    IsActive = true,
                    CreatedAt = fixedDate
                });
            }

            modelBuilder.Entity<Review>().HasData(reviews);

            // Seed Products (Cinema Concessions)
            modelBuilder.Entity<Product>().HasData(
                // Popcorn
                new Product { Id = 1, Name = "Large Gourmet Popcorn", Price = 4.50m, IsActive = true, CreatedAt = fixedDate, Picture = ImageConversion.ConvertImageToByteArray("Assets", "M1.jpg") },
                new Product { Id = 2, Name = "Small Classic Popcorn", Price = 3.00m, IsActive = true, CreatedAt = fixedDate, Picture = ImageConversion.ConvertImageToByteArray("Assets", "M2.jpg") },
                
                // Beverages
                new Product { Id = 3, Name = "Large Premium Soda", Price = 3.50m, IsActive = true, CreatedAt = fixedDate, Picture = ImageConversion.ConvertImageToByteArray("Assets", "M3.jpg") },
                new Product { Id = 4, Name = "Small Refreshing Soda", Price = 2.50m, IsActive = true, CreatedAt = fixedDate, Picture = ImageConversion.ConvertImageToByteArray("Assets", "M4.jpg") },
                
                // Nachos
                new Product { Id = 5, Name = "Large Loaded Nachos", Price = 5.00m, IsActive = true, CreatedAt = fixedDate, Picture = ImageConversion.ConvertImageToByteArray("Assets", "M5.jpg") },
                new Product { Id = 6, Name = "Small Crispy Nachos", Price = 3.50m, IsActive = true, CreatedAt = fixedDate, Picture = ImageConversion.ConvertImageToByteArray("Assets", "M6.jpg") },
                
                // Combo Deals
                new Product { Id = 7, Name = "Ultimate Combo - Large Nachos + Large Soda", Price = 7.50m, IsActive = true, CreatedAt = fixedDate, Picture = ImageConversion.ConvertImageToByteArray("Assets", "M7.jpg") },
                new Product { Id = 8, Name = "Snack Combo - Small Nachos + Small Soda", Price = 5.50m, IsActive = true, CreatedAt = fixedDate, Picture = ImageConversion.ConvertImageToByteArray("Assets", "M8.jpg") },
                new Product { Id = 9, Name = "Movie Night Combo - Large Popcorn + Large Soda", Price = 7.00m, IsActive = true, CreatedAt = fixedDate, Picture = ImageConversion.ConvertImageToByteArray("Assets", "M9.jpg") },
                new Product { Id = 10, Name = "Classic Combo - Small Popcorn + Small Soda", Price = 5.00m, IsActive = true, CreatedAt = fixedDate, Picture = ImageConversion.ConvertImageToByteArray("Assets", "M10.jpg") }
            );
        }
    }
} 