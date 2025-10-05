# CineVibe

A comprehensive cinema management system built with .NET Core Web API, Flutter for mobile/desktop applications, and integrated with RabbitMQ for real-time notifications and ML-based movie recommendations.

## 🎬 Project Overview

CineVibe is a full-stack cinema management platform that provides:
- **Admin Dashboard** (Desktop Flutter App) - Analytics, movie management, user administration
- **User Mobile App** (Flutter Mobile App) - Movie browsing, ticket booking, reviews
- **Backend API** (.NET Core) - RESTful API with authentication and business logic
- **Notification System** (RabbitMQ) - Real-time email notifications for new movie releases
- **ML Recommendation Engine** - Personalized movie recommendations using Matrix Factorization

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Desktop App   │    │   Mobile App    │    │   Web API       │
│   (Flutter)     │    │   (Flutter)     │    │   (.NET Core)   │
└─────────┬───────┘    └─────────┬───────┘    └─────────┬───────┘
          │                      │                      │
          └──────────────────────┼──────────────────────┘
                                 │
                    ┌─────────────┴─────────────┐
                    │                           │
            ┌───────▼───────┐           ┌───────▼───────┐
            │   SQL Server  │           │   RabbitMQ    │
            │   Database    │           │   (Messages)  │
            └───────────────┘           └───────────────┘
```

## 🚀 Quick Start

### Prerequisites
- .NET 8.0 SDK
- SQL Server 2022
- RabbitMQ 3.x
- Flutter SDK
- Docker

### Environment Setup

Create a `.env` file in the root directory:
```env
SQL__DATABASE=CineVibeDb
SQL__USER=sa
SQL__PASSWORD=QWEasd123!

RABBITMQ__HOST=localhost
RABBITMQ__USERNAME=guest
RABBITMQ__PASSWORD=guest
```

### Running with Docker Compose

```bash
# Start all services (API, Database, RabbitMQ, Notification Service)
docker-compose up --build

### Manual Setup

1. **Start SQL Server** (port 1401)
2. **Start RabbitMQ** (ports 5672, 15672)
3. **Run the API**:
   ```bash
   cd CineVibe/CineVibe.WebAPI
   dotnet run
   ```
4. **Run the Notification Service**:
   ```bash
   cd CineVibe/CineVibe.Subscriber
   dotnet run
   ```

## 🔐 Test Credentials

### Admin Access (Desktop App)
- **Username**: `admin`
- **Password**: `test`
- **Role**: Administrator (ID: 1)
- **Access**: Analytics dashboard, full system management

### User Access (Mobile App)
- **Username**: `user`
- **Password**: `test`
- **Role**: User (ID: 2)
- **Access**: Movie browsing, ticket booking, reviews

### Additional Test Accounts
- **Username**: `admin2` | **Password**: `test` (Admin role)
- **Username**: `user2` | **Password**: `test` (User role)
- **Email**: `cinevibe.reciever@gmail.com` | **Password**: `CineVibeR1!.` (for RabbitMQ testing)

## 📧 RabbitMQ Email Notifications

The system uses RabbitMQ to send email notifications when new movies are added:

### Configuration
- **Host**: `localhost` (or `RABBITMQ__HOST` env var)
- **Username**: `guest` (or `RABBITMQ__USERNAME` env var)
- **Password**: `guest` (or `RABBITMQ__PASSWORD` env var)
- **Port**: 5672 (AMQP), 15672 (Management UI)

### Testing Email Notifications
1. Login as admin in desktop app
2. Add a new movie
3. All users with "User" role will receive email notifications
4. Test email: `cinevibe.reciever@gmail.com` with password `CineVibeR1!`

### Notification Flow
```
Movie Created → MovieService → RabbitMQ → EmailSenderService → Gmail SMTP
```

## 🤖 ML-Based Movie Recommendation System

The system includes an advanced recommendation engine using Microsoft ML.NET:

### Algorithm: Matrix Factorization
- **Type**: Collaborative Filtering with Implicit Feedback
- **Training Data**: User ticket purchases + high-rated reviews (≥4 stars)
- **Features**: User-Movie interactions
- **Model**: Matrix Factorization with Square Loss One-Class

### How It Works

