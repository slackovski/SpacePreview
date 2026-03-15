package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
)

type User struct {
	ID    int    `json:"id"`
	Name  string `json:"name"`
	Email string `json:"email"`
}

type UserService struct {
	users []User
}

func NewUserService() *UserService {
	return &UserService{
		users: []User{
			{ID: 1, Name: "Alice", Email: "alice@example.com"},
			{ID: 2, Name: "Bob", Email: "bob@example.com"},
		},
	}
}

func (s *UserService) GetUser(ctx context.Context, id int) (*User, error) {
	for _, u := range s.users {
		if u.ID == id {
			return &u, nil
		}
	}
	return nil, fmt.Errorf("user %d not found", id)
}

func main() {
	svc := NewUserService()

	http.HandleFunc("/api/users/", func(w http.ResponseWriter, r *http.Request) {
		var id int
		fmt.Sscanf(r.URL.Path[len("/api/users/"):], "%d", &id)

		user, err := svc.GetUser(r.Context(), id)
		if err != nil {
			http.Error(w, err.Error(), http.StatusNotFound)
			return
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(user)
	})

	log.Println("Listening on :8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
