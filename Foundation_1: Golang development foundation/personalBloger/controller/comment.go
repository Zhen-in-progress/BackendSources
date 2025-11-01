package controller

import (
	"personalBloger/model"
	"strconv"

	"github.com/gin-gonic/gin"
)

type CommentController struct{}

type CreateCommentRequest struct {
	PostID  uint   `json:"post_id" gorm:"not null;index"`
	Content string `json:"content" binding:"required"`
}

func (cc *CommentController) CreateComment(c *gin.Context) {
	//create post with title and content
	var req CreateCommentRequest
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

	// Validate that the post exists
	var post model.Post
	if err := model.DB.Where("id = ?", req.PostID).First(&post).Error; err != nil {
		c.JSON(404, gin.H{"error": "Post not found"})
		return
	}

	comment := model.Comment{
		PostID:  req.PostID,
		Content: req.Content,
		UserID:  userID.(uint),
	}
	if err := model.DB.Create(&comment).Error; err != nil {
		c.JSON(500, gin.H{"error": "Failed to create a comment"})
		return
	}
	c.JSON(201, gin.H{"message": "Comment created successfully"})
}

func (cc *CommentController) GetComment(c *gin.Context) {
	postID, err := strconv.ParseUint(c.Param("id"), 10, 32)
	if err != nil {
		c.JSON(400, gin.H{"error": "Invalid post ID"})
		return
	}
	var comments []model.Comment
	if err := model.DB.Where("post_id = ?", postID).Find(&comments).Error; err != nil {
		c.JSON(500, gin.H{"error": "Failed to get comments"})
		return
	}
	c.JSON(200, gin.H{
		"count":    len(comments),
		"comments": comments,
	})
}
