package main

import (
	"personalBloger/model"
	"personalBloger/routes"
)

func main() {
	// Initialize database (sets model.DB global variable)
	model.InitDB()
	// Setup routes
	r := routes.InitRoutes()

	// Start server
	r.Run(":8080")
}
