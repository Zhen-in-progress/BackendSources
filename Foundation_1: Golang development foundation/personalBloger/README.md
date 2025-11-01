# Personal Blogger API

A RESTful API service for a personal blog platform built with Go, Gin framework, and SQLite.

## Prerequisites

- Go 1.24.1 or higher
- Git (optional)

## Project Structure

```
personalBloger/
├── auth/           # Authentication controllers
├── model/          # Database models and initialization
├── routes/         # API route definitions
├── main.go         # Application entry point
├── go.mod          # Go module dependencies
└── blog.db         # SQLite database (created on first run)
```

## Getting Started

### 1. Install Dependencies

```bash
cd "/Users/zanepan/WebstormProjects/BackendSources/Foundation_1: Golang development foundation/personalBloger"
go mod download
```

### 2. Run the Server

```bash
go run main.go
```

The server will start on `http://localhost:8080`

You should see output like:
```
[GIN-debug] Listening and serving HTTP on :8080
```

### 3. Alternative: Build and Run

```bash
# Build the executable
go build -o personalBloger main.go

# Run the executable
./personalBloger
```

## API Endpoints

Base URL: `http://localhost:8080`

### Authentication

#### 1. Sign Up (Register)

Create a new user account.

**Endpoint:** `POST /v1/auth/signin`

**Request Body:**
```json
{
  "username": "john",
  "password": "secret123",
  "email": "john@example.com"
}
```

**Validation Rules:**
- `username`: required, 3-20 characters
- `password`: required, 8-20 characters
- `email`: required, valid email format

**Success Response (200 OK):**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": 1,
      "username": "john",
      "email": "john@example.com"
    }
  }
}
```

**Error Responses:**

400 Bad Request - Validation failed:
```json
{
  "error": "Key: 'signInRequest.Email' Error:Field validation for 'Email' failed on the 'email' tag"
}
```

400 Bad Request - Username exists:
```json
{
  "error": "Username already exists"
}
```

400 Bad Request - Email exists:
```json
{
  "error": "Email already exists"
}
```

#### 2. Login

Authenticate an existing user.

**Endpoint:** `POST /v1/auth/login`

**Request Body:**
```json
{
  "username": "john",
  "password": "secret123"
}
```

**Success Response (200 OK):**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": 1,
      "username": "john",
      "email": "john@example.com"
    }
  }
}
```

**Error Responses:**

400 Bad Request - Invalid credentials:
```json
{
  "error": "Invalid username or password"
}
```

401 Unauthorized - Wrong password:
```json
{
  "error": "Invalid username or password"
}
```

## Testing the API

### Using curl

#### 1. Sign Up
```bash
curl -X POST http://localhost:8080/v1/auth/signin \
  -H "Content-Type: application/json" \
  -d '{
    "username": "john",
    "password": "secret123",
    "email": "john@example.com"
  }'
```

#### 2. Login
```bash
curl -X POST http://localhost:8080/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "john",
    "password": "secret123"
  }'
```

#### 3. Save Token (for future protected routes)
```bash
# Copy the token from login response
TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

# Use it in future requests
curl -X GET http://localhost:8080/v1/profile \
  -H "Authorization: Bearer $TOKEN"
```

### Using Postman

1. **Create a new request**
2. **Set method to POST**
3. **Enter URL:** `http://localhost:8080/v1/auth/signin`
4. **Go to Body tab → raw → JSON**
5. **Enter request body:**
   ```json
   {
     "username": "john",
     "password": "secret123",
     "email": "john@example.com"
   }
   ```
6. **Click Send**

### Using HTTPie

```bash
# Install HTTPie (if not installed)
brew install httpie  # macOS
# or
pip install httpie   # Python

# Sign Up
http POST http://localhost:8080/v1/auth/signin \
  username=john \
  password=secret123 \
  email=john@example.com

# Login
http POST http://localhost:8080/v1/auth/login \
  username=john \
  password=secret123
```

### Using JavaScript (Fetch API)

```javascript
// Sign Up
fetch('http://localhost:8080/v1/auth/signin', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    username: 'john',
    password: 'secret123',
    email: 'john@example.com'
  })
})
.then(res => res.json())
.then(data => {
  console.log('Success:', data);
  // Store the token
  localStorage.setItem('token', data.data.token);
})
.catch(error => console.error('Error:', error));

// Login
fetch('http://localhost:8080/v1/auth/login', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    username: 'john',
    password: 'secret123'
  })
})
.then(res => res.json())
.then(data => {
  console.log('Success:', data);
  localStorage.setItem('token', data.data.token);
});

// Use token in future requests
const token = localStorage.getItem('token');
fetch('http://localhost:8080/v1/profile', {
  method: 'GET',
  headers: {
    'Authorization': `Bearer ${token}`
  }
})
.then(res => res.json())
.then(data => console.log(data));
```

## JWT Token

After successful login or signup, you'll receive a JWT token that:
- Expires in 24 hours
- Contains user ID and username
- Must be sent in the `Authorization` header for protected routes
- Format: `Authorization: Bearer <token>`

## Database

The application uses SQLite database (`blog.db`) which will be created automatically on first run.

### Tables

- **users**: User accounts
  - id (primary key)
  - username (unique)
  - email (unique)
  - password (hashed with bcrypt)
  - created_at
  - updated_at

- **posts**: Blog posts (future feature)
- **comments**: Post comments (future feature)

## Development

### Run with Auto-Reload

Install Air for hot reloading:

```bash
go install github.com/air-verse/air@latest

# Run with auto-reload
air
```

### View Database

```bash
# Install SQLite browser (macOS)
brew install --cask db-browser-for-sqlite

# Or use command line
sqlite3 blog.db
sqlite> .tables
sqlite> SELECT * FROM users;
sqlite> .quit
```

## Environment Variables

Currently using hardcoded values. For production, set these environment variables:

```bash
export JWT_SECRET="your-secret-key-here"
export PORT=8080
```

## Troubleshooting

### Port Already in Use

If port 8080 is already in use:

```bash
# Find and kill the process using port 8080
lsof -ti:8080 | xargs kill -9

# Or change the port in main.go
r.Run(":3000")  // Use port 3000 instead
```

### Database Locked Error

If you get "database is locked" error:

```bash
# Close all connections to blog.db and restart the server
rm blog.db  # This will delete the database and recreate it
```

### Module Import Errors

```bash
# Clean and re-download dependencies
go clean -modcache
go mod download
go mod tidy
```

## Security Notes

⚠️ **Important for Production:**

1. Change `"your_secret_key"` in auth.go to a strong random secret
2. Use environment variables for sensitive data
3. Enable HTTPS/TLS
4. Add rate limiting
5. Implement CORS properly
6. Add request validation middleware
7. Use proper logging
8. Never commit `.env` files to Git

## Next Steps

To add protected routes:

1. Create middleware to verify JWT tokens
2. Apply middleware to protected route groups
3. Access user info from context in controllers

Example protected route:
```go
protected := api.Group("")
protected.Use(middleware.AuthMiddleware())
{
    protected.GET("/profile", authController.GetProfile)
}
```

## License

MIT

## Contact

For questions or issues, please contact the development team.
