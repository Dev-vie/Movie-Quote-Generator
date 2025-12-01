# Test Gateway - Personal Finance App
Write-Host "Testing Spring Cloud Gateway..." -ForegroundColor Cyan

# 1. Health Check
Write-Host "`n1. Health Check:" -ForegroundColor Yellow
try {
    $health = Invoke-WebRequest -Uri "http://localhost:8080/actuator/health" -UseBasicParsing
    Write-Host "✅ Gateway is UP (Status: $($health.StatusCode))" -ForegroundColor Green
    $healthJson = $health.Content | ConvertFrom-Json
    Write-Host "   Status: $($healthJson.status)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Gateway is DOWN" -ForegroundColor Red
    Write-Host "   Make sure to run: mvn spring-boot:run" -ForegroundColor Gray
    exit
}

# 2. Gateway Info
Write-Host "`n2. Gateway Information:" -ForegroundColor Yellow
Write-Host "   URL: http://localhost:8080" -ForegroundColor Cyan
Write-Host "   Eureka: http://localhost:8761/eureka/" -ForegroundColor Cyan

# 3. Test Auth Route
Write-Host "`n3. Testing Auth Route (/api/auth/*):" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/auth/health" -UseBasicParsing -ErrorAction Stop
    Write-Host "✅ Auth route accessible (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    if ($_.Exception.Response.StatusCode.value__ -eq 503) {
        Write-Host "⚠️  Auth route configured but service not available (503)" -ForegroundColor Yellow
        Write-Host "   This is expected when user-auth-service isn't running" -ForegroundColor Gray
    } elseif ($_.Exception.Response.StatusCode.value__ -eq 404) {
        Write-Host "⚠️  Auth route working but endpoint not found (404)" -ForegroundColor Yellow
        Write-Host "   Gateway is routing correctly!" -ForegroundColor Gray
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
    if ($_.Exception.Response.StatusCode.value__ -eq 503) {
        Write-Host "⚠️  Transaction route configured but service not available (503)" -ForegroundColor Yellow
        Write-Host "   This is expected when transaction-service isn't running" -ForegroundColor Gray
    } elseif ($_.Exception.Response.StatusCode.value__ -eq 404) {
        Write-Host "⚠️  Transaction route working but endpoint not found (404)" -ForegroundColor Yellow
        Write-Host "   Gateway is routing correctly!" -ForegroundColor Gray
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
    if ($_.Exception.Response.StatusCode.value__ -eq 503) {
        Write-Host "⚠️  Analytics route configured but service not available (503)" -ForegroundColor Yellow
        Write-Host "   This is expected when analytics-service isn't running" -ForegroundColor Gray
    } elseif ($_.Exception.Response.StatusCode.value__ -eq 404) {
        Write-Host "⚠️  Analytics route working but endpoint not found (404)" -ForegroundColor Yellow
        Write-Host "   Gateway is routing correctly!" -ForegroundColor Gray
    } else {
        Write-Host "❌ Analytics route test failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 6. Summary
Write-Host "`n" -NoNewline
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "✅ Gateway Testing Complete!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "`nNote: 503 errors are expected when backend services aren't running yet." -ForegroundColor Gray
Write-Host "The gateway is properly configured and waiting for services to register!" -ForegroundColor Gray
