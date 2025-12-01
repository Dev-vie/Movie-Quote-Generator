# Docker Setup Guide

## Prerequisites

- Docker Desktop installed
- Docker Compose installed (comes with Docker Desktop)

## Build and Run

### Build all services

```powershell
docker-compose build
```

### Run all services

```powershell
docker-compose up
```

### Run in detached mode (background)

```powershell
docker-compose up -d
```

### View logs

```powershell
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f eureka-server
docker-compose logs -f zuul-gateway
```

### Stop all services

```powershell
docker-compose down
```

### Rebuild and restart

```powershell
docker-compose up --build
```

## Individual Service Commands

### Build Eureka Server

```powershell
cd eureka-server
docker build -t eureka-server:latest .
```

### Run Eureka Server

```powershell
docker run -d -p 8761:8761 --name eureka-server eureka-server:latest
```

### Build Zuul Gateway

```powershell
cd zuul-gateway
docker build -t zuul-gateway:latest .
```

### Run Zuul Gateway

```powershell
docker run -d -p 8080:8080 --name zuul-gateway `
  -e EUREKA_CLIENT_SERVICEURL_DEFAULTZONE=http://eureka-server:8761/eureka/ `
  --link eureka-server `
  zuul-gateway:latest
```

## Testing

### Check running containers

```powershell
docker ps
```

### Test Eureka Server

```powershell
curl http://localhost:8761
```

### Test Zuul Gateway

```powershell
curl http://localhost:8080/actuator/health
```

## Troubleshooting

### View container logs

```powershell
docker logs <container-name>
```

### Access container shell

```powershell
docker exec -it <container-name> sh
```

### Remove all containers

```powershell
docker-compose down -v
```

### Clean up Docker resources

```powershell
docker system prune -a
```

## Network Architecture

- All services run in `microservices-network` bridge network
- Services communicate using container names as hostnames
- External access through exposed ports

## Service URLs

- **Eureka Server**: http://localhost:8761
- **Zuul Gateway**: http://localhost:8080
- **User Auth Service**: http://localhost:3001 (when added)
- **Transaction Service**: http://localhost:3002 (when added)
- **Analytics Service**: http://localhost:3003 (when added)

## Adding New Services

1. Create Dockerfile in service directory
2. Uncomment service in docker-compose.yml
3. Update environment variables
4. Run `docker-compose up --build`
