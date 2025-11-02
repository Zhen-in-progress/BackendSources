# Personal Blogger API

A RESTful API service for a personal blog platform built with Go, Gin framework, and SQLite. Features include user authentication with JWT, post management, and comment functionality.

## Features

- User authentication (registration & login) with JWT tokens
- Password encryption using bcrypt
- Blog post CRUD operations
- Comment system for posts
- Authorization checks (only authors can modify their posts)
- Request/response logging middleware
- SQLite database with GORM ORM

## Prerequisites

- Go 1.24.1 or higher
- Git (optional)

## Project Structure

```
personalBloger/
├── auth/           # Authentication controllers
├── controller/     # Post and comment controllers
├── middleware/     # Auth and logger middleware
├── model/          # Database models and initialization
├── routes/         # API route definitions
├── main.go         # Application entry point
├── test_api.sh     # Comprehensive API test script
├── go.mod          # Go module dependencies
├── .gitignore      # Git ignore file
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
go build -o personalBloger

# Run the executable
./personalBloger
```

### 4. Run API Tests

```bash
# Make the test script executable
chmod +x test_api.sh

# Run all API tests
./test_api.sh
```

## API Endpoints

Base URL: `http://localhost:8080/v1`

### Authentication

#### Register a New User

**Endpoint:** `POST /v1/auth/signin`

**Request Body:**
```json
{
  "username": "alice",
  "password": "password123",
  "email": "alice@example.com"
}
```

**Validation Rules:**
- `username`: required, 3-20 characters
- `password`: required, 8-20 characters (automatically encrypted)
- `email`: required, valid email format

**Success Response (200 OK):**
```json
{
  "success": "Sign in successful"
}
```

**Error Responses:**

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

#### Login

**Endpoint:** `POST /v1/auth/login`

**Request Body:**
```json
{
  "username": "alice",
  "password": "password123"
}
```

**Success Response (200 OK):**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "Token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "User": {
      "ID": 1,
      "CreatedAt": "2025-11-02T16:34:40.600159+11:00",
      "UpdatedAt": "2025-11-02T16:34:40.600159+11:00",
      "DeletedAt": null,
      "username": "alice",
      "password": "$2a$10$...",
      "email": "alice@example.com"
    }
  }
}
```

**Error Response (401 Unauthorized):**
```json
{
  "error": "Invalid username or password"
}
```

### Post Management

#### Create a Post (Authenticated)

**Endpoint:** `POST /v1/post`

**Headers:**
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

**Request Body:**
```json
{
  "title": "My First Blog Post",
  "content": "This is the content of my blog post"
}
```

**Success Response (200 OK):**
```json
{
  "success": "Post created successfully"
}
```

**Error Response (401 Unauthorized):**
```json
{
  "error": "Authorization header is required"
}
```

#### Get All Posts for a User (Public)

**Endpoint:** `GET /v1/postlist?user_id=<USER_ID>`

**Query Parameters:**
- `user_id`: Required, the ID of the user whose posts to retrieve

**Success Response (200 OK):**
```json
{
  "count": 2,
  "posts": [
    {
      "ID": 2,
      "CreatedAt": "2025-11-02T16:34:40.927126+11:00",
      "UpdatedAt": "2025-11-02T16:34:40.927126+11:00",
      "DeletedAt": null,
      "user_id": 1,
      "title": "Learning Golang",
      "content": "Golang is a powerful programming language"
    },
    {
      "ID": 1,
      "CreatedAt": "2025-11-02T16:34:40.902748+11:00",
      "UpdatedAt": "2025-11-02T16:34:40.902748+11:00",
      "DeletedAt": null,
      "user_id": 1,
      "title": "My First Blog Post",
      "content": "This is the content of my first blog post"
    }
  ]
}
```

#### Get a Single Post (Public)

**Endpoint:** `GET /v1/post/:id`

**Success Response (200 OK):**
```json
{
  "post": {
    "ID": 1,
    "CreatedAt": "2025-11-02T16:34:40.902748+11:00",
    "UpdatedAt": "2025-11-02T16:34:40.902748+11:00",
    "DeletedAt": null,
    "user_id": 1,
    "title": "My First Blog Post",
    "content": "This is the content of my first blog post"
  }
}
```

**Error Response (404 Not Found):**
```json
{
  "error": "Post not found"
}
```

#### Update a Post (Author Only)

**Endpoint:** `PUT /v1/post/:id`

**Headers:**
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

**Request Body:**
```json
{
  "title": "Updated Title",
  "content": "Updated content"
}
```

**Success Response (200 OK):**
```json
{
  "message": "Post updated successfully"
}
```

**Error Response (403 Forbidden):**
```json
{
  "error": "You can only update your own post"
}
```

#### Delete a Post (Author Only)

**Endpoint:** `DELETE /v1/post/:id`

**Headers:**
```
Authorization: Bearer <JWT_TOKEN>
```

**Success Response (200 OK):**
```json
{
  "message": "Post deleted successfully"
}
```

**Error Response (403 Forbidden):**
```json
{
  "error": "You can only delete your own post"
}
```

### Comment Management

#### Create a Comment (Authenticated)

**Endpoint:** `POST /v1/comment`

**Headers:**
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

**Request Body:**
```json
{
  "post_id": 1,
  "content": "Great post! Very informative."
}
```

**Success Response (201 Created):**
```json
{
  "message": "Comment created successfully"
}
```

**Error Response (404 Not Found):**
```json
{
  "error": "Post not found"
}
```

#### Get Comments for a Post (Public)

**Endpoint:** `GET /v1/post/:id/comment`

**Success Response (200 OK):**
```json
{
  "count": 2,
  "comments": [
    {
      "ID": 1,
      "CreatedAt": "2025-11-02T16:34:41.016078+11:00",
      "UpdatedAt": "2025-11-02T16:34:41.016078+11:00",
      "DeletedAt": null,
      "post_id": 1,
      "user_id": 1,
      "content": "Great post! Very informative."
    },
    {
      "ID": 2,
      "CreatedAt": "2025-11-02T16:34:41.037845+11:00",
      "UpdatedAt": "2025-11-02T16:34:41.037845+11:00",
      "DeletedAt": null,
      "post_id": 1,
      "user_id": 1,
      "content": "Thanks for sharing this knowledge!"
    }
  ]
}
```

## Testing the API

### Using the Test Script

The project includes a comprehensive test script that tests all endpoints:

```bash
./test_api.sh
```

This will test:
- User registration and login
- Post creation, reading, updating, and deletion
- Comment creation and reading
- Authorization checks (non-authors cannot modify posts)
- Authentication validation

### Manual Testing with curl

#### 1. Register a User
```bash
curl -X POST http://localhost:8080/v1/auth/signin \
  -H "Content-Type: application/json" \
  -d '{
    "username": "alice",
    "password": "password123",
    "email": "alice@example.com"
  }'
```

#### 2. Login and Get Token
```bash
curl -X POST http://localhost:8080/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "alice",
    "password": "password123"
  }'
```

#### 3. Create a Post (Save token from login first)
```bash
TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

curl -X POST http://localhost:8080/v1/post \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "title": "My Blog Post",
    "content": "This is my post content"
  }'
```

#### 4. Get All Posts for User
```bash
curl -X GET "http://localhost:8080/v1/postlist?user_id=1"
```

#### 5. Get a Single Post
```bash
curl -X GET http://localhost:8080/v1/post/1
```

#### 6. Update a Post
```bash
curl -X PUT http://localhost:8080/v1/post/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "title": "Updated Title",
    "content": "Updated content"
  }'
```

#### 7. Create a Comment
```bash
curl -X POST http://localhost:8080/v1/comment \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "post_id": 1,
    "content": "Great article!"
  }'
```

#### 8. Get Comments for a Post
```bash
curl -X GET http://localhost:8080/v1/post/1/comment
```

#### 9. Delete a Post
```bash
curl -X DELETE http://localhost:8080/v1/post/1 \
  -H "Authorization: Bearer $TOKEN"
```

### Using Postman

1. Import the endpoints above
2. Set `Authorization` header to `Bearer <token>` for protected routes
3. Set `Content-Type` to `application/json` for POST/PUT requests

## JWT Token

After successful login, you'll receive a JWT token that:
- Expires in 24 hours
- Contains user ID and username
- Must be sent in the `Authorization` header for protected routes
- Format: `Authorization: Bearer <token>`

## Database

The application uses SQLite database (`blog.db`) which will be created automatically on first run.

### Tables

- **users**: User accounts
  - ID (primary key)
  - Username (unique)
  - Email (unique)
  - Password (hashed with bcrypt)
  - CreatedAt, UpdatedAt, DeletedAt

- **posts**: Blog posts
  - ID (primary key)
  - UserID (foreign key to users)
  - Title
  - Content
  - CreatedAt, UpdatedAt, DeletedAt

- **comments**: Post comments
  - ID (primary key)
  - PostID (foreign key to posts)
  - UserID (foreign key to users)
  - Content
  - CreatedAt, UpdatedAt, DeletedAt

### View Database

```bash
# Install SQLite browser (macOS)
brew install --cask db-browser-for-sqlite

# Or use command line
sqlite3 blog.db
sqlite> .tables
sqlite> SELECT * FROM users;
sqlite> SELECT * FROM posts;
sqlite> SELECT * FROM comments;
sqlite> .quit
```

## Middleware

### Logger Middleware

All requests are logged with the following information:
- Client IP address
- HTTP method and path
- Status code
- Request duration (in milliseconds)
- User agent
- User ID and username (if authenticated)
- Errors (if any)

Logs are output in JSON format for easy parsing by log aggregation tools.

### Auth Middleware

Protected routes require a valid JWT token in the Authorization header:
```
Authorization: Bearer <token>
```

The middleware:
- Validates the JWT token
- Checks token expiration
- Extracts user information (user_id, username)
- Makes user info available to controllers via context

## Development

### Run with Auto-Reload

Install Air for hot reloading:

```bash
go install github.com/air-verse/air@latest

# Run with auto-reload
air
```

### Clean Database

To start fresh with a clean database:

```bash
# Stop the server first
rm blog.db

# Restart the server - it will create a new database
go run main.go
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

1. Change `"your_secret_key"` in auth/auth.go and middleware/auth.go to a strong random secret
2. Use environment variables for sensitive data (JWT secret, database credentials)
3. Enable HTTPS/TLS
4. Add rate limiting to prevent abuse
5. Implement CORS properly for frontend integration
6. Add input sanitization to prevent XSS attacks
7. Never commit `.env` files or `blog.db` to Git (already in .gitignore)
8. Use prepared statements to prevent SQL injection (GORM handles this)
9. Set appropriate password complexity requirements
10. Add email verification for user registration

## Production Deployment

For production deployment:

1. Set environment variables:
```bash
export JWT_SECRET="your-super-secret-key-change-this"
export GIN_MODE=release
export PORT=8080
```

2. Build the binary:
```bash
go build -o personalBloger
```

3. Run with production settings:
```bash
./personalBloger
```

## Dependencies

- **gin-gonic/gin**: Web framework
- **gorm.io/gorm**: ORM library
- **gorm.io/driver/sqlite**: SQLite driver
- **dgrijalva/jwt-go**: JWT token generation and validation
- **golang.org/x/crypto/bcrypt**: Password hashing
- **sirupsen/logrus**: Structured logging

## License

MIT

## Contributing

Feel free to submit issues and enhancement requests!

## Contact

For questions or issues, please create an issue in the repository.
