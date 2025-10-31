package auth

import (
	"net/http"
	"personalBloger/model"
	"time"

	"github.com/dgrijalva/jwt-go"
	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
)

type AuthController struct{}

type AuthResponse struct {
	Code    int         `json:"code"`
	Message string      `json:"message"`
	Data    interface{} `json:"data,omitempty"`
}

type signInRequest struct {
	Username string `json:"username" binding:"required, min=3, max=20"`
	Password string `json:"password" binding:"required, min=8, max=20"`
	Email    string `json:"email" binding:"required, email"`
}

type logInRequest struct {
	Username string `json:"username" binding:"required, min=3, max=20"`
	Password string `json:"password" binding:"required, min=8, max=20"`
}

func (ac *AuthController) SignIn(c *gin.Context) {
	// Username string `json:"username" binding:"required, min=3, max=20"`
	// Password string `json:"password" binding:"required, min=8, max=20"`
	// Email    string `json:"email" binding:"required, email"`
	var req signInRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(400, gin.H{"error": err.Error()})
		return
	}
	//To Do 1
	//Chcek form of email is correct
	//Check
	//Check if Username or email exist
	//
	var existingUser model.User
	if err := model.DB.Where("username=?", req.Username).First(&existingUser).Error; err == nil {
		c.JSON(400, gin.H{"error": "Username already exists"})
		return
	}
	var existingEmail model.User
	if err := model.DB.Where("username=?", req.Username).First(&existingEmail).Error; err == nil {
		c.JSON(400, gin.H{"error": "Email already exists"})
		return
	}
	// Create user
	user := model.User{
		Username: req.Username,
		Email:    req.Email,
		Password: req.Password,
	}
	if err := model.DB.Create(&user).Error; err != nil {
		c.JSON(400, gin.H{"error": "Failed to create a user"})
	}

}

func (ac *AuthController) LogIn(c *gin.Context) {
	// Username string `json:"username" binding:"required, min=3, max=20"`
	// Password string `json:"password" binding:"required, min=8, max=20"`
	var req logInRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(400, gin.H{"error": err.Error()})
	}
	// check if user exist, return error if user doesn't exist
	var existingUser model.User
	if err := model.DB.Where("username=?", req.Username).First(&existingUser).Error; err != nil {
		c.JSON(400, gin.H{"error": "Invalid username or password"})
		return
	}
	// check if password match, return error if password doesn't match
	// var storedUser model.User
	if err := bcrypt.CompareHashAndPassword([]byte(existingUser.Password), []byte(req.Password)); err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid username or password"})
		return
	}
	//JWT
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"id":       existingUser.ID,
		"username": existingUser.Username,
		"exp":      time.Now().Add(time.Hour * 24).Unix(),
	})

	tokenString, err := token.SignedString([]byte("your_secret_key"))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate token"})
		return
	}
	c.JSON(http.StatusOK, AuthResponse{
		Code:    200,
		Message: "success",
		Data: gin.H{
			"Token": tokenString,
			"User":  existingUser,
		},
	})
}
