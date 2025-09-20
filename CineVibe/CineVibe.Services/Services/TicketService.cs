using CineVibe.Model.Requests;
using CineVibe.Model.Responses;
using CineVibe.Model.SearchObjects;
using CineVibe.Services.Database;
using CineVibe.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace CineVibe.Services.Services
{
    public class TicketService : BaseCRUDService<TicketResponse, TicketSearchObject, Ticket, TicketUpsertRequest, TicketUpsertRequest>, ITicketService
    {
        public TicketService(CineVibeDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override TicketResponse MapToResponse(Ticket entity)
        {
            return new TicketResponse
            {
                Id = entity.Id,
                IsActive = entity.IsActive,
                CreatedAt = entity.CreatedAt,
                SeatId = entity.SeatId,
                SeatNumber = entity.Seat?.SeatNumber ?? string.Empty,
                ScreeningId = entity.ScreeningId,
                ScreeningStartTime = entity.Screening?.StartTime ?? DateTime.MinValue,
                MovieTitle = entity.Screening?.Movie?.Title ?? string.Empty,
                HallName = entity.Screening?.Hall?.Name ?? string.Empty,
                ScreeningTypeName = entity.Screening?.ScreeningType?.Name ?? string.Empty,
                UserId = entity.UserId,
                UserFullName = $"{entity.User?.FirstName} {entity.User?.LastName}".Trim()
            };
        }

        protected override IQueryable<Ticket> ApplyFilter(IQueryable<Ticket> query, TicketSearchObject search)
        {
            // Include navigation properties for proper mapping
            query = query.Include(t => t.Seat)
                         .Include(t => t.Screening)
                         .ThenInclude(s => s.Movie)
                         .Include(t => t.Screening)
                         .ThenInclude(s => s.Hall)
                         .Include(t => t.Screening)
                         .ThenInclude(s => s.ScreeningType)
                         .Include(t => t.User);

            if (search.UserId.HasValue)
            {
                query = query.Where(t => t.UserId == search.UserId.Value);
            }

            if (search.ScreeningId.HasValue)
            {
                query = query.Where(t => t.ScreeningId == search.ScreeningId.Value);
            }

            if (search.MovieId.HasValue)
            {
                query = query.Where(t => t.Screening.MovieId == search.MovieId.Value);
            }

            if (search.HallId.HasValue)
            {
                query = query.Where(t => t.Screening.HallId == search.HallId.Value);
            }

            if (search.SeatId.HasValue)
            {
                query = query.Where(t => t.SeatId == search.SeatId.Value);
            }

            if (search.ScreeningDateFrom.HasValue)
            {
                query = query.Where(t => t.Screening.StartTime.Date >= search.ScreeningDateFrom.Value.Date);
            }

            if (search.ScreeningDateTo.HasValue)
            {
                query = query.Where(t => t.Screening.StartTime.Date <= search.ScreeningDateTo.Value.Date);
            }

            if (search.IsActive.HasValue)
            {
                query = query.Where(t => t.IsActive == search.IsActive.Value);
            }

            return query;
        }

        public override async Task<TicketResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Set<Ticket>()
                .Include(t => t.Seat)
                .Include(t => t.Screening)
                .ThenInclude(s => s.Movie)
                .Include(t => t.Screening)
                .ThenInclude(s => s.Hall)
                .Include(t => t.Screening)
                .ThenInclude(s => s.ScreeningType)
                .Include(t => t.User)
                .FirstOrDefaultAsync(t => t.Id == id);

            if (entity == null)
                return null;

            return MapToResponse(entity);
        }

        protected override async Task BeforeInsert(Ticket entity, TicketUpsertRequest request)
        {
            // Verify user exists and has User role
            var user = await _context.Users
                .Include(u => u.UserRoles)
                .ThenInclude(ur => ur.Role)
                .FirstOrDefaultAsync(u => u.Id == request.UserId);

            if (user == null)
            {
                throw new InvalidOperationException("The specified user does not exist.");
            }

            // Check if user has User role (assuming Role Id 2 is "User" based on seeding)
            var hasUserRole = user.UserRoles.Any(ur => ur.Role.Name == "User");
            if (!hasUserRole)
            {
                throw new InvalidOperationException("Only users with User role can purchase tickets.");
            }

            // Verify screening exists
            var screening = await _context.Screenings
                .Include(s => s.Hall)
                .FirstOrDefaultAsync(s => s.Id == request.ScreeningId);

            if (screening == null)
            {
                throw new InvalidOperationException("The specified screening does not exist.");
            }

            // Verify seat exists
            var seat = await _context.Seats.FirstOrDefaultAsync(s => s.Id == request.SeatId);
            if (seat == null)
            {
                throw new InvalidOperationException("The specified seat does not exist.");
            }

            // Verify seat belongs to the same hall as the screening
            if (seat.HallId != screening.HallId)
            {
                throw new InvalidOperationException("The selected seat is not in the hall where the screening is taking place.");
            }

            // Check if seat is already booked for this screening
            var existingTicket = await _context.Tickets
                .FirstOrDefaultAsync(t => t.SeatId == request.SeatId && t.ScreeningId == request.ScreeningId && t.IsActive);

            if (existingTicket != null)
            {
                throw new InvalidOperationException("This seat is already booked for the selected screening.");
            }
        }

        protected override async Task BeforeUpdate(Ticket entity, TicketUpsertRequest request)
        {
            // Verify user exists and has User role
            var user = await _context.Users
                .Include(u => u.UserRoles)
                .ThenInclude(ur => ur.Role)
                .FirstOrDefaultAsync(u => u.Id == request.UserId);

            if (user == null)
            {
                throw new InvalidOperationException("The specified user does not exist.");
            }

            // Check if user has User role
            var hasUserRole = user.UserRoles.Any(ur => ur.Role.Name == "User");
            if (!hasUserRole)
            {
                throw new InvalidOperationException("Only users with User role can purchase tickets.");
            }

            // Verify screening exists
            var screening = await _context.Screenings
                .Include(s => s.Hall)
                .FirstOrDefaultAsync(s => s.Id == request.ScreeningId);

            if (screening == null)
            {
                throw new InvalidOperationException("The specified screening does not exist.");
            }

            // Verify seat exists
            var seat = await _context.Seats.FirstOrDefaultAsync(s => s.Id == request.SeatId);
            if (seat == null)
            {
                throw new InvalidOperationException("The specified seat does not exist.");
            }

            // Verify seat belongs to the same hall as the screening
            if (seat.HallId != screening.HallId)
            {
                throw new InvalidOperationException("The selected seat is not in the hall where the screening is taking place.");
            }

            // Check if seat is already booked for this screening (excluding current ticket)
            var existingTicket = await _context.Tickets
                .FirstOrDefaultAsync(t => t.SeatId == request.SeatId && t.ScreeningId == request.ScreeningId && t.IsActive && t.Id != entity.Id);

            if (existingTicket != null)
            {
                throw new InvalidOperationException("This seat is already booked for the selected screening.");
            }
        }
    }
}
