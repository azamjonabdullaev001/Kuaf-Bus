package websocket

import (
	"encoding/json"
	"fmt"
	"log"

	"backend/models"
)

type Hub struct {
	// Registered clients
	Clients map[*Client]bool

	// Inbound messages from clients
	Broadcast chan models.LocationBroadcast

	// Register requests from clients
	Register chan *Client

	// Unregister requests from clients
	Unregister chan *Client
}

func NewHub() *Hub {
	return &Hub{
		Clients:    make(map[*Client]bool),
		Broadcast:  make(chan models.LocationBroadcast, 256),
		Register:   make(chan *Client),
		Unregister: make(chan *Client),
	}
}

func (h *Hub) Run() {
	for {
		select {
		case client := <-h.Register:
			h.Clients[client] = true
			log.Printf("Client connected. Total clients: %d", len(h.Clients))

		case client := <-h.Unregister:
			if _, ok := h.Clients[client]; ok {
				delete(h.Clients, client)
				close(client.Send)
				log.Printf("Client disconnected. Total clients: %d", len(h.Clients))
			}

		case message := <-h.Broadcast:
			// Broadcast location update to all connected clients
			messageJSON, err := json.Marshal(message)
			if err != nil {
				log.Printf("[Hub] Error marshaling broadcast message: %v", err)
				continue
			}
			
			headingStr := "null"
			if message.Heading != nil {
				headingStr = fmt.Sprintf("%.1f°", *message.Heading)
			}
			log.Printf("[Hub] Broadcasting to %d clients: user_id=%d, user_type=%s, lat=%.6f, lon=%.6f, heading=%s",
				len(h.Clients), message.UserID, message.UserType, message.Latitude, message.Longitude, headingStr)

			for client := range h.Clients {
				select {
				case client.Send <- messageJSON:
				default:
					close(client.Send)
					delete(h.Clients, client)
				}
			}
		}
	}
}
