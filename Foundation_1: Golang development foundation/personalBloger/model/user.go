package model

import (
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

type User struct {
	gorm.Model
	Posts    []Post `json:"posts,omitempty"`
	Username string `json:"username" binding:"required, min=3, max=20"`
	Password string `json:"password" binding:"required, min=8, max=20"`
	Email    string `json:"email" binding:"required, email"`
}

func (u *User) BeforeCreate(tx *gorm.DB) error {
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(u.Password), bcrypt.DefaultCost)
	if err != nil {
		return err
	}
	u.Password = string(hashedPassword)
	return nil
}
