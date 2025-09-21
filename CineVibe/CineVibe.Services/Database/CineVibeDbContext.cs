using Microsoft.EntityFrameworkCore;

namespace CineVibe.Services.Database
{
    public class CineVibeDbContext : DbContext
    {
        public CineVibeDbContext(DbContextOptions<CineVibeDbContext> options) : base(options)
        {
        }

        public DbSet<User> Users { get; set; }
        public DbSet<Role> Roles { get; set; }
        public DbSet<UserRole> UserRoles { get; set; }
        public DbSet<Gender> Genders { get; set; }
        public DbSet<City> Cities { get; set; }
        public DbSet<Actor> Actors { get; set; }
        public DbSet<Movie> Movies { get; set; }
        public DbSet<MovieActor> MovieActors { get; set; }
        public DbSet<Category> Categories { get; set; }
        public DbSet<Genre> Genres { get; set; }
        public DbSet<Director> Directors { get; set; }
        public DbSet<ProductionCompany> ProductionCompanies { get; set; }
        public DbSet<MovieProductionCompany> MovieProductionCompanies { get; set; }
        public DbSet<Hall> Halls { get; set; }
        public DbSet<SeatType> SeatTypes { get; set; }
        public DbSet<Seat> Seats { get; set; }
        public DbSet<ScreeningType> ScreeningTypes { get; set; }
        public DbSet<Screening> Screenings { get; set; }
        public DbSet<Ticket> Tickets { get; set; }
        public DbSet<Review> Reviews { get; set; }
        public DbSet<Product> Products { get; set; }
        public DbSet<Cart> Carts { get; set; }
        public DbSet<CartItem> CartItems { get; set; }
        public DbSet<Order> Orders { get; set; }
        public DbSet<OrderItem> OrderItems { get; set; }
    

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Configure User entity
            modelBuilder.Entity<User>()
                .HasIndex(u => u.Email)
                .IsUnique();

            modelBuilder.Entity<User>()
                .HasIndex(u => u.Username)
                .IsUnique();
               

            // Configure Role entity
            modelBuilder.Entity<Role>()
                .HasIndex(r => r.Name)
                .IsUnique();

