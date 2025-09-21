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
    public class ReviewService : BaseCRUDService<ReviewResponse, ReviewSearchObject, Review, ReviewUpsertRequest, ReviewUpsertRequest>, IReviewService
    {
        public ReviewService(CineVibeDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override ReviewResponse MapToResponse(Review entity)
        {
            return new ReviewResponse
            {
                Id = entity.Id,
                Rating = entity.Rating,
                Comment = entity.Comment,
                IsActive = entity.IsActive,
                CreatedAt = entity.CreatedAt,
                ScreeningId = entity.ScreeningId,
                ScreeningStartTime = entity.Screening?.StartTime ?? DateTime.MinValue,
                MovieTitle = entity.Screening?.Movie?.Title ?? string.Empty,
                HallName = entity.Screening?.Hall?.Name ?? string.Empty,
                ScreeningTypeName = entity.Screening?.ScreeningType?.Name ?? string.Empty,
                UserId = entity.UserId,
                UserFullName = $"{entity.User?.FirstName} {entity.User?.LastName}".Trim()
            };
        }

        protected override IQueryable<Review> ApplyFilter(IQueryable<Review> query, ReviewSearchObject search)
        {
            // Include navigation properties for proper mapping
            query = query.Include(r => r.Screening)
                         .ThenInclude(s => s.Movie)
                         .Include(r => r.Screening)
                         .ThenInclude(s => s.Hall)
                         .Include(r => r.Screening)
                         .ThenInclude(s => s.ScreeningType)
                         .Include(r => r.User);

            if (search.UserId.HasValue)
            {
                query = query.Where(r => r.UserId == search.UserId.Value);
            }

            if (search.ScreeningId.HasValue)
            {
                query = query.Where(r => r.ScreeningId == search.ScreeningId.Value);
            }

            if (search.MovieId.HasValue)
            {
                query = query.Where(r => r.Screening.MovieId == search.MovieId.Value);
            }

            if (search.HallId.HasValue)
            {
                query = query.Where(r => r.Screening.HallId == search.HallId.Value);
            }

            if (search.MinRating.HasValue)
            {
                query = query.Where(r => r.Rating >= search.MinRating.Value);
            }

            if (search.MaxRating.HasValue)
            {
                query = query.Where(r => r.Rating <= search.MaxRating.Value);
            }

            if (search.ScreeningDateFrom.HasValue)
            {
                query = query.Where(r => r.Screening.StartTime.Date >= search.ScreeningDateFrom.Value.Date);
            }

            if (search.ScreeningDateTo.HasValue)
            {
                query = query.Where(r => r.Screening.StartTime.Date <= search.ScreeningDateTo.Value.Date);
            }

            if (search.IsActive.HasValue)
            {
                query = query.Where(r => r.IsActive == search.IsActive.Value);
            }

            return query;
        }

        public override async Task<ReviewResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Set<Review>()
                .Include(r => r.Screening)
                .ThenInclude(s => s.Movie)
                .Include(r => r.Screening)
                .ThenInclude(s => s.Hall)
                .Include(r => r.Screening)
                .ThenInclude(s => s.ScreeningType)
                .Include(r => r.User)
                .FirstOrDefaultAsync(r => r.Id == id);

            if (entity == null)
                return null;

            return MapToResponse(entity);
        }

        protected override async Task BeforeInsert(Review entity, ReviewUpsertRequest request)
        {
            // Verify user exists
            var userExists = await _context.Users.AnyAsync(u => u.Id == request.UserId);
            if (!userExists)
            {
                throw new InvalidOperationException("The specified user does not exist.");
            }

            // Verify screening exists
            var screeningExists = await _context.Screenings.AnyAsync(s => s.Id == request.ScreeningId);
            if (!screeningExists)
            {
                throw new InvalidOperationException("The specified screening does not exist.");
            }

            // Check if user has purchased a ticket for this screening
            var hasTicket = await _context.Tickets
                .AnyAsync(t => t.UserId == request.UserId && t.ScreeningId == request.ScreeningId && t.IsActive);

            if (!hasTicket)
            {
                throw new InvalidOperationException("You can only review screenings for which you have purchased a ticket.");
            }

            // Check if user has already reviewed this screening
            var existingReview = await _context.Reviews
                .FirstOrDefaultAsync(r => r.UserId == request.UserId && r.ScreeningId == request.ScreeningId && r.IsActive);

            if (existingReview != null)
            {
                throw new InvalidOperationException("You have already reviewed this screening.");
            }
        }

        protected override async Task BeforeUpdate(Review entity, ReviewUpsertRequest request)
        {
            // Verify user exists
            var userExists = await _context.Users.AnyAsync(u => u.Id == request.UserId);
            if (!userExists)
            {
                throw new InvalidOperationException("The specified user does not exist.");
            }

            // Verify screening exists
            var screeningExists = await _context.Screenings.AnyAsync(s => s.Id == request.ScreeningId);
            if (!screeningExists)
            {
                throw new InvalidOperationException("The specified screening does not exist.");
            }

            // Check if user has purchased a ticket for this screening
            var hasTicket = await _context.Tickets
                .AnyAsync(t => t.UserId == request.UserId && t.ScreeningId == request.ScreeningId && t.IsActive);

            if (!hasTicket)
            {
                throw new InvalidOperationException("You can only review screenings for which you have purchased a ticket.");
            }

            // Check if user has already reviewed this screening (excluding current review)
            var existingReview = await _context.Reviews
                .FirstOrDefaultAsync(r => r.UserId == request.UserId && r.ScreeningId == request.ScreeningId && r.IsActive && r.Id != entity.Id);

            if (existingReview != null)
            {
                throw new InvalidOperationException("You have already reviewed this screening.");
            }
        }
    }
}
