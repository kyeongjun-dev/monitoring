FROM golang:1.23
WORKDIR /app
COPY go.mod go.sum main.go ./
RUN go mod download
RUN go build -o app .
CMD ["go", "run", "main.go"]
