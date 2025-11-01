package routes

import (
	"personalBloger/auth"
	"personalBloger/controller"
	"personalBloger/middleware"

	"github.com/gin-gonic/gin"
)

func InitRoutes() *gin.Engine {
	r := gin.New()
	authController := &auth.AuthController{}
	postController := &controller.PostController{}

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
		post.GET("/list", postController.GetPostList)
		post.GET("/id", postController.GetPost)
		post.PUT("/id", postController.UpdatePost)
		post.DELETE("/id", postController.DeletePost)

	}

	return r
}
