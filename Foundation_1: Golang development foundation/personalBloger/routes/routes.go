package routes

import (
	"personalBloger/auth"

	"github.com/gin-gonic/gin"
)

func InitRoutes() *gin.Engine {
	r := gin.New()
	authController := &auth.AuthController{}

	//api
	api := r.Group("v1")
	{
		auth := api.Group("/auth")
		{
			auth.POST("/signin", authController.SignIn)
			auth.POST("/login", authController.LogIn)

		}
	}

	return r
}
