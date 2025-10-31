package model

import "gorm.io/gorm"

type Post struct {
	gorm.Model
	Comments []Comment `json:"comments,omitempty"`
	UserID   uint      `json:"user_id" gorm:"not null;index"`
	Title    string    `json:"title" binding:"required"`
	Content  string    `json:"content" binding:"required"`
}
