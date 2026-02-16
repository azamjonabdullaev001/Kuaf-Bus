package main

import (
	"log"
	"net/http"
	"os"

	"backend/handlers"
	"backend/database"
	"backend/websocket"

	"github.com/gorilla/mux"
	"github.com/joho/godotenv"
	"github.com/rs/cors"
)

func main() {
	// Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, using system environment variables")
	}

	// Initialize database
	db, err := database.InitDB()
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}
	defer db.Close()

	// Run migrations
	if err := database.RunMigrations(db); err != nil {
		log.Fatal("Failed to run migrations:", err)
	}

	// Initialize WebSocket hub for real-time location updates
	hub := websocket.NewHub()
	go hub.Run()

	// Setup routes
	router := mux.NewRouter()

	// Health check endpoint
	router.HandleFunc("/api/health", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte(`{"status":"ok"}`))
	}).Methods("GET")

	// Auth routes
	router.HandleFunc("/api/auth/login", handlers.Login(db)).Methods("POST")

	// Admin routes (protected)
	router.HandleFunc("/api/admin/students", handlers.CreateStudent(db)).Methods("POST")
	router.HandleFunc("/api/admin/students", handlers.GetAllStudents(db)).Methods("GET")
	router.HandleFunc("/api/admin/students/import", handlers.ImportStudents(db)).Methods("POST")
	router.HandleFunc("/api/admin/drivers", handlers.CreateDriver(db)).Methods("POST")
	router.HandleFunc("/api/admin/drivers", handlers.GetAllDrivers(db)).Methods("GET")
	router.HandleFunc("/api/admin/drivers/import", handlers.ImportDrivers(db)).Methods("POST")
	
	// Admin management routes
	router.HandleFunc("/api/admin/users/search", handlers.SearchUsers(db)).Methods("GET")
	router.HandleFunc("/api/admin/users/delete", handlers.DeleteUser(db)).Methods("DELETE")
	router.HandleFunc("/api/admin/users/delete-all", handlers.DeleteAllUsers(db)).Methods("DELETE")

	// User routes (protected)
	router.HandleFunc("/api/users/profile", handlers.GetProfile(db)).Methods("GET")
	router.HandleFunc("/api/users/location", handlers.UpdateLocation(db, hub)).Methods("POST")
	router.HandleFunc("/api/users/drivers-locations", handlers.GetDriversLocations(db)).Methods("GET")

	// WebSocket endpoint for real-time updates
	router.HandleFunc("/ws", func(w http.ResponseWriter, r *http.Request) {
		websocket.ServeWs(hub, w, r)
	})

	// CORS configuration
	allowedOrigins := os.Getenv("ALLOWED_ORIGINS")
	if allowedOrigins == "" {
		allowedOrigins = "http://localhost:3000,http://localhost:19006"
	}
	
	// Parse allowed origins
	origins := make([]string, 0)
	for _, origin := range splitAndTrim(allowedOrigins, ",") {
		origins = append(origins, origin)
	}
	
	// In development, allow all origins
	if os.Getenv("ENVIRONMENT") == "development" {
		origins = append(origins, "*")
	}

	c := cors.New(cors.Options{
		AllowedOrigins:   origins,
		AllowedMethods:   []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowedHeaders:   []string{"Content-Type", "Authorization"},
		AllowCredentials: true,
	})

	handler := c.Handler(router)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Server starting on port %s...", port)
	log.Printf("Allowed CORS origins: %v", origins)
	log.Printf("Environment: %s", os.Getenv("ENVIRONMENT"))
	log.Fatal(http.ListenAndServe(":"+port, handler))
}

// Helper function to split and trim strings
func splitAndTrim(s, sep string) []string {
	parts := make([]string, 0)
	for _, part := range stringsSplit(s, sep) {
		trimmed := stringsTrim(part)
		if trimmed != "" {
			parts = append(parts, trimmed)
		}
	}
	return parts
}

func stringsSplit(s, sep string) []string {
	result := make([]string, 0)
	start := 0
	for i := 0; i < len(s); i++ {
		if i+len(sep) <= len(s) && s[i:i+len(sep)] == sep {
			result = append(result, s[start:i])
			start = i + len(sep)
			i += len(sep) - 1
		}
	}
	result = append(result, s[start:])
	return result
}

func stringsTrim(s string) string {
	start := 0
	end := len(s)
	for start < end && (s[start] == ' ' || s[start] == '\t' || s[start] == '\n' || s[start] == '\r') {
		start++
	}
	for end > start && (s[end-1] == ' ' || s[end-1] == '\t' || s[end-1] == '\n' || s[end-1] == '\r') {
		end--
	}
	return s[start:end]
}
