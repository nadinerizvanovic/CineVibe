using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace CineVibe.Services.Database
{
    public static class DatabaseConfiguration
    {
        public static void AddDatabaseServices(this IServiceCollection services, string connectionString)
        {
            services.AddDbContext<CineVibeDbContext>(options =>
                options.UseSqlServer(connectionString));
        }

        public static void AddDatabaseCineVibe(this IServiceCollection services, string connectionString)
        {
            services.AddDbContext<CineVibeDbContext>(options =>
                options.UseSqlServer(connectionString));
        }
    }
}