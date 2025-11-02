#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

BASE_URL="http://localhost:8080"
echo "=================================="
echo "API Testing Script"
echo "=================================="
echo ""

# Test 1: User Registration
echo -e "${YELLOW}Test 1: User Registration${NC}"
echo "POST $BASE_URL/v1/auth/signin"
REGISTER_RESPONSE=$(curl -s -X POST $BASE_URL/v1/auth/signin \
  -H "Content-Type: application/json" \
  -d '{"username": "alice", "password": "password123", "email": "alice@example.com"}')
echo "Response: $REGISTER_RESPONSE"
if echo "$REGISTER_RESPONSE" | grep -q "success"; then
    echo -e "${GREEN}✓ PASSED${NC}"
else
    echo -e "${RED}✗ FAILED${NC}"
fi
echo ""

# Test 2: User Login
echo -e "${YELLOW}Test 2: User Login${NC}"
echo "POST $BASE_URL/v1/auth/login"
LOGIN_RESPONSE=$(curl -s -X POST $BASE_URL/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "alice", "password": "password123"}')
echo "Response: $LOGIN_RESPONSE"
if echo "$LOGIN_RESPONSE" | grep -q "Token"; then
    echo -e "${GREEN}✓ PASSED${NC}"
else
    echo -e "${RED}✗ FAILED${NC}"
fi
echo ""

# Extract JWT token
TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"Token":"[^"]*"' | cut -d'"' -f4)
USER_ID=$(echo $LOGIN_RESPONSE | grep -o '"ID":[0-9]*' | cut -d':' -f2)
echo -e "${BLUE}JWT Token: ${TOKEN:0:50}...${NC}"
echo -e "${BLUE}User ID: $USER_ID${NC}"
echo ""

# Test 3: Create Post (authenticated)
echo -e "${YELLOW}Test 3: Create Post (Authenticated)${NC}"
echo "POST $BASE_URL/v1/post"
CREATE_POST_RESPONSE=$(curl -s -X POST $BASE_URL/v1/post \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"title": "My First Blog Post", "content": "This is the content of my first blog post"}')
echo "Response: $CREATE_POST_RESPONSE"
if echo "$CREATE_POST_RESPONSE" | grep -q "success"; then
    echo -e "${GREEN}✓ PASSED${NC}"
else
    echo -e "${RED}✗ FAILED${NC}"
fi
echo ""

# Test 4: Create another post
echo -e "${YELLOW}Test 4: Create Second Post${NC}"
CREATE_POST2_RESPONSE=$(curl -s -X POST $BASE_URL/v1/post \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"title": "Learning Golang", "content": "Golang is a powerful programming language"}')
echo "Response: $CREATE_POST2_RESPONSE"
if echo "$CREATE_POST2_RESPONSE" | grep -q "success"; then
    echo -e "${GREEN}✓ PASSED${NC}"
else
    echo -e "${RED}✗ FAILED${NC}"
fi
echo ""

# Test 5: Get Post List (public)
echo -e "${YELLOW}Test 5: Get Post List (Public)${NC}"
echo "GET $BASE_URL/v1/postlist?user_id=$USER_ID"
GET_POSTS_RESPONSE=$(curl -s -X GET "$BASE_URL/v1/postlist?user_id=$USER_ID")
echo "Response: $GET_POSTS_RESPONSE"
if echo "$GET_POSTS_RESPONSE" | grep -q "posts"; then
    echo -e "${GREEN}✓ PASSED${NC}"
else
    echo -e "${RED}✗ FAILED${NC}"
fi
echo ""

# Test 6: Get Single Post (public)
echo -e "${YELLOW}Test 6: Get Single Post (Public)${NC}"
echo "GET $BASE_URL/v1/post/1"
GET_POST_RESPONSE=$(curl -s -X GET $BASE_URL/v1/post/1)
echo "Response: $GET_POST_RESPONSE"
if echo "$GET_POST_RESPONSE" | grep -q "My First Blog Post"; then
    echo -e "${GREEN}✓ PASSED${NC}"
