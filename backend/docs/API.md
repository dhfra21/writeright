# API Endpoints Documentation

## Base URL

```
http://localhost:3000/api/v1
```

## Authentication

All endpoints (except `/health`) require authentication via Supabase JWT token.

**Header:**
```
Authorization: Bearer <your-jwt-token>
```

## Endpoints

### Health Check

#### GET /health

Check API status.

**Response:**
```json
{
  "success": true,
  "message": "API is running",
  "timestamp": "2026-02-05T13:30:00.000Z"
}
```

---

## Children Management

### GET /children

Get all children for authenticated user.

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "account_id": "uuid",
      "child_name": "Emma",
      "age": 7,
      "avatar_url": "avatars/girl_1.png",
      "created_at": "2026-02-05T13:00:00.000Z",
      "updated_at": "2026-02-05T13:00:00.000Z"
    }
  ]
}
```

### GET /children/:childId

Get specific child by ID.

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "account_id": "uuid",
    "child_name": "Emma",
    "age": 7,
    "avatar_url": "avatars/girl_1.png",
    "created_at": "2026-02-05T13:00:00.000Z",
    "updated_at": "2026-02-05T13:00:00.000Z"
  }
}
```

### POST /children

Create new child profile.

**Request Body:**
```json
{
  "child_name": "Emma",
  "age": 7,
  "avatar_url": "avatars/girl_1.png"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "account_id": "uuid",
    "child_name": "Emma",
    "age": 7,
    "avatar_url": "avatars/girl_1.png",
    "created_at": "2026-02-05T13:00:00.000Z",
    "updated_at": "2026-02-05T13:00:00.000Z"
  }
}
```

### PUT /children/:childId

Update child profile.

**Request Body:**
```json
{
  "child_name": "Emma Updated",
  "age": 8,
  "avatar_url": "avatars/girl_2.png"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "account_id": "uuid",
    "child_name": "Emma Updated",
    "age": 8,
    "avatar_url": "avatars/girl_2.png",
    "created_at": "2026-02-05T13:00:00.000Z",
    "updated_at": "2026-02-05T13:30:00.000Z"
  }
}
```

### DELETE /children/:childId

Delete child profile (cascades to all related data).

**Response:**
```json
{
  "success": true,
  "message": "Child deleted successfully"
}
```

---

## Practice Sessions

### GET /practice/:childId/sessions

Get practice sessions for a child.

**Query Parameters:**
- `limit` (optional) - Number of sessions (default: 20)
- `offset` (optional) - Pagination offset (default: 0)
- `character_type` (optional) - Filter by 'letter' or 'number'
- `character_value` (optional) - Filter by specific character

**Example:**
```
GET /practice/uuid/sessions?limit=10&character_type=letter
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "child_id": "uuid",
      "character_type": "letter",
      "character_value": "A",
      "score": 85.5,
      "xp_earned": 10,
      "stars_earned": 2,
      "duration_seconds": 120,
      "session_date": "2026-02-05T13:00:00.000Z",
      "created_at": "2026-02-05T13:00:00.000Z"
    }
  ],
  "pagination": {
    "limit": 10,
    "offset": 0
  }
}
```

### POST /practice/:childId/sessions

Create new practice session.

**Request Body:**
```json
{
  "character_type": "letter",
  "character_value": "A",
  "score": 85.5,
  "xp_earned": 10,
  "stars_earned": 2,
  "duration_seconds": 120
}
```

**Validation:**
- `character_type`: Required, must be 'letter' or 'number'
- `character_value`: Required
- `score`: Required, must be 0-100
- `xp_earned`: Optional, defaults to 0
- `stars_earned`: Optional, defaults to 0, must be 0-3
- `duration_seconds`: Optional

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "child_id": "uuid",
    "character_type": "letter",
    "character_value": "A",
    "score": 85.5,
    "xp_earned": 10,
    "stars_earned": 2,
    "duration_seconds": 120,
    "session_date": "2026-02-05T13:00:00.000Z",
    "created_at": "2026-02-05T13:00:00.000Z"
  }
}
```

**Side Effects:**
- Automatically updates `game_progress` (XP, level, stars, streak)
- Automatically updates/creates `character_mastery` record

### GET /practice/:childId/stats

Get practice statistics for a child.

**Query Parameters:**
- `days` (optional) - Number of days to include (default: 30)

**Example:**
```
GET /practice/uuid/stats?days=7
```

**Response:**
```json
{
  "success": true,
  "data": {
    "total_sessions": 15,
    "total_xp": 150,
    "total_stars": 35,
    "average_score": 82.5,
    "by_character_type": {
      "letter": {
        "count": 10,
        "total_score": 850,
        "average_score": 85.0
      },
      "number": {
        "count": 5,
        "total_score": 400,
        "average_score": 80.0
      }
    }
  },
  "period_days": 7
}
```

---

## Progress Tracking

### GET /progress/:childId/game-progress

Get overall game progress for a child.

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "child_id": "uuid",
    "total_xp": 250,
    "current_level": 3,
    "total_stars": 45,
    "badges": [
      {
        "id": "first_star",
        "earned_at": "2026-02-05T13:00:00.000Z"
      }
    ],
    "last_practice_date": "2026-02-05",
    "streak_days": 5,
    "created_at": "2026-02-05T13:00:00.000Z",
    "updated_at": "2026-02-05T13:30:00.000Z"
  }
}
```

### GET /progress/:childId/character-mastery

Get character mastery data for a child.

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "child_id": "uuid",
      "character_type": "letter",
      "character_value": "A",
      "practice_count": 10,
      "average_score": 91.5,
      "best_score": 98.0,
      "mastery_level": "master",
      "last_practiced": "2026-02-05T13:00:00.000Z",
      "created_at": "2026-02-05T13:00:00.000Z",
      "updated_at": "2026-02-05T13:30:00.000Z"
    }
  ]
}
```

**Mastery Levels:**
- `beginner` - Default
- `intermediate` - 60+ avg score, 5+ practices
- `advanced` - 75+ avg score, 7+ practices
- `master` - 90+ avg score, 10+ practices

### GET /progress/:childId/character-stats

Get character mastery statistics.

**Response:**
```json
{
  "success": true,
  "data": {
    "total_characters": 15,
    "by_type": {
      "letter": 10,
      "number": 5
    },
    "by_mastery": {
      "beginner": 5,
      "intermediate": 4,
      "advanced": 3,
      "master": 3
    }
  }
}
```

---

## Error Responses

### 400 Bad Request
```json
{
  "success": false,
  "error": "Validation error message"
}
```

### 401 Unauthorized
```json
{
  "success": false,
  "error": "Missing or invalid authorization header"
}
```

### 404 Not Found
```json
{
  "success": false,
  "error": "Resource not found"
}
```

### 409 Conflict
```json
{
  "success": false,
  "error": "Resource already exists"
}
```

### 500 Internal Server Error
```json
{
  "success": false,
  "error": "Internal server error"
}
```

---

## Rate Limiting

Currently not implemented. Consider adding rate limiting for production.

## CORS

Configured via `ALLOWED_ORIGINS` environment variable.

## Security

- All routes (except `/health`) require authentication
- JWT tokens verified via Supabase
- RLS policies enforced at database level
- Helmet.js for security headers
