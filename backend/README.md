# Express.js Backend for Handwriting Learning App

A RESTful API backend built with Express.js and Supabase for the Children's Handwriting Learning App.

## Features

- ✅ RESTful API with Express.js
- ✅ Supabase integration for database operations
- ✅ JWT authentication via Supabase Auth
- ✅ Row Level Security (RLS) enforcement
- ✅ Comprehensive error handling
- ✅ CORS and security headers (Helmet)
- ✅ Request logging (Morgan)
- ✅ Environment-based configuration

## Project Structure

```
backend/
├── src/
│   ├── config/
│   │   ├── index.js           # Centralized configuration
│   │   └── supabase.js        # Supabase client setup
│   ├── controllers/
│   │   ├── childrenController.js    # Children CRUD operations
│   │   ├── practiceController.js    # Practice session management
│   │   └── progressController.js    # Progress tracking
│   ├── middleware/
│   │   ├── auth.js            # JWT authentication
│   │   └── errorHandler.js    # Error handling
│   ├── routes/
│   │   ├── index.js           # Main router
│   │   ├── children.js        # Children routes
│   │   ├── practice.js        # Practice routes
│   │   └── progress.js        # Progress routes
│   └── server.js              # Express app entry point
├── supabase/
│   └── migrations/            # Database migrations
├── .env.example               # Environment variables template
├── .gitignore
└── package.json
```

## Setup

### 1. Install Dependencies

```bash
cd backend
npm install
```

### 2. Configure Environment

Copy `.env.example` to `.env` and fill in your Supabase credentials:

```bash
cp .env.example .env
```

Edit `.env`:
```env
PORT=3000
NODE_ENV=development

SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080
```

### 3. Run Database Migrations

See [Supabase Setup Guide](../docs/database/SUPABASE_SETUP.md) for instructions on running migrations.

### 4. Start Server

**Development mode (with auto-reload):**
```bash
npm run dev
```

**Production mode:**
```bash
npm start
```

The server will start on `http://localhost:3000` (or your configured PORT).

## API Endpoints

### Base URL
```
http://localhost:3000/api/v1
```

### Authentication

All endpoints (except `/health`) require a valid Supabase JWT token in the Authorization header:

```
Authorization: Bearer <your-jwt-token>
```

### Endpoints

#### Health Check
```http
GET /api/v1/health
```
Returns API status.

#### Children Management

```http
GET    /api/v1/children              # Get all children for authenticated user
GET    /api/v1/children/:childId     # Get specific child
POST   /api/v1/children              # Create new child
PUT    /api/v1/children/:childId     # Update child
DELETE /api/v1/children/:childId     # Delete child
```

**Create Child Example:**
```json
POST /api/v1/children
{
  "child_name": "Emma",
  "age": 7,
  "avatar_url": "avatars/girl_1.png"
}
```

#### Practice Sessions

```http
GET  /api/v1/practice/:childId/sessions     # Get practice sessions
POST /api/v1/practice/:childId/sessions     # Create practice session
GET  /api/v1/practice/:childId/stats        # Get practice statistics
```

**Create Practice Session Example:**
```json
POST /api/v1/practice/:childId/sessions
{
  "character_type": "letter",
  "character_value": "A",
  "score": 85.5,
  "xp_earned": 10,
  "stars_earned": 2,
  "duration_seconds": 120
}
```

**Query Parameters for GET sessions:**
- `limit` - Number of sessions to return (default: 20)
- `offset` - Pagination offset (default: 0)
- `character_type` - Filter by type (letter/number)
- `character_value` - Filter by specific character

#### Progress Tracking

```http
GET /api/v1/progress/:childId/game-progress      # Get overall game progress
GET /api/v1/progress/:childId/character-mastery  # Get character mastery data
GET /api/v1/progress/:childId/character-stats    # Get character statistics
```

## Response Format

### Success Response
```json
{
  "success": true,
  "data": { ... }
}
```

### Error Response
```json
{
  "success": false,
  "error": "Error message"
}
```

## Authentication Flow

1. User signs up/logs in through Supabase Auth (client-side)
2. Client receives JWT token
3. Client includes token in Authorization header for API requests
4. Backend verifies token with Supabase
5. Backend enforces RLS policies (users can only access their own data)

## Security Features

- ✅ **Helmet.js** - Security headers
- ✅ **CORS** - Configurable allowed origins
- ✅ **JWT Verification** - All routes protected
- ✅ **RLS Enforcement** - Database-level security
- ✅ **Input Validation** - Request validation
- ✅ **Error Sanitization** - No sensitive data in errors

## Error Handling

The API uses consistent error responses:

- `400` - Bad Request (validation errors)
- `401` - Unauthorized (missing/invalid token)
- `404` - Not Found
- `409` - Conflict (duplicate resources)
- `500` - Internal Server Error

## Development

### Running with Nodemon

```bash
npm run dev
```

This will auto-reload the server when you make changes.

### Testing API Endpoints

You can use tools like:
- **Postman** - GUI for API testing
- **curl** - Command-line testing
- **Thunder Client** - VS Code extension

Example curl request:
```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
     http://localhost:3000/api/v1/children
```

## Database Integration

The backend uses Supabase client to interact with PostgreSQL:

- **RLS Policies** - Automatically enforced
- **Triggers** - Auto-update game progress and character mastery
- **Transactions** - Handled by Supabase
- **Connection Pooling** - Managed by Supabase

See [Database Schema Documentation](../docs/database/DATABASE_SCHEMA.md) for details.

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `PORT` | Server port | No (default: 3000) |
| `NODE_ENV` | Environment (development/production) | No (default: development) |
| `SUPABASE_URL` | Supabase project URL | Yes |
| `SUPABASE_ANON_KEY` | Supabase anon key | Yes |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase service role key | No |
| `ALLOWED_ORIGINS` | CORS allowed origins (comma-separated) | No |
| `API_VERSION` | API version | No (default: v1) |

## Deployment

### Recommended Platforms

- **Vercel** - Serverless deployment
- **Railway** - Container deployment
- **Heroku** - Platform as a Service
- **AWS/GCP/Azure** - Cloud platforms

### Environment Setup

Make sure to set all environment variables in your deployment platform.

### Production Checklist

- [ ] Set `NODE_ENV=production`
- [ ] Configure production `ALLOWED_ORIGINS`
- [ ] Use strong `SUPABASE_SERVICE_ROLE_KEY`
- [ ] Enable HTTPS
- [ ] Set up monitoring/logging
- [ ] Configure rate limiting (if needed)

## Troubleshooting

### "Missing Supabase environment variables"

Make sure `.env` file exists and contains `SUPABASE_URL` and `SUPABASE_ANON_KEY`.

### "Invalid or expired token"

The JWT token has expired. User needs to re-authenticate.

### "Child not found"

The child ID doesn't exist or doesn't belong to the authenticated user (RLS enforcement).

## Next Steps

1. ✅ Backend API created
2. 🔲 Integrate with Flutter app
3. 🔲 Add rate limiting
4. 🔲 Add request validation library (e.g., Joi)
5. 🔲 Add unit tests
6. 🔲 Deploy to production

## Documentation

- [Database Schema](../docs/database/DATABASE_SCHEMA.md)
- [Supabase Setup](../docs/database/SUPABASE_SETUP.md)
- [API Documentation](#api-endpoints) (this file)

## Support

For issues or questions, refer to:
- [Express.js Documentation](https://expressjs.com/)
- [Supabase Documentation](https://supabase.com/docs)
- Project documentation in `/docs`