else
    echo -e "${RED}✗ FAILED${NC}"
fi
echo ""

# Test 7: Update Post (author only)
echo -e "${YELLOW}Test 7: Update Post (Author Only)${NC}"
echo "PUT $BASE_URL/v1/post/1"
UPDATE_POST_RESPONSE=$(curl -s -X PUT "$BASE_URL/v1/post/1" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"title": "My Updated Blog Post", "content": "This content has been updated successfully"}')
echo "Response: $UPDATE_POST_RESPONSE"
if echo "$UPDATE_POST_RESPONSE" | grep -q "success"; then
    echo -e "${GREEN}✓ PASSED${NC}"
else
    echo -e "${RED}✗ FAILED${NC}"
fi
echo ""

# Test 8: Create Comment (authenticated)
echo -e "${YELLOW}Test 8: Create Comment (Authenticated)${NC}"
echo "POST $BASE_URL/v1/comment"
CREATE_COMMENT_RESPONSE=$(curl -s -X POST $BASE_URL/v1/comment \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"post_id": 1, "content": "Great post! Very informative."}')
echo "Response: $CREATE_COMMENT_RESPONSE"
if echo "$CREATE_COMMENT_RESPONSE" | grep -q "success"; then
    echo -e "${GREEN}✓ PASSED${NC}"
else
    echo -e "${RED}✗ FAILED${NC}"
fi
echo ""

# Test 9: Create another comment
echo -e "${YELLOW}Test 9: Create Second Comment${NC}"
CREATE_COMMENT2_RESPONSE=$(curl -s -X POST $BASE_URL/v1/comment \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"post_id": 1, "content": "Thanks for sharing this knowledge!"}')
echo "Response: $CREATE_COMMENT2_RESPONSE"
if echo "$CREATE_COMMENT2_RESPONSE" | grep -q "success"; then
    echo -e "${GREEN}✓ PASSED${NC}"
else
    echo -e "${RED}✗ FAILED${NC}"
fi
echo ""

# Test 10: Get Comments for a Post (public)
echo -e "${YELLOW}Test 10: Get Comments for Post (Public)${NC}"
echo "GET $BASE_URL/v1/post/1/comment"
GET_COMMENTS_RESPONSE=$(curl -s -X GET $BASE_URL/v1/post/1/comment)
echo "Response: $GET_COMMENTS_RESPONSE"
if echo "$GET_COMMENTS_RESPONSE" | grep -q "comments"; then
    echo -e "${GREEN}✓ PASSED${NC}"
else
    echo -e "${RED}✗ FAILED${NC}"
fi
echo ""

# Test 11: Delete Post (author only)
echo -e "${YELLOW}Test 11: Delete Post (Author Only)${NC}"
echo "DELETE $BASE_URL/v1/post/2"
DELETE_POST_RESPONSE=$(curl -s -X DELETE "$BASE_URL/v1/post/2" \
  -H "Authorization: Bearer $TOKEN")
echo "Response: $DELETE_POST_RESPONSE"
if echo "$DELETE_POST_RESPONSE" | grep -q "success"; then
    echo -e "${GREEN}✓ PASSED${NC}"
else
    echo -e "${RED}✗ FAILED${NC}"
fi
echo ""

# Test 12: Verify post was deleted
echo -e "${YELLOW}Test 12: Verify Post Deleted${NC}"
echo "GET $BASE_URL/v1/post/2"
GET_DELETED_POST=$(curl -s -X GET $BASE_URL/v1/post/2)
echo "Response: $GET_DELETED_POST"
if echo "$GET_DELETED_POST" | grep -q "not found"; then
    echo -e "${GREEN}✓ PASSED - Post successfully deleted${NC}"
else
    echo -e "${RED}✗ FAILED - Post still exists${NC}"
fi
echo ""

