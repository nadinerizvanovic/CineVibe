using EasyNetQ;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using System;
using System.Threading;
using System.Threading.Tasks;
using System.Runtime.Versioning;
using System.Linq;
using CineVibe.Subscriber.Models;
using CineVibe.Subscriber.Interfaces;
using System.Net.Sockets;
using System.Net;

namespace CineVibe.Subscriber.Services
{
    public class BackgroundWorkerService : BackgroundService
    {
        private readonly ILogger<BackgroundWorkerService> _logger;
        private readonly IEmailSenderService _emailSender;
        private readonly string _host = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "localhost";
        private readonly string _username = Environment.GetEnvironmentVariable("RABBITMQ_USERNAME") ?? "guest";
        private readonly string _password = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD") ?? "guest";
        private readonly string _virtualhost = Environment.GetEnvironmentVariable("RABBITMQ_VIRTUALHOST") ?? "/";

        public BackgroundWorkerService(
            ILogger<BackgroundWorkerService> logger,
            IEmailSenderService emailSender)
        {
            _logger = logger;
            _emailSender = emailSender;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            // Check internet connectivity to smtp.gmail.com
            try
            {
                var addresses = await Dns.GetHostAddressesAsync("smtp.gmail.com");
                _logger.LogInformation($"smtp.gmail.com resolved to: {string.Join(", ", addresses.Select(a => a.ToString()))}");
                using (var client = new TcpClient())
                {
                    var connectTask = client.ConnectAsync("smtp.gmail.com", 587);
                    var timeoutTask = Task.Delay(5000, stoppingToken);
                    var completed = await Task.WhenAny(connectTask, timeoutTask);
                    if (completed == connectTask && client.Connected)
                    {
                        _logger.LogInformation("Successfully connected to smtp.gmail.com:587");
                    }
                    else
                    {
                        _logger.LogError("Failed to connect to smtp.gmail.com:587 (timeout or error)");
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError($"Internet connectivity check failed: {ex.Message}");
            }

            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    using (var bus = RabbitHutch.CreateBus($"host={_host};virtualHost={_virtualhost};username={_username};password={_password}"))
                    {
                        // Subscribe to movie notifications only
                        bus.PubSub.Subscribe<MovieNotification>("Movie_Notifications", HandleMovieMessage);

                        _logger.LogInformation("Waiting for movie notifications...");
                        await Task.Delay(TimeSpan.FromSeconds(5), stoppingToken);
                    }
                }
                catch (OperationCanceledException) when (stoppingToken.IsCancellationRequested)
                {
                    break;
                }
                catch (Exception ex)
                {
                    _logger.LogError($"Error in RabbitMQ listener: {ex.Message}");
                }
            }
        }

        private async Task HandleMovieMessage(MovieNotification notification)
        {
            var movie = notification.Movie;

            if (!movie.UserEmails.Any())
            {
                _logger.LogWarning("No user emails provided in the notification");
                return;
            }

            var subject = "🎬 New Movie Announcement - Coming Soon to CineVibe!";
            var message = $@"
🎭 Exciting News! A New Movie is Coming to CineVibe! 🎭

📽️ Movie: {movie.Title}
🎬 Director: {movie.DirectorName}
🎪 Genre: {movie.GenreName}
📅 Release Date: {movie.ReleaseDate:MMMM dd, yyyy}
🏷️ Category: {movie.CategoryName}

📖 Description:
{movie.Description}

🎟️ Get ready for an amazing cinematic experience! Tickets will be available soon.
Visit CineVibe to book your seats and enjoy the latest blockbuster!

🍿 Don't forget to check out our delicious concessions for the perfect movie night!

---
CineVibe Cinema
Your Ultimate Movie Experience
";

            foreach (var email in movie.UserEmails)
            {
                try
                {
                    await _emailSender.SendEmailAsync(email, subject, message);
                    _logger.LogInformation($"Movie notification sent to user: {email}");
                }
                catch (Exception ex)
                {
                    _logger.LogError($"Failed to send email to {email}: {ex.Message}");
                }
            }
        }
    }
}