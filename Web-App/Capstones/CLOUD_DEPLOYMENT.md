# Cloud Deployment Guide

## Quick Deploy Options for Your Team

### Option 1: Docker Hub + Render.com (RECOMMENDED - FREE)

#### Step 1: Push Images to Docker Hub

```powershell
# Login to Docker Hub
docker login

# Tag your images
docker tag capstones-eureka-server:latest mengfong/eureka-server:latest
docker tag capstones-zuul-gateway:latest mengfong/zuul-gateway:latest

# Push to Docker Hub
docker push mengfong/eureka-server:latest
docker push mengfong/zuul-gateway:latest
```

#### Step 2: Deploy on Render.com

**IMPORTANT:** Render automatically detects ports. Set the `PORT` environment variable if needed.

##### Deploy Eureka Server:

1. Go to https://render.com and sign up (free)
2. Click **"New +"** → **"Web Service"**
3. Select **"Deploy an existing image from a registry"**
4. Configure:
   - **Image URL:** `mengfong/eureka-server:latest`
   - **Name:** `eureka-server`
   - **Region:** Choose closest to you (e.g., Singapore)
   - **Instance Type:** `Free`
5. Click **"Advanced"** (optional - only if Render doesn't detect port):
   - Add Environment Variable:
     - **Key:** `PORT`
     - **Value:** `8761`
6. Click **"Create Web Service"**
7. Wait 2-5 minutes for deployment

##### Deploy Zuul Gateway:

1. Click **"New +"** → **"Web Service"**
2. Select **"Deploy an existing image from a registry"**
3. Configure:
   - **Image URL:** `mengfong/zuul-gateway:latest`
   - **Name:** `zuul-gateway`
   - **Region:** Same as Eureka Server
   - **Instance Type:** `Free`
4. Add **Environment Variables**:
   - Variable 1:
     - **Key:** `PORT`
     - **Value:** `8080`
   - Variable 2:
     - **Key:** `EUREKA_CLIENT_SERVICEURL_DEFAULTZONE`
     - **Value:** `https://eureka-server-6yh5.onrender.com/eureka/`
5. Click **"Create Web Service"**
6. Wait 2-5 minutes for deployment

#### Step 3: Share URLs with Team

- Eureka: `https://eureka-server-6yh5.onrender.com`
- Gateway: `https://zuul-gateway.onrender.com`
- Swagger: `https://zuul-gateway.onrender.com/swagger-ui.html`

---

### Option 2: Railway.app (FREE - Easiest)

#### Deploy via GitHub

1. Push your code to GitHub
2. Go to https://railway.app and sign up
3. New Project → Deploy from GitHub
4. Select your repository
5. Railway auto-detects Dockerfiles and deploys both services

**Advantages:**

- Automatic HTTPS
- Environment variables management
- Free tier: $5 credit/month
- Easy rollbacks

---

### Option 3: Heroku (Paid but Reliable)

#### Deploy Eureka Server

```powershell
# Install Heroku CLI
# https://devcenter.heroku.com/articles/heroku-cli

cd eureka-server
heroku login
heroku create your-team-eureka-server
heroku container:login
heroku container:push web -a your-team-eureka-server
heroku container:release web -a your-team-eureka-server
```

#### Deploy Gateway

```powershell
cd zuul-gateway
heroku create your-team-gateway
heroku config:set EUREKA_CLIENT_SERVICEURL_DEFAULTZONE=https://your-team-eureka-server.herokuapp.com/eureka/ -a your-team-gateway
heroku container:push web -a your-team-gateway
heroku container:release web -a your-team-gateway
```

---

### Option 4: Azure Container Instances (If you have Azure credits)

```powershell
# Login to Azure
az login

# Create Resource Group
az group create --name capstones-rg --location eastus

# Deploy Eureka Server
az container create `
  --resource-group capstones-rg `
  --name eureka-server `
  --image mengfong/eureka-server:latest `
  --dns-name-label your-team-eureka `
  --ports 8761

# Deploy Gateway
az container create `
  --resource-group capstones-rg `
  --name zuul-gateway `
  --image mengfong/zuul-gateway:latest `
  --dns-name-label your-team-gateway `
  --ports 8080 `
  --environment-variables EUREKA_CLIENT_SERVICEURL_DEFAULTZONE=http://your-team-eureka.eastus.azurecontainer.io:8761/eureka/

# Get URLs
az container show --resource-group capstones-rg --name eureka-server --query ipAddress.fqdn
az container show --resource-group capstones-rg --name zuul-gateway --query ipAddress.fqdn
```

---

### Option 5: ngrok (Quick Testing - Not for Production)

**Fastest way to share localhost with teammates (for testing only):**

```powershell
# Install ngrok: https://ngrok.com/download

# Expose Eureka (in one terminal)
ngrok http 8761

# Expose Gateway (in another terminal)
ngrok http 8080
```

**Share the ngrok URLs with your team:**

- Eureka: `https://xxxxx.ngrok.io`
- Gateway: `https://yyyyy.ngrok.io`

**Limitations:**

- URLs change each time you restart
- Free tier has connection limits
- Only for temporary testing

---

## Recommended Approach for Your Team

### **Best: Render.com (Free + Persistent)**

**Why Render.com?**

- ✓ Free tier with 750 hours/month (enough for development)
- ✓ Automatic HTTPS
- ✓ Persistent URLs
- ✓ Easy deployment from Docker images
- ✓ No credit card required for free tier
- ✓ Auto-sleep after 15 min inactivity (free tier), wakes on request

**For Development Team:**

1. **DevOps (You)**: Deploy Eureka + Gateway to Render
2. **Backend Developers**: Register their services with your Eureka URL
3. **Frontend Developers**: Call APIs via your Gateway URL

### Configuration for Teammates

Once deployed, your teammates should configure their services:

**application.yml for teammate services:**

```yaml
eureka:
  client:
    service-url:
      defaultZone: https://eureka-server.onrender.com/eureka/
    register-with-eureka: true
    fetch-registry: true
```

**API calls from frontend:**

```javascript
const API_BASE_URL = "https://zuul-gateway.onrender.com";
fetch(`${API_BASE_URL}/api/auth/login`, {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({ username, password }),
});
```

---

## Cost Comparison

| Platform        | Free Tier              | Best For          |
| --------------- | ---------------------- | ----------------- |
| **Render.com**  | 750 hrs/month          | Development teams |
| **Railway.app** | $5 credit/month        | Quick deploys     |
| **Heroku**      | None (paid only)       | Production apps   |
| **Azure**       | $200 credit (students) | Learning Azure    |
| **ngrok**       | Limited connections    | Quick testing     |

---

## Next Steps

1. Choose a platform (I recommend Render.com)
2. Push Docker images to Docker Hub
3. Deploy both services
4. Share URLs with your team
5. Update their configuration to use your URLs

Need help with any specific deployment? Let me know which platform you prefer!
