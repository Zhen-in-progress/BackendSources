package routes

import (
	"personalBloger/auth"
	"personalBloger/controller"
	"personalBloger/middleware"

	"github.com/gin-gonic/gin"
)

func InitRoutes() *gin.Engine {
	r := gin.New()

	// Add logger middleware globally
	r.Use(middleware.LoggerMiddleware())
	// Add recovery middleware to recover from panics
	r.Use(gin.Recovery())

	authController := &auth.AuthController{}
	postController := &controller.PostController{}
	commentController := &controller.CommentController{}
	//api
	api := r.Group("v1")
	{
		auth := api.Group("/auth")
		{
			auth.POST("/signin", authController.SignIn)
			auth.POST("/login", authController.LogIn)

		}
	}

	{
		authenticated := api.Group("")
		authenticated.Use(middleware.AuthMiddleware())
		post := authenticated.Group("/post")
		post.POST("", postController.CreatePost)
		post.PUT("/:id", postController.UpdatePost)
		post.DELETE("/:id", postController.DeletePost)

		comment := authenticated.Group("/comment")
		comment.POST("", commentController.CreateComment)

	}
	{
		public := api.Group("")
		public.GET("/postlist", postController.GetPostList)
		public.GET("/post/:id", postController.GetPost)
		public.GET("/post/:id/comment", commentController.GetComment)
	}

	return r
}
