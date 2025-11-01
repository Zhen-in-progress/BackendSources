package controller

import (
	"personalBloger/model"
	"strconv"

	"github.com/gin-gonic/gin"
)

type PostController struct{}

type CreatePostRequest struct {
	Title   string `json:"title" binding:"required"`
	Content string `json:"content" binding:"required"`
}

type UpdatePostRequest struct {
	Title   string `json:"title" binding:"required"`
	Content string `json:"content" binding:"required"`
}

func (pc *PostController) CreatePost(c *gin.Context) {
	//verify jwt
	//create post with title and content
	var req CreatePostRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(400, gin.H{"error": err.Error()})
		return
	}
	//check if user exist
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(401, gin.H{"error": "User is not authenticated"})
		return
	}

	post := model.Post{
		Title:   req.Title,
		Content: req.Content,
		UserID:  userID.(uint),
	}
	if err := model.DB.Create(&post).Error; err != nil {
		c.JSON(500, gin.H{"error": "Failed to create a post"})
		return
	}
	c.JSON(200, gin.H{"success": "Post created successfully"})
}

func (pc *PostController) GetPostList(c *gin.Context) {
	user_id, exists := c.Get("user_id")
	if !exists {
		c.JSON(401, gin.H{"error": "User is not authenticated"})
		return
	}
	var posts []model.Post
	if err := model.DB.Where("user_id = ? ", user_id).Order("created_at DESC").Find(&posts).Error; err != nil {
		c.JSON(500, gin.H{"error": "Failed to get posts"})
		return
	}

	c.JSON(200, gin.H{
		"count": len(posts),
		"posts": posts,
	})
}

func (pc *PostController) GetPost(c *gin.Context) {
	postID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(400, gin.H{"error": "Invalid post ID"})
		return
	}
	var post model.Post
	if err := model.DB.Where("id = ?", postID).First(&post).Error; err != nil {
		c.JSON(404, gin.H{"error": "Post not found"})
		return
	}
	c.JSON(200, gin.H{
		"post": post,
	})
}

func (pc *PostController) UpdatePost(c *gin.Context) {
	postID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(400, gin.H{"error": "Invalid post ID"})
		return
	}

	var req UpdatePostRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(400, gin.H{"error": err.Error()})
		return
	}
	//check user_id
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(401, gin.H{"error": "User not authenticated"})
		return
	}
	// check post_id
	var post model.Post
	if err := model.DB.Where("id = ?", postID).First(&post).Error; err != nil {
		c.JSON(404, gin.H{"error": "Post not found"})
		return
	}
	// check if the person is the owner of the post
	if post.UserID != userID.(uint) {
		c.JSON(403, gin.H{"error": "You can only update your own post"})
		return
	}
	//update post
	post.Title = req.Title
	post.Content = req.Content
	if err := model.DB.Save(&post).Error; err != nil {
		c.JSON(500, gin.H{"error": "Failed to update post"})
		return
	}
	c.JSON(200, gin.H{"message": "Post updated successfully"})
}

func (pc *PostController) DeletePost(c *gin.Context) {
	postID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(400, gin.H{"error": "Invalid post ID"})
		return
	}
	//check user_id
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(401, gin.H{"error": "User not authenticated"})
		return
	}
	// check post_id
	var post model.Post
	if err := model.DB.Where("id = ?", postID).First(&post).Error; err != nil {
		c.JSON(404, gin.H{"error": "Post not found"})
		return
	}

	// check if the person is the owner of the post
	if post.UserID != userID.(uint) {
		c.JSON(403, gin.H{"error": "You can only delete your own post"})
		return
	}
	//delete post
	if err := model.DB.Delete(&post).Error; err != nil {
		c.JSON(500, gin.H{"error": "Failed to delete post"})
		return
	}
	c.JSON(200, gin.H{"message": "Post deleted successfully"})
}
