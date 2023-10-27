package main

import (
	"context"
	"fmt"
	"log"
	"net"
	"sync"

	chat "github.com/tylersustare/chatserver/chat"
	"google.golang.org/grpc"
)

type server struct {
	chat.UnimplementedChatServiceServer
	connectedClients map[*chat.User]chan chat.Message
	mu               sync.Mutex
}

func (s *server) Connect(user *chat.User, stream chat.ChatService_ConnectServer) error {
	fmt.Printf("User %s connected\n", user.Name)
	s.mu.Lock()
	messageChannel := make(chan chat.Message, 10)
	s.connectedClients[user] = messageChannel
	s.mu.Unlock()

	defer func() {
		s.mu.Lock()
		delete(s.connectedClients, user)
		s.mu.Unlock()
		close(messageChannel)
	}()

	for {
		select {
		case msg := <-messageChannel:
			if err := stream.Send(&msg); err != nil {
				return err
			}
		case <-stream.Context().Done():
			return nil
		}
	}
}

func (s *server) SendMessage(ctx context.Context, message *chat.Message) (*chat.Empty, error) {
	fmt.Printf("Message received from %s: %s\n", message.From, message.Content)
	s.mu.Lock()
	for _, messageChannel := range s.connectedClients {
		select {
		case messageChannel <- *message:
		default:
		}
	}
	s.mu.Unlock()
	return &chat.Empty{}, nil
}

func main() {
	grpcServer := grpc.NewServer()
	chatServer := &server{
		connectedClients: make(map[*chat.User]chan chat.Message),
	}
	chat.RegisterChatServiceServer(grpcServer, chatServer)

	listener, err := net.Listen("tcp", ":50051")
	if err != nil {
		log.Fatalf("Failed to listen on port 50051: %v", err)
	}

	log.Println("Server Listening on :50051")
	if err := grpcServer.Serve(listener); err != nil {
		log.Fatalf("Failed to serve gRPC server: %v", err)
	}
}