            // Configure UserRole join entity
            modelBuilder.Entity<UserRole>()
                .HasOne(ur => ur.User)
                .WithMany(u => u.UserRoles)
                .HasForeignKey(ur => ur.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<UserRole>()
                .HasOne(ur => ur.Role)
                .WithMany(r => r.UserRoles)
                .HasForeignKey(ur => ur.RoleId)
                .OnDelete(DeleteBehavior.Cascade);

            // Create a unique constraint on UserId and RoleId
            modelBuilder.Entity<UserRole>()
                .HasIndex(ur => new { ur.UserId, ur.RoleId })
                .IsUnique();

         

            // Configure Gender entity
            modelBuilder.Entity<Gender>()
                .HasIndex(g => g.Name)
                .IsUnique();

            // Configure City entity
            modelBuilder.Entity<City>()
                .HasIndex(c => c.Name)
                .IsUnique();

            modelBuilder.Entity<User>()
                .HasOne(u => u.Gender)
                .WithMany()
                .HasForeignKey(u => u.GenderId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<User>()
                .HasOne(u => u.City)
                .WithMany()
                .HasForeignKey(u => u.CityId)
                .OnDelete(DeleteBehavior.NoAction);

            // Configure Movie entity
            modelBuilder.Entity<Movie>()
                .HasIndex(m => m.Title)
                .IsUnique();

            // Configure Actor entity - no unique constraints needed for names as multiple actors can have same names

            // Configure MovieActor join entity
            modelBuilder.Entity<MovieActor>()
                .HasOne(ma => ma.Movie)
                .WithMany(m => m.MovieActors)
                .HasForeignKey(ma => ma.MovieId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<MovieActor>()
                .HasOne(ma => ma.Actor)
                .WithMany(a => a.MovieActors)
                .HasForeignKey(ma => ma.ActorId)
                .OnDelete(DeleteBehavior.Cascade);

            // Create a unique constraint on MovieId and ActorId to prevent duplicate assignments
            modelBuilder.Entity<MovieActor>()
                .HasIndex(ma => new { ma.MovieId, ma.ActorId })
                .IsUnique();

            // Configure Category entity
            modelBuilder.Entity<Category>()
                .HasIndex(c => c.Name)
                .IsUnique();

            // Configure Genre entity
            modelBuilder.Entity<Genre>()
                .HasIndex(g => g.Name)
                .IsUnique();

            // Configure Movie relationships with Category and Genre
            modelBuilder.Entity<Movie>()
                .HasOne(m => m.Category)
                .WithMany(c => c.Movies)
                .HasForeignKey(m => m.CategoryId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Movie>()
                .HasOne(m => m.Genre)
                .WithMany(g => g.Movies)
                .HasForeignKey(m => m.GenreId)
                .OnDelete(DeleteBehavior.Restrict);

            // Configure Movie relationship with Director
            modelBuilder.Entity<Movie>()
                .HasOne(m => m.Director)
                .WithMany(d => d.Movies)
                .HasForeignKey(m => m.DirectorId)
                .OnDelete(DeleteBehavior.Restrict);

            // Configure ProductionCompany entity
            modelBuilder.Entity<ProductionCompany>()
                .HasIndex(pc => pc.Name)
                .IsUnique();

            // Configure MovieProductionCompany join entity
            modelBuilder.Entity<MovieProductionCompany>()
                .HasOne(mpc => mpc.Movie)
                .WithMany(m => m.MovieProductionCompanies)
                .HasForeignKey(mpc => mpc.MovieId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<MovieProductionCompany>()
                .HasOne(mpc => mpc.ProductionCompany)
                .WithMany(pc => pc.MovieProductionCompanies)
                .HasForeignKey(mpc => mpc.ProductionCompanyId)
                .OnDelete(DeleteBehavior.Cascade);

            // Create a unique constraint on MovieId and ProductionCompanyId to prevent duplicate assignments
            modelBuilder.Entity<MovieProductionCompany>()
                .HasIndex(mpc => new { mpc.MovieId, mpc.ProductionCompanyId })
                .IsUnique();

            // Configure Hall entity
            modelBuilder.Entity<Hall>()
                .HasIndex(h => h.Name)
                .IsUnique();

            // Configure SeatType entity
            modelBuilder.Entity<SeatType>()
                .HasIndex(st => st.Name)
                .IsUnique();

            // Configure Seat relationships
            modelBuilder.Entity<Seat>()
                .HasOne(s => s.Hall)
                .WithMany(h => h.Seats)
                .HasForeignKey(s => s.HallId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<Seat>()
                .HasOne(s => s.SeatType)
                .WithMany(st => st.Seats)
                .HasForeignKey(s => s.SeatTypeId)
                .OnDelete(DeleteBehavior.SetNull);

            // Create a unique constraint on SeatNumber and HallId to prevent duplicate seat numbers in the same hall
            modelBuilder.Entity<Seat>()
                .HasIndex(s => new { s.SeatNumber, s.HallId })
                .IsUnique();

            // Configure ScreeningType entity
            modelBuilder.Entity<ScreeningType>()
                .HasIndex(st => st.Name)
                .IsUnique();

            // Configure Screening relationships
            modelBuilder.Entity<Screening>()
                .HasOne(s => s.Movie)
                .WithMany()
                .HasForeignKey(s => s.MovieId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Screening>()
                .HasOne(s => s.Hall)
                .WithMany()
                .HasForeignKey(s => s.HallId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Screening>()
                .HasOne(s => s.ScreeningType)
                .WithMany(st => st.Screenings)
                .HasForeignKey(s => s.ScreeningTypeId)
                .OnDelete(DeleteBehavior.Restrict);

            // Create an index on StartTime and HallId for efficient conflict checking
            modelBuilder.Entity<Screening>()
                .HasIndex(s => new { s.HallId, s.StartTime });

            // Configure Ticket relationships
            modelBuilder.Entity<Ticket>()
                .HasOne(t => t.Seat)
                .WithMany()
                .HasForeignKey(t => t.SeatId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Ticket>()
                .HasOne(t => t.Screening)
                .WithMany()
                .HasForeignKey(t => t.ScreeningId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Ticket>()
                .HasOne(t => t.User)
                .WithMany()
                .HasForeignKey(t => t.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            // Create a unique constraint on SeatId and ScreeningId to prevent duplicate bookings
            modelBuilder.Entity<Ticket>()
                .HasIndex(t => new { t.SeatId, t.ScreeningId })
                .IsUnique();

            // Configure Review relationships
            modelBuilder.Entity<Review>()
                .HasOne(r => r.Screening)
                .WithMany()
                .HasForeignKey(r => r.ScreeningId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<Review>()
                .HasOne(r => r.User)
                .WithMany()
                .HasForeignKey(r => r.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            // Create a unique constraint on UserId and ScreeningId to prevent duplicate reviews
            modelBuilder.Entity<Review>()
                .HasIndex(r => new { r.UserId, r.ScreeningId })
                .IsUnique();

            // Configure Product entity
            modelBuilder.Entity<Product>()
                .HasIndex(p => p.Name)
                .IsUnique();

            // Configure Cart relationships
            modelBuilder.Entity<Cart>()
                .HasOne(c => c.User)
                .WithMany()
                .HasForeignKey(c => c.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            // Create a unique constraint on UserId to ensure one cart per user
            modelBuilder.Entity<Cart>()
                .HasIndex(c => c.UserId)
                .IsUnique();

            // Configure CartItem relationships
            modelBuilder.Entity<CartItem>()
                .HasOne(ci => ci.Cart)
                .WithMany(c => c.CartItems)
                .HasForeignKey(ci => ci.CartId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<CartItem>()
                .HasOne(ci => ci.Product)
                .WithMany()
                .HasForeignKey(ci => ci.ProductId)
                .OnDelete(DeleteBehavior.Restrict);

            // Create a unique constraint on CartId and ProductId to prevent duplicate items
            modelBuilder.Entity<CartItem>()
                .HasIndex(ci => new { ci.CartId, ci.ProductId })
                .IsUnique();

            // Configure Order relationships
            modelBuilder.Entity<Order>()
                .HasOne(o => o.User)
                .WithMany()
                .HasForeignKey(o => o.UserId)
                .OnDelete(DeleteBehavior.Restrict);

            // Configure OrderItem relationships
            modelBuilder.Entity<OrderItem>()
                .HasOne(oi => oi.Order)
                .WithMany(o => o.OrderItems)
                .HasForeignKey(oi => oi.OrderId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<OrderItem>()
                .HasOne(oi => oi.Product)
                .WithMany()
                .HasForeignKey(oi => oi.ProductId)
                .OnDelete(DeleteBehavior.Restrict);

            // Seed initial data
            modelBuilder.SeedData();
        }
    }
} 