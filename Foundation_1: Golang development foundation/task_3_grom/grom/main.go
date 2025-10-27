package main

import (
	"fmt"
	"log"

	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

// 题目1：模型定义
// 假设你要开发一个博客系统，有以下几个实体： User （用户）、 Post （文章）、 Comment （评论）。
// 要求 ：
// 使用Gorm定义 User 、 Post 和 Comment 模型，其中 User 与 Post 是一对多关系（一个用户可以发布多篇文章）， Post 与 Comment 也是一对多关系（一篇文章可以有多个评论）。
// 编写Go代码，使用Gorm创建这些模型对应的数据库表。
type User struct {
	gorm.Model
	PostCount int // Track number of posts
	Posts     []Post
}

type Post struct {
	gorm.Model
	UserID        uint
	CommentStatus string // "Commented" or "No Comment"
	Comments      []Comment
}

// AfterCreate hook - runs after a post is created
func (p *Post) AfterCreate(tx *gorm.DB) error {
	// Increment user's post count
	return tx.Model(&User{}).Where("id = ?", p.UserID).
		UpdateColumn("post_count", gorm.Expr("post_count + 1")).Error
}

type Comment struct {
	gorm.Model
	PostID uint
}

// AfterDelete hook - runs after a comment is deleted
func (c *Comment) AfterDelete(tx *gorm.DB) error {
	// Count remaining comments for this post
	var count int64
	tx.Model(&Comment{}).Where("post_id = ?", c.PostID).Count(&count)

	// If no comments left, update post status to "No Comment"
	if count == 0 {
		return tx.Model(&Post{}).Where("id = ?", c.PostID).
			Update("comment_status", "No Comment").Error
	}
	return nil
}

func loadSampleData(db *gorm.DB) {
	// Create users
	user1 := User{}
	user2 := User{}
	user3 := User{}

	db.Create(&user1)
	db.Create(&user2)
	db.Create(&user3)

	// Create posts for users
	post1 := Post{UserID: user1.ID, CommentStatus: "Commented"}
	post2 := Post{UserID: user1.ID, CommentStatus: "Commented"}
	post3 := Post{UserID: user2.ID, CommentStatus: "Commented"}
	post4 := Post{UserID: user3.ID, CommentStatus: "No Comment"}

	db.Create(&post1)
	db.Create(&post2)
	db.Create(&post3)
	db.Create(&post4)

	// Create comments for posts
	db.Create(&Comment{PostID: post1.ID})
	db.Create(&Comment{PostID: post1.ID})
	db.Create(&Comment{PostID: post1.ID})
	db.Create(&Comment{PostID: post2.ID})
	db.Create(&Comment{PostID: post2.ID})
	db.Create(&Comment{PostID: post3.ID})

	log.Println("Sample data loaded successfully!")
	log.Printf("Created %d users, %d posts, %d comments", 3, 4, 6)
}
func main() {
	// Connect to SQLite database
	db, err := gorm.Open(sqlite.Open("blog.db"), &gorm.Config{})
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}

	// Auto migrate the models - creates tables with proper foreign keys
	// 编写Go代码，使用Gorm创建这些模型对应的数据库表。
	db.AutoMigrate(&User{}, &Post{}, &Comment{})

	// Load sample data
	loadSampleData(db)
	//题目2：关联查询
	// 基于上述博客系统的模型定义。
	// 要求 ：
	// 编写Go代码，使用Gorm查询某个用户发布的所有文章及其对应的评论信息。
	// 编写Go代码，使用Gorm查询评论数量最多的文章信息。
	var user1Posts []Post
	db.Where("user_id = ?", 1).Find(&user1Posts)
	fmt.Println(user1Posts)

	var MostCommentedPost Post
	db.Raw("SELECT * FROM comments GROUP BY post_id ORDER BY COUNT(*) DESC LIMIT 1").Scan(&MostCommentedPost)
	fmt.Println(MostCommentedPost)

	// Test hooks
	testHooks(db)
}

func testHooks(db *gorm.DB) {
	log.Println("\n=== Testing Hooks ===")

	// Test 1: Check user post counts (should be updated by AfterCreate hook)
	var users []User
	db.Find(&users)
	log.Println("\nUser Post Counts (updated by AfterCreate hook):")
	for _, u := range users {
		log.Printf("User ID %d: %d posts", u.ID, u.PostCount)
	}

	// Test 2: Create a new post and see post count increment
	log.Println("\nCreating a new post for User 1...")
	newPost := Post{UserID: 1, CommentStatus: "No Comment"}
	db.Create(&newPost)

	var user1 User
	db.First(&user1, 1)
	log.Printf("User 1 post count after creating new post: %d", user1.PostCount)

	// Test 3: Delete all comments from a post and check status
	log.Println("\nDeleting all comments from Post 3...")
	var post3 Post
	db.Preload("Comments").First(&post3, 3)
	log.Printf("Post 3 status before deletion: %s", post3.CommentStatus)
	log.Printf("Post 3 has %d comments", len(post3.Comments))

	// Delete comments one by one (batch delete doesn't trigger hooks!)
	for _, comment := range post3.Comments {
		db.Delete(&comment)
	}

	// Check post status after deletion
	db.First(&post3, 3)
	log.Printf("Post 3 status after deletion: %s (should be 'No Comment')", post3.CommentStatus)
}
