# Stage 1: Build stage
FROM golang:1.21-alpine AS builder

WORKDIR /build

# Copy go mod files
COPY go.mod ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags="-w -s" -o server .

# Stage 2: Runtime stage
FROM scratch

# Copy binary from builder
COPY --from=builder /build/server /server

# Expose port
EXPOSE 8080

# Run the application
ENTRYPOINT ["/server"]
