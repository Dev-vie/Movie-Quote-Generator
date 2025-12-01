# Zuul API Gateway

API Gateway for Personal Finance & Expense Tracker Microservices

## Overview

Zuul Gateway acts as a single entry point for all client requests, routing them to appropriate backend microservices based on configured paths.

## Features

- **Dynamic Routing**: Routes requests to appropriate microservices
- **Load Balancing**: Distributes traffic across service instances via Ribbon
- **Request/Response Filtering**: Pre, post, and error filters for logging and processing
- **CORS Configuration**: Enables cross-origin requests from Angular frontend
- **Service Discovery**: Integrates with Eureka Server for dynamic service discovery
- **Circuit Breaking**: Built-in resilience with retry mechanisms

## Routes

| Path                   | Service             | Description                              |
| ---------------------- | ------------------- | ---------------------------------------- |
| `/api/auth/**`         | user-auth-service   | User authentication, login, registration |
| `/api/transactions/**` | transaction-service | Transaction CRUD operations              |
| `/api/analytics/**`    | analytics-service   | Reports, charts, and analytics           |

## Configuration

### Ports

- **Gateway Port**: 8080
- **Eureka Server**: 8761

### Timeouts

- Connection Timeout: 20 seconds
- Socket Timeout: 20 seconds
- Ribbon Connect Timeout: 5 seconds
- Ribbon Read Timeout: 5 seconds

## Running the Gateway

### Prerequisites

- Java 17 or higher
- Maven 3.6+
- Eureka Server running on http://localhost:8761

### Build and Run

```bash
# Navigate to zuul-gateway directory
cd zuul-gateway

# Clean and build
mvn clean install

# Run the application
mvn spring-boot:run
```

The gateway will start on **http://localhost:8080**

## Health Check

Monitor the gateway health and routes:

```bash
# Health endpoint
curl http://localhost:8080/actuator/health

# View all configured routes
curl http://localhost:8080/actuator/routes

# View registered filters
curl http://localhost:8080/actuator/filters
```

## Testing Routes

### Example Requests

```bash
# User Authentication (when user-auth-service is running)
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password123"}'

# Get Transactions (when transaction-service is running)
curl http://localhost:8080/api/transactions \
  -H "Authorization: Bearer <token>"

# Get Analytics (when analytics-service is running)
curl http://localhost:8080/api/analytics/reports \
  -H "Authorization: Bearer <token>"
```

## Filters

### PreFilter

- **Purpose**: Intercepts requests before routing
- **Actions**:
  - Logs incoming requests (method, URL)
  - Adds custom headers (X-Gateway-Timestamp)

### PostFilter

- **Purpose**: Processes responses after routing
- **Actions**:
  - Logs response status codes
  - Adds CORS headers for frontend access

### ErrorFilter

- **Purpose**: Handles routing errors
- **Actions**:
  - Logs errors with stack traces
  - Returns JSON error responses

## Integration with Services

For backend services to register with this gateway:

1. Services must register with Eureka Server
2. Service names in Eureka must match:
   - `user-auth-service`
   - `transaction-service`
   - `analytics-service`
3. Services should expose health endpoints for monitoring

## Troubleshooting

### Common Issues

**Gateway can't connect to Eureka:**

- Ensure Eureka Server is running on port 8761
- Check `eureka.client.service-url.defaultZone` in application.yml

**Routes not working:**

- Verify backend services are registered in Eureka
- Check service names match exactly
- Review logs for routing errors

**Timeouts occurring:**

- Adjust timeout settings in application.yml
- Check backend service response times
- Review Ribbon retry configuration

## Next Steps

1. Start backend microservices (user-auth, transaction, analytics)
2. Configure Angular frontend to use gateway URL (http://localhost:8080)
3. Implement JWT token validation in filters
4. Add rate limiting for API protection
5. Set up monitoring and logging aggregation
