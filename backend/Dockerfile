# Build stage
FROM golang:1.21-alpine AS builder

WORKDIR /app

# Disable sum db for go mod
ENV GOSUMDB=off

# Copy all source code
COPY . .

# Download dependencies and create go.sum
RUN go mod tidy && go mod download

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -o main .

# Run stage
FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /root/

# Copy binary from builder
COPY --from=builder /app/main .

EXPOSE 8080

CMD ["./main"]
