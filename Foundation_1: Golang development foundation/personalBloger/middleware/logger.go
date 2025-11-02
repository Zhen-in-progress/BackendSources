package middleware

import (
	"time"

	"github.com/gin-gonic/gin"
	"github.com/sirupsen/logrus"
)

var log = logrus.New()

func init() {
	// Set log format to JSON for better parsing in production
	log.SetFormatter(&logrus.JSONFormatter{
		TimestampFormat: time.RFC3339,
	})

	// You can also use TextFormatter for more readable console output
	// log.SetFormatter(&logrus.TextFormatter{
	// 	FullTimestamp:   true,
	// 	TimestampFormat: "2006-01-02 15:04:05",
	// })

	// Set log level (Debug, Info, Warn, Error, Fatal, Panic)
	log.SetLevel(logrus.InfoLevel)
}

// LoggerMiddleware logs incoming requests and responses
func LoggerMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		// Start timer
		startTime := time.Now()

		// Get request details before processing
		path := c.Request.URL.Path
		method := c.Request.Method
		clientIP := c.ClientIP()
		userAgent := c.Request.UserAgent()

		// Process request
		c.Next()

		// Calculate request duration
		duration := time.Since(startTime)
		statusCode := c.Writer.Status()

		// Create log entry with structured fields
		entry := log.WithFields(logrus.Fields{
			"client_ip":   clientIP,
			"method":      method,
			"path":        path,
			"status_code": statusCode,
			"duration_ms": duration.Milliseconds(),
			"user_agent":  userAgent,
		})

		// Add user information if authenticated
		if userID, exists := c.Get("user_id"); exists {
			entry = entry.WithField("user_id", userID)
		}
		if username, exists := c.Get("username"); exists {
			entry = entry.WithField("username", username)
		}

		// Add error message if exists
		if len(c.Errors) > 0 {
			entry = entry.WithField("errors", c.Errors.String())
		}

		// Log based on status code
		switch {
		case statusCode >= 500:
			entry.Error("Server error")
		case statusCode >= 400:
			entry.Warn("Client error")
		case statusCode >= 300:
			entry.Info("Redirection")
		default:
			entry.Info("Success")
		}
	}
}

// GetLogger returns the logger instance for use in other parts of the application
func GetLogger() *logrus.Logger {
	return log
}
