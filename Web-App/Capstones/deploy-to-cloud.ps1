# Quick Deploy to Docker Hub (for Render.com deployment)

Write-Host "`n=== Docker Hub Deployment Script ===" -ForegroundColor Cyan

# Get Docker Hub username
$dockerUsername = Read-Host "Enter your Docker Hub username"

if ([string]::IsNullOrWhiteSpace($dockerUsername)) {
    Write-Host "Error: Docker Hub username is required!" -ForegroundColor Red
    exit 1
}

Write-Host "`n1. Logging into Docker Hub..." -ForegroundColor Yellow
docker login

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Docker login failed!" -ForegroundColor Red
    exit 1
}

Write-Host "`n2. Tagging images..." -ForegroundColor Yellow
docker tag capstones-eureka-server:latest "$dockerUsername/eureka-server:latest"
docker tag capstones-zuul-gateway:latest "$dockerUsername/zuul-gateway:latest"

Write-Host "`n3. Pushing Eureka Server to Docker Hub..." -ForegroundColor Yellow
docker push "$dockerUsername/eureka-server:latest"

Write-Host "`n4. Pushing Zuul Gateway to Docker Hub..." -ForegroundColor Yellow
docker push "$dockerUsername/zuul-gateway:latest"

Write-Host "`n✓ Images pushed successfully!" -ForegroundColor Green

Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "NEXT STEPS: Deploy on Render.com" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan

Write-Host "`n1. Go to https://render.com and sign up (free)" -ForegroundColor Yellow
Write-Host "`n2. Deploy Eureka Server:" -ForegroundColor Yellow
Write-Host "   • Click 'New +' → 'Web Service'"
Write-Host "   • Select 'Deploy an existing image from a registry'"
Write-Host "   • Image URL: $dockerUsername/eureka-server:latest"
Write-Host "   • Name: eureka-server"
Write-Host "   • Port: 8761"
Write-Host "   • Instance Type: Free"
Write-Host "   • Click 'Create Web Service'"

Write-Host "`n3. Deploy Zuul Gateway:" -ForegroundColor Yellow
Write-Host "   • Click 'New +' → 'Web Service'"
Write-Host "   • Select 'Deploy an existing image from a registry'"
Write-Host "   • Image URL: $dockerUsername/zuul-gateway:latest"
Write-Host "   • Name: zuul-gateway"
Write-Host "   • Port: 8080"
Write-Host "   • Add Environment Variable:"
Write-Host "     Key: EUREKA_CLIENT_SERVICEURL_DEFAULTZONE"
Write-Host "     Value: https://eureka-server.onrender.com/eureka/"
Write-Host "   • Instance Type: Free"
Write-Host "   • Click 'Create Web Service'"

Write-Host "`n4. Share these URLs with your team:" -ForegroundColor Yellow
Write-Host "   • Eureka: https://eureka-server.onrender.com"
Write-Host "   • Gateway: https://zuul-gateway.onrender.com"
Write-Host "   • Swagger: https://zuul-gateway.onrender.com/swagger-ui.html"

Write-Host "`n═══════════════════════════════════════════════════════════`n" -ForegroundColor Cyan
