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
    public class OrderService : BaseCRUDService<OrderResponse, OrderSearchObject, Order, OrderUpsertRequest, OrderUpsertRequest>, IOrderService
    {
        public OrderService(CineVibeDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override OrderResponse MapToResponse(Order entity)
        {
            var orderItems = entity.OrderItems?.Select(oi => new OrderItemResponse
            {
                Id = oi.Id,
                Quantity = oi.Quantity,
                UnitPrice = oi.UnitPrice,
                TotalPrice = oi.TotalPrice,
                CreatedAt = oi.CreatedAt,
                OrderId = oi.OrderId,
                ProductId = oi.ProductId,
                ProductName = oi.Product?.Name ?? string.Empty,
                ProductPicture = oi.Product?.Picture
            }).ToList() ?? new List<OrderItemResponse>();

            return new OrderResponse
            {
                Id = entity.Id,
                TotalAmount = entity.TotalAmount,
                CreatedAt = entity.CreatedAt,
                IsActive = entity.IsActive,
                UserId = entity.UserId,
                UserFullName = $"{entity.User?.FirstName} {entity.User?.LastName}".Trim(),
                OrderItems = orderItems
            };
        }

        protected override IQueryable<Order> ApplyFilter(IQueryable<Order> query, OrderSearchObject search)
        {
            // Include navigation properties for proper mapping
            query = query.Include(o => o.User)
                         .Include(o => o.OrderItems)
                         .ThenInclude(oi => oi.Product);

            if (search.UserId.HasValue)
            {
                query = query.Where(o => o.UserId == search.UserId.Value);
            }

            if (search.MinTotalAmount.HasValue)
            {
                query = query.Where(o => o.TotalAmount >= search.MinTotalAmount.Value);
            }

            if (search.MaxTotalAmount.HasValue)
            {
                query = query.Where(o => o.TotalAmount <= search.MaxTotalAmount.Value);
            }

            if (search.CreatedFrom.HasValue)
            {
                query = query.Where(o => o.CreatedAt >= search.CreatedFrom.Value);
            }

            if (search.CreatedTo.HasValue)
            {
                query = query.Where(o => o.CreatedAt <= search.CreatedTo.Value);
            }

            if (search.IsActive.HasValue)
            {
                query = query.Where(o => o.IsActive == search.IsActive.Value);
            }

            return query;
        }

        public override async Task<OrderResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Set<Order>()
                .Include(o => o.User)
                .Include(o => o.OrderItems)
                .ThenInclude(oi => oi.Product)
                .FirstOrDefaultAsync(o => o.Id == id);

            if (entity == null)
                return null;

            return MapToResponse(entity);
        }

        public async Task<OrderResponse> CreateOrderFromCartAsync(int userId)
        {
            // Get user's cart
            var cart = await _context.Carts
                .Include(c => c.CartItems)
                .ThenInclude(ci => ci.Product)
                .FirstOrDefaultAsync(c => c.UserId == userId && c.IsActive);

            if (cart == null || !cart.CartItems.Any())
            {
                throw new InvalidOperationException("No active cart found or cart is empty.");
            }

            // Calculate total amount
            var totalAmount = cart.CartItems.Sum(ci => ci.Product.Price * ci.Quantity);

            // Create order
            var order = new Order
            {
                UserId = userId,
                TotalAmount = totalAmount,
                CreatedAt = DateTime.Now,
                IsActive = true
            };

            _context.Orders.Add(order);
            await _context.SaveChangesAsync(); // Save to get order ID

            // Create order items from cart items
            var orderItems = cart.CartItems.Select(ci => new OrderItem
            {
                OrderId = order.Id,
                ProductId = ci.ProductId,
                Quantity = ci.Quantity,
                UnitPrice = ci.Product.Price,
                TotalPrice = ci.Product.Price * ci.Quantity,
                CreatedAt = DateTime.Now
            }).ToList();

            _context.OrderItems.AddRange(orderItems);

            // Clear cart items after creating order
            _context.CartItems.RemoveRange(cart.CartItems);

            await _context.SaveChangesAsync();

            // Return the created order
            return await GetByIdAsync(order.Id) ?? throw new InvalidOperationException("Failed to retrieve created order.");
        }

        public async Task<List<OrderResponse>> GetOrdersByUserAsync(int userId)
        {
            var orders = await _context.Orders
                .Where(o => o.UserId == userId)
                .Include(o => o.User)
                .Include(o => o.OrderItems)
                .ThenInclude(oi => oi.Product)
                .OrderByDescending(o => o.CreatedAt)
                .ToListAsync();

            return orders.Select(o => MapToResponse(o)).ToList();
        }

        protected override async Task BeforeInsert(Order entity, OrderUpsertRequest request)
        {
            // Verify user exists
            var userExists = await _context.Users.AnyAsync(u => u.Id == request.UserId);
            if (!userExists)
            {
                throw new InvalidOperationException("The specified user does not exist.");
            }

            entity.CreatedAt = DateTime.Now;
        }

        protected override async Task BeforeUpdate(Order entity, OrderUpsertRequest request)
        {
            // Verify user exists
            var userExists = await _context.Users.AnyAsync(u => u.Id == request.UserId);
            if (!userExists)
            {
                throw new InvalidOperationException("The specified user does not exist.");
            }
        }
    }
}
