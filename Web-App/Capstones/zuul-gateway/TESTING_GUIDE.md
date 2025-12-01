# Testing the Zuul Gateway (Spring Cloud Gateway)

## Quick Start Guide

### 1. Start the Gateway

Open a terminal and run:

```bash
cd "d:\Semester 4\Web-App\Capstones\zuul-gateway"
mvn spring-boot:run
```

The gateway will start on **http://localhost:8080**

Wait for the message: `Netty started on port 8080`

---

## Testing Endpoints

### ✅ Health Check

Test if the gateway is running:

```powershell
# PowerShell
Invoke-WebRequest -Uri http://localhost:8080/actuator/health | Select-Object -ExpandProperty Content
```

Expected response:

```json
{
  "status": "UP",
  "components": {
    "discoveryComposite": {...},
    "diskSpace": {...},
    "ping": {"status": "UP"},
    "reactiveDiscoveryClients": {...}
  }
}
```

---

### 🔍 View All Routes

See all configured routes:

```powershell
# PowerShell
$routes = Invoke-WebRequest -Uri http://localhost:8080/actuator/gateway/routes | ConvertFrom-Json
$routes | ConvertTo-Json -Depth 5
```

You should see 3 routes:

1. **user-auth-service** → `/api/auth/**`
2. **transaction-service** → `/api/transactions/**`
3. **analytics-service** → `/api/analytics/**`

---

### 🧪 Test Route Configuration

#### Test Authentication Route:

```powershell
# This will try to route to user-auth-service
# (Will fail if service isn't running, but proves routing works)
Invoke-WebRequest -Uri http://localhost:8080/api/auth/test -Method GET
```

#### Test Transaction Route:

```powershell
Invoke-WebRequest -Uri http://localhost:8080/api/transactions -Method GET
```

#### Test Analytics Route:

```powershell
Invoke-WebRequest -Uri http://localhost:8080/api/analytics/reports -Method GET
```

**Expected behavior:**

- If backend services are NOT running: You'll get `503 Service Unavailable` (normal!)
- If backend services ARE running: You'll get their actual response

---

## Testing with Postman

### 1. Import Collection

Create a new Postman collection called "Finance Gateway Tests"

### 2. Add These Requests:

#### Health Check

- **Method:** GET
- **URL:** `http://localhost:8080/actuator/health`
- **Expected:** 200 OK with JSON response

#### Gateway Routes

- **Method:** GET
- **URL:** `http://localhost:8080/actuator/gateway/routes`
- **Expected:** Array of route configurations

#### Auth Service Test

- **Method:** POST
- **URL:** `http://localhost:8080/api/auth/login`
- **Headers:** `Content-Type: application/json`
- **Body:**

```json
{
  "email": "test@example.com",
  "password": "password123"
}
```

- **Expected:** 503 (if service not running) or actual auth response

#### Get Transactions

- **Method:** GET
- **URL:** `http://localhost:8080/api/transactions`
- **Headers:** `Authorization: Bearer <token>`
- **Expected:** 503 (if service not running) or transaction list

#### Get Analytics

- **Method:** GET
- **URL:** `http://localhost:8080/api/analytics/reports`
- **Headers:** `Authorization: Bearer <token>`
- **Expected:** 503 (if service not running) or analytics data

---

## PowerShell Testing Script

Save this as `test-gateway.ps1`:

```powershell
# Test Gateway - Personal Finance App
Write-Host "Testing Spring Cloud Gateway..." -ForegroundColor Cyan

# 1. Health Check
Write-Host "`n1. Health Check:" -ForegroundColor Yellow
try {
    $health = Invoke-WebRequest -Uri "http://localhost:8080/actuator/health" -UseBasicParsing
    Write-Host "✅ Gateway is UP (Status: $($health.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "❌ Gateway is DOWN" -ForegroundColor Red
    exit
}

# 2. List Routes
Write-Host "`n2. Configured Routes:" -ForegroundColor Yellow
try {
    $routes = Invoke-WebRequest -Uri "http://localhost:8080/actuator/gateway/routes" -UseBasicParsing | ConvertFrom-Json
    foreach ($route in $routes) {
        Write-Host "  - $($route.route_id): $($route.uri)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "❌ Could not fetch routes" -ForegroundColor Red
}

# 3. Test Auth Route
Write-Host "`n3. Testing Auth Route (/api/auth/*):" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/auth/health" -UseBasicParsing -ErrorAction Stop
    Write-Host "✅ Auth route accessible (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    if ($_.Exception.Response.StatusCode -eq 503) {
        Write-Host "⚠️  Auth route configured but service not available (503)" -ForegroundColor Yellow
    } else {
        Write-Host "❌ Auth route test failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 4. Test Transaction Route
Write-Host "`n4. Testing Transaction Route (/api/transactions/*):" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/transactions" -UseBasicParsing -ErrorAction Stop
    Write-Host "✅ Transaction route accessible (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    if ($_.Exception.Response.StatusCode -eq 503) {
        Write-Host "⚠️  Transaction route configured but service not available (503)" -ForegroundColor Yellow
    } else {
        Write-Host "❌ Transaction route test failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 5. Test Analytics Route
Write-Host "`n5. Testing Analytics Route (/api/analytics/*):" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/analytics/reports" -UseBasicParsing -ErrorAction Stop
    Write-Host "✅ Analytics route accessible (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    if ($_.Exception.Response.StatusCode -eq 503) {
        Write-Host "⚠️  Analytics route configured but service not available (503)" -ForegroundColor Yellow
    } else {
        Write-Host "❌ Analytics route test failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n✅ Gateway Testing Complete!" -ForegroundColor Green
Write-Host "Note: 503 errors are expected when backend services aren't running yet." -ForegroundColor Gray
```

Run it:

```powershell
cd "d:\Semester 4\Web-App\Capstones\zuul-gateway"
.\test-gateway.ps1
```

---

## Using cURL (Command Line)

### Health Check:

```bash
curl http://localhost:8080/actuator/health
```

### View Routes:

```bash
curl http://localhost:8080/actuator/gateway/routes
```

### Test Auth Endpoint:

```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

### Test with Authorization Header:

```bash
curl http://localhost:8080/api/transactions \
  -H "Authorization: Bearer your-token-here"
```

---

## Checking Logs

View real-time gateway logs:

```bash
# In the terminal where gateway is running, you'll see:
# - Request Method and URL
# - Response Status
# - Routing decisions
# - Any errors
```

Look for these log patterns:

```
INFO  c.e.zuul.filter.LoggingFilter : Request Method: GET, URL: http://localhost:8080/api/auth/test
INFO  c.e.zuul.filter.LoggingFilter : Response Status: 503
```

---

## Troubleshooting

### Gateway won't start:

```powershell
# Check if port 8080 is already in use
Get-NetTCPConnection -LocalPort 8080

# Kill the process if needed
Stop-Process -Id <ProcessId> -Force
```

### Routes not working:

1. Check Eureka Server is running on port 8761
2. Verify backend services are registered in Eureka
3. Check service names match exactly in `application.yml`

### 503 Service Unavailable:

- **This is expected** when backend services aren't running yet
- Gateway is working correctly, just no services to route to
- Start the backend services to fix this

### CORS errors from Angular:

- Already configured in `application.yml`
- Check browser console for specific CORS errors
- Verify `allowedOriginPatterns: "*"` is set

---

## Expected Behavior Summary

| Endpoint                   | Without Backend Services   | With Backend Services             |
| -------------------------- | -------------------------- | --------------------------------- |
| `/actuator/health`         | ✅ 200 OK                  | ✅ 200 OK                         |
| `/actuator/gateway/routes` | ✅ 200 OK with route list  | ✅ 200 OK with route list         |
| `/api/auth/**`             | ❌ 503 Service Unavailable | ✅ Proxied to user-auth-service   |
| `/api/transactions/**`     | ❌ 503 Service Unavailable | ✅ Proxied to transaction-service |
| `/api/analytics/**`        | ❌ 503 Service Unavailable | ✅ Proxied to analytics-service   |

---

## Next Steps

Once backend services are running:

1. They will register with Eureka Server
2. Gateway will automatically discover them
3. Requests will be load-balanced across instances
4. Full routing will be operational

**Your gateway is ready and waiting for the backend services! 🚀**