# Test 13: Test authentication failure
echo -e "${YELLOW}Test 13: Create Post without Auth (Should Fail)${NC}"
echo "POST $BASE_URL/v1/post (no token)"
NO_AUTH_RESPONSE=$(curl -s -X POST $BASE_URL/v1/post \
  -H "Content-Type: application/json" \
  -d '{"title": "Unauthorized Post", "content": "This should fail"}')
echo "Response: $NO_AUTH_RESPONSE"
if echo "$NO_AUTH_RESPONSE" | grep -q "error"; then
    echo -e "${GREEN}✓ PASSED - Correctly rejected${NC}"
else
    echo -e "${RED}✗ FAILED - Should have been rejected${NC}"
fi
echo ""

# Test 14: Test update post by non-author (should fail)
echo -e "${YELLOW}Test 14: Register Second User${NC}"
REGISTER2_RESPONSE=$(curl -s -X POST $BASE_URL/v1/auth/signin \
  -H "Content-Type: application/json" \
  -d '{"username": "bob", "password": "password123", "email": "bob@example.com"}')
echo "Response: $REGISTER2_RESPONSE"
if echo "$REGISTER2_RESPONSE" | grep -q "success"; then
    echo -e "${GREEN}✓ PASSED${NC}"
else
    echo -e "${RED}✗ FAILED${NC}"
fi
echo ""

echo -e "${YELLOW}Test 15: Login Second User${NC}"
LOGIN2_RESPONSE=$(curl -s -X POST $BASE_URL/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "bob", "password": "password123"}')
TOKEN2=$(echo $LOGIN2_RESPONSE | grep -o '"Token":"[^"]*"' | cut -d'"' -f4)
echo "Response: $LOGIN2_RESPONSE"
if echo "$LOGIN2_RESPONSE" | grep -q "Token"; then
    echo -e "${GREEN}✓ PASSED${NC}"
else
    echo -e "${RED}✗ FAILED${NC}"
fi
echo ""

echo -e "${YELLOW}Test 16: Update Post by Non-Author (Should Fail)${NC}"
echo "PUT $BASE_URL/v1/post/1 (with Bob's token)"
UNAUTHORIZED_UPDATE=$(curl -s -X PUT "$BASE_URL/v1/post/1" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN2" \
  -d '{"title": "Hacked Post", "content": "This should not work"}')
echo "Response: $UNAUTHORIZED_UPDATE"
if echo "$UNAUTHORIZED_UPDATE" | grep -q "only update your own"; then
    echo -e "${GREEN}✓ PASSED - Correctly prevented unauthorized update${NC}"
else
    echo -e "${RED}✗ FAILED - Should have been prevented${NC}"
fi
echo ""

echo -e "${YELLOW}Test 17: Delete Post by Non-Author (Should Fail)${NC}"
echo "DELETE $BASE_URL/v1/post/1 (with Bob's token)"
UNAUTHORIZED_DELETE=$(curl -s -X DELETE "$BASE_URL/v1/post/1" \
  -H "Authorization: Bearer $TOKEN2")
echo "Response: $UNAUTHORIZED_DELETE"
if echo "$UNAUTHORIZED_DELETE" | grep -q "only delete your own"; then
    echo -e "${GREEN}✓ PASSED - Correctly prevented unauthorized delete${NC}"
else
    echo -e "${RED}✗ FAILED - Should have been prevented${NC}"
fi
echo ""

echo -e "${YELLOW}Test 18: Invalid Login Credentials${NC}"
INVALID_LOGIN=$(curl -s -X POST $BASE_URL/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "alice", "password": "wrongpassword"}')
echo "Response: $INVALID_LOGIN"
if echo "$INVALID_LOGIN" | grep -q "error"; then
    echo -e "${GREEN}✓ PASSED - Correctly rejected wrong password${NC}"
else
    echo -e "${RED}✗ FAILED - Should reject wrong password${NC}"
fi
echo ""

echo "=================================="
echo -e "${GREEN}All API Tests Completed!${NC}"
echo "=================================="