1. **Training Phase** (Automatic on startup):
   ```csharp
   // Combines ticket purchases and positive reviews
   var positiveEntries = db.Tickets.Select(t => new FeedbackEntry {
       UserId = t.UserId,
       MovieId = t.Screening.MovieId,
       Label = 1f
   });
   
   var positiveReviews = db.Reviews
       .Where(r => r.Rating >= 4)
       .Select(r => new FeedbackEntry {
           UserId = r.UserId,
           MovieId = r.Screening.MovieId,
           Label = 1f
       });
   ```

2. **Prediction Phase**:
   - Filters movies user hasn't watched
   - Only includes movies with available screenings
   - Scores all candidates using trained model
   - Returns highest-scoring movie

3. **Fallback System**:
   - If ML model unavailable, uses heuristic approach
   - Considers user's preferred genres, directors, actors
   - Prioritizes recent releases

### Recommendation API
```http
GET /api/Movie/RecommendForUser/{userId}
```

## 📱 Applications

### Desktop App (Admin)
- **Path**: `UI/cinevibe_desktop/`
- **Features**: Analytics, movie management, user administration
- **Login**: Admin credentials required

### Mobile App (User)
- **Path**: `UI/cinevibe_mobile/`
- **Features**: Movie browsing, ticket booking, reviews, recommendations
- **Login**: User credentials required

## 🗄️ Database Schema

Key entities:
- **Users** - Authentication and user management
- **Movies** - Movie catalog with relationships
- **Screenings** - Show times and availability
- **Tickets** - Booking system
- **Reviews** - User ratings and feedback
- **Actors, Directors, Genres** - Movie metadata

## 🔧 API Endpoints

### Authentication
- `POST /api/User/authenticate` - Login with username/password

### Movies
- `GET /api/Movie` - List movies with filtering
- `GET /api/Movie/{id}` - Get movie details
- `POST /api/Movie` - Create new movie (Admin)
- `GET /api/Movie/RecommendForUser/{userId}` - Get personalized recommendation

### Tickets & Bookings
- `GET /api/Ticket` - User's tickets
- `POST /api/Ticket` - Book new ticket

### Analytics (Admin)
- `GET /api/Analytics` - System analytics and reports

## 🐳 Docker Services

- **cinevibe-api**: Main API service (port 5130)
- **cinevibe-sql**: SQL Server database (port 1401)
- **rabbitmq**: Message broker (ports 5672, 15672)
- **cinevibe-rabbitmq**: Notification service (port 7111)

## 🔍 Development

### Project Structure
```
CineVibe/
├── CineVibe.Model/          # Data models, DTOs
├── CineVibe.Services/       # Business logic, database
├── CineVibe.WebAPI/         # REST API controllers
├── CineVibe.Subscriber/     # RabbitMQ notification service
├── UI/
│   ├── cinevibe_desktop/    # Flutter desktop app
│   └── cinevibe_mobile/     # Flutter mobile app
└── docker-compose.yml       # Container orchestration
```

### Key Technologies
- **Backend**: .NET 8, Entity Framework Core, ML.NET
- **Frontend**: Flutter (Mobile & Desktop)
- **Database**: SQL Server
- **Messaging**: RabbitMQ, EasyNetQ
- **Authentication**: Basic Authentication
- **Containerization**: Docker, Docker Compose

## 📊 Features

### Admin Features
- Movie catalog management
- User administration
- Analytics dashboard
- Screening management
- Revenue tracking

### User Features
- Browse movies with filters
- Book tickets
- Rate and review movies
- Receive personalized recommendations
- Email notifications for new releases

## 🚨 Troubleshooting

### Common Issues

1. **Database Connection**:
   - Ensure SQL Server is running on port 1401
   - Check connection string in `appsettings.json`

2. **RabbitMQ Connection**:
   - Verify RabbitMQ is running on ports 5672/15672
   - Check environment variables

3. **Email Notifications**:
   - Ensure internet connectivity to `smtp.gmail.com`
   - Verify Gmail credentials in notification service

4. **Recommendation System**:
   - Model trains automatically on startup
   - Requires user interaction data (tickets/reviews)
   - Falls back to heuristic if ML model fails

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

---

**CineVibe** - Bringing the cinema experience to the digital world! 🎭🍿