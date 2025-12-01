# Team Integration Guide

## 🎯 For Backend Developers (Roles 1, 2, 3)

Your DevOps teammate has deployed the infrastructure. Here's how to integrate your microservices.

---

## 📋 What's Already Deployed

- **Eureka Server (Service Discovery):** `https://eureka-server-6yh5.onrender.com`
- **API Gateway (Zuul):** `https://zuul-gateway.onrender.com`
- **Swagger:** `https://zuul-gateway.onrender.com/swagger-ui.html`
- **Docker Images:** Available on Docker Hub (`mengfong/eureka-server`, `mengfong/zuul-gateway`)

---

## 🔧 Step 1: Configure Your Microservice

### Update `application.yml` or `application.properties`

Add Eureka client configuration to register your service with the discovery server.

#### For application.yml:

```yaml
spring:
  application:
    name: user-auth-service # Change to: transaction-service, analytics-service

server:
  port: ${PORT:3001} # Use 3001 for auth, 3002 for transactions, 3003 for analytics

eureka:
  client:
    service-url:
      defaultZone: https://eureka-server-6yh5.onrender.com/eureka/
    register-with-eureka: true
    fetch-registry: true
  instance:
    prefer-ip-address: true
    instance-id: ${spring.application.name}:${random.value}
```

#### For application.properties:

```properties
spring.application.name=user-auth-service
server.port=${PORT:3001}

eureka.client.service-url.defaultZone=https://eureka-server-6yh5.onrender.com/eureka/
eureka.client.register-with-eureka=true
eureka.client.fetch-registry=true
eureka.instance.prefer-ip-address=true
```

### Service Name Mapping:

| Role       | Service Name          | Port | Gateway Route          |
| ---------- | --------------------- | ---- | ---------------------- |
| **Role 1** | `user-auth-service`   | 3001 | `/api/auth/**`         |
| **Role 2** | `transaction-service` | 3002 | `/api/transactions/**` |
| **Role 3** | `analytics-service`   | 3003 | `/api/analytics/**`    |

---

## 🐳 Step 2: Create Dockerfile for Your Service

Create a `Dockerfile` in your service's root directory:

### For Java/Spring Boot:

```dockerfile
FROM amazoncorretto:17-alpine

WORKDIR /app

# Install curl for health checks
RUN apk add --no-cache curl

# Copy the JAR file
COPY target/*.jar app.jar

# Expose the port
EXPOSE 3001

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:${PORT:-3001}/actuator/health || exit 1

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
```

### For Node.js:

```dockerfile
FROM node:18-alpine

WORKDIR /app

# Install curl for health checks
RUN apk add --no-cache curl

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy source code
COPY . .

# Expose the port
EXPOSE 3001

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:${PORT:-3001}/health || exit 1

# Run the application
CMD ["node", "server.js"]
```

### For Python/Flask:

```dockerfile
FROM python:3.11-alpine

WORKDIR /app

# Install curl for health checks
RUN apk add --no-cache curl

# Copy requirements
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy source code
COPY . .

# Expose the port
EXPOSE 3001

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:${PORT:-3001}/health || exit 1

# Run the application
CMD ["python", "app.py"]
```

---

## 🏗️ Step 3: Build and Test Locally

### Build your Docker image:

```powershell
# Build your service
cd your-service-folder
mvn clean package -DskipTests  # For Java
# OR
npm run build  # For Node.js
# OR
# No build needed for Python

# Build Docker image
docker build -t your-username/your-service:latest .
```

### Test locally with Eureka:

```powershell
# Run your service
docker run -p 3001:3001 `
  -e EUREKA_CLIENT_SERVICEURL_DEFAULTZONE=https://eureka-server-6yh5.onrender.com/eureka/ `
  your-username/your-service:latest

# Test your endpoints
curl http://localhost:3001/actuator/health
curl http://localhost:3001/your-endpoint
```

### Verify registration:

1. Open Eureka Dashboard: `https://eureka-server-6yh5.onrender.com`
2. Your service should appear in **"Instances currently registered with Eureka"**

---

## 🚀 Step 4: Deploy to Render.com

### Push to Docker Hub:

```powershell
# Login to Docker Hub
docker login

# Push your image
docker push your-username/your-service:latest
```

### Deploy on Render:

1. Go to https://dashboard.render.com
2. Click **"New +"** → **"Web Service"**
3. Select **"Deploy an existing image from a registry"**
4. Configure:
   - **Image URL:** `your-username/your-service:latest`
   - **Name:** `your-service-name` (e.g., `user-auth-service`)
   - **Region:** `Singapore` (same as Gateway)
   - **Instance Type:** `Free`
5. Add **Environment Variables**:
   ```
   EUREKA_CLIENT_SERVICEURL_DEFAULTZONE = https://eureka-server-6yh5.onrender.com/eureka/
   ```
6. Click **"Create Web Service"**
7. Wait 3-5 minutes for deployment

### Verify deployment:

1. Check Render logs for startup success
2. Visit Eureka: `https://eureka-server-6yh5.onrender.com` (your service should be listed)
3. Test via Gateway: `https://zuul-gateway.onrender.com/api/your-route/endpoint`

---

## 🧪 Step 5: Test Integration

### Test through API Gateway:

```powershell
# Example for User Auth Service
curl https://zuul-gateway.onrender.com/api/auth/health

# Example for Transaction Service
curl https://zuul-gateway.onrender.com/api/transactions/health

# Example for Analytics Service
curl https://zuul-gateway.onrender.com/api/analytics/health
```

### Available Gateway Routes:

| Service      | Gateway URL                                             | Your Service URL                |
| ------------ | ------------------------------------------------------- | ------------------------------- |
| Auth         | `https://zuul-gateway.onrender.com/api/auth/**`         | Routes to `user-auth-service`   |
| Transactions | `https://zuul-gateway.onrender.com/api/transactions/**` | Routes to `transaction-service` |
| Analytics    | `https://zuul-gateway.onrender.com/api/analytics/**`    | Routes to `analytics-service`   |

---

## 🎨 For Frontend Developer

### Base API URL:

```javascript
const API_BASE_URL = "https://zuul-gateway.onrender.com";
```

### Example API Calls:

#### Login:

```javascript
const login = async (username, password) => {
  const response = await fetch(`${API_BASE_URL}/api/auth/login`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ username, password }),
  });
  return response.json();
};
```

#### Get Transactions:

```javascript
const getTransactions = async (token) => {
  const response = await fetch(`${API_BASE_URL}/api/transactions`, {
    method: "GET",
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
    },
  });
  return response.json();
};
```

#### Get Analytics:

```javascript
const getAnalytics = async (token) => {
  const response = await fetch(`${API_BASE_URL}/api/analytics/summary`, {
    method: "GET",
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
    },
  });
  return response.json();
};
```

### CORS Configuration:

The Gateway already has CORS enabled for all origins. You can make requests directly from your frontend application.

---

## 📝 Required Dependencies

### For Java/Spring Boot Services:

Add to your `pom.xml`:

```xml
<!-- Eureka Client -->
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
</dependency>

<!-- Actuator for health checks -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```

Add Spring Cloud version in `dependencyManagement`:

```xml
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-dependencies</artifactId>
            <version>2021.0.8</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>
```

### Enable Eureka Client:

Add `@EnableEurekaClient` to your main application class:

```java
import org.springframework.cloud.netflix.eureka.EnableEurekaClient;

@SpringBootApplication
@EnableEurekaClient
public class YourServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(YourServiceApplication.class, args);
    }
}
```

---

## ⚠️ Important Notes

### Free Tier Limitations:

- **Auto-sleep:** Services sleep after 15 minutes of inactivity
- **Wake-up time:** First request takes 30-60 seconds
- **750 hours/month:** Per service (enough for development)

### Service Health Checks:

Ensure your service has a health endpoint:

**Spring Boot:** `/actuator/health` (automatic)  
**Node.js/Express:** Create `/health` endpoint  
**Python/Flask:** Create `/health` endpoint

Example for Node.js:

```javascript
app.get("/health", (req, res) => {
  res.status(200).json({ status: "UP" });
});
```

### Environment Variables on Render:

Always use `${PORT:default}` syntax in your config to support Render's dynamic port assignment.

---

## 🆘 Troubleshooting

### Service not appearing in Eureka:

1. Check Render logs: Click your service → "Logs" tab
2. Verify `EUREKA_CLIENT_SERVICEURL_DEFAULTZONE` is correct
3. Ensure your service is using the correct `spring.application.name`
4. Wait 30 seconds for Eureka registration

### Gateway returns 503 Service Unavailable:

1. Verify service is registered in Eureka dashboard
2. Check if service is awake (free tier auto-sleeps)
3. Test service directly: `https://your-service.onrender.com/actuator/health`

### Port binding errors:

- Use `${PORT:3001}` in your application.yml, not hardcoded `3001`
- Render assigns dynamic ports in cloud environment

---

## 📞 Contact

If you encounter issues:

1. Check Eureka Dashboard: `https://eureka-server-6yh5.onrender.com`
2. Check Gateway Health: `https://zuul-gateway.onrender.com/actuator/health`
3. Contact your DevOps teammate (Role 4) for infrastructure issues

---

## ✅ Deployment Checklist

- [ ] Updated `application.yml` with Eureka configuration
- [ ] Created `Dockerfile` for your service
- [ ] Tested locally with Docker
- [ ] Verified service registers with Eureka
- [ ] Pushed Docker image to Docker Hub
- [ ] Deployed to Render.com
- [ ] Verified service appears in Eureka Dashboard
- [ ] Tested endpoints via API Gateway
- [ ] Shared your service endpoints with team

---

## 🎉 You're All Set!

Once your service is deployed and registered with Eureka, it will automatically be accessible through the API Gateway at `https://zuul-gateway.onrender.com`.

**Good luck with your development!** 🚀
