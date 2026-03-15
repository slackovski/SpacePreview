FROM golang:1.22-alpine AS builder

WORKDIR /build
COPY . .

RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux go build -o app .

FROM alpine:latest

WORKDIR /root

COPY --from=builder /build/app .

EXPOSE 8080

CMD ["./app"]
