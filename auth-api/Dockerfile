# Dockerfile para auth-api (Go)
FROM golang:1.18-alpine AS build
WORKDIR /app

# Copiar solo go.mod primero
COPY go.mod ./

# Copiar todo el código fuente
COPY . .

# Descargar dependencias y compilar
RUN go mod tidy && \
    go mod download && \
    CGO_ENABLED=0 GOOS=linux go build -o auth-api .

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=build /app/auth-api .
EXPOSE 8000
CMD ["./auth-api"]
