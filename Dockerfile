# Start from the latest golang base image
FROM golang:latest

ENV GO111MODULE=on
ARG APP_NAME
ENV ENV_APP_NAME=$APP_NAME

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy go mod and sum files
COPY go.mod go.sum ./

# Download all dependencies. Dependencies will be cached if the go.mod and go.sum files are not changed
RUN go mod download

# Copy the source from the current directory to the Working Directory inside the container
COPY . .

# Build the Go app
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o $ENV_APP_NAME .

# Expose port 8080 to the outside world
EXPOSE 7070

# Command to run the executable
CMD ["./gobuild-make"]
