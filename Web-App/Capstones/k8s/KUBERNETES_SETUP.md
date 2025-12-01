# Kubernetes Setup Guide

## Prerequisites

- Kubernetes cluster (Minikube, Docker Desktop, or cloud provider)
- kubectl installed and configured
- Docker images built and available

## Quick Start

### 1. Create Namespace

```powershell
kubectl apply -f k8s/namespace.yaml
```

### 2. Create ConfigMaps and Secrets

```powershell
# Create ConfigMap
kubectl apply -f k8s/configmap.yaml

# Create Secrets (update with actual values first!)
kubectl apply -f k8s/secrets.yaml
```

### 3. Deploy Infrastructure Services

```powershell
# Deploy Eureka Server
kubectl apply -f k8s/eureka-server-deployment.yaml

# Wait for Eureka to be ready
kubectl wait --for=condition=ready pod -l app=eureka-server -n finance-tracker --timeout=300s

# Deploy Zuul Gateway
kubectl apply -f k8s/zuul-gateway-deployment.yaml
```

### 4. Deploy Microservices (when ready)

```powershell
kubectl apply -f k8s/user-auth-service-deployment.yaml
kubectl apply -f k8s/transaction-service-deployment.yaml
kubectl apply -f k8s/analytics-service-deployment.yaml
```

### 5. Set up Ingress (optional)

```powershell
# Install NGINX Ingress Controller (if not already installed)
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml

# Apply Ingress rules
kubectl apply -f k8s/ingress.yaml
```

## Using Minikube

### Start Minikube

```powershell
minikube start --memory=4096 --cpus=2
```

### Load Docker images

```powershell
minikube image load eureka-server:latest
minikube image load zuul-gateway:latest
```

### Enable Ingress

```powershell
minikube addons enable ingress
```

### Access services

```powershell
# Get Minikube IP
minikube ip

# Access Eureka
minikube service eureka-server -n finance-tracker

# Access Gateway
minikube service zuul-gateway -n finance-tracker
```

## Using Docker Desktop Kubernetes

### Enable Kubernetes

1. Open Docker Desktop Settings
2. Go to Kubernetes tab
3. Check "Enable Kubernetes"
4. Click "Apply & Restart"

### Access services

```powershell
# Services will be available at localhost with LoadBalancer type
# Eureka: http://localhost:8761
# Gateway: http://localhost:8080
```

## Monitoring and Management

### Check pod status

```powershell
kubectl get pods -n finance-tracker
```

### View logs

```powershell
# Eureka Server
kubectl logs -f deployment/eureka-server -n finance-tracker

# Zuul Gateway
kubectl logs -f deployment/zuul-gateway -n finance-tracker

# Specific pod
kubectl logs -f <pod-name> -n finance-tracker
```

### Describe resources

```powershell
# Deployment
kubectl describe deployment eureka-server -n finance-tracker

# Service
kubectl describe service zuul-gateway -n finance-tracker

# Pod
kubectl describe pod <pod-name> -n finance-tracker
```

### Execute commands in pod

```powershell
kubectl exec -it <pod-name> -n finance-tracker -- sh
```

### Port forwarding (for local testing)

```powershell
# Forward Eureka Server
kubectl port-forward service/eureka-server 8761:8761 -n finance-tracker

# Forward Gateway
kubectl port-forward service/zuul-gateway 8080:8080 -n finance-tracker
```

## Scaling

### Scale deployments

```powershell
# Scale Gateway replicas
kubectl scale deployment zuul-gateway --replicas=3 -n finance-tracker

# Scale microservices
kubectl scale deployment user-auth-service --replicas=3 -n finance-tracker
```

### Auto-scaling (HPA)

```powershell
# Create HorizontalPodAutoscaler
kubectl autoscale deployment zuul-gateway --cpu-percent=70 --min=2 --max=5 -n finance-tracker
```

## Troubleshooting

### Check events

```powershell
kubectl get events -n finance-tracker --sort-by='.lastTimestamp'
```

### Check resource usage

```powershell
kubectl top pods -n finance-tracker
kubectl top nodes
```

### Restart deployment

```powershell
kubectl rollout restart deployment/zuul-gateway -n finance-tracker
```

### Delete and recreate

```powershell
# Delete deployment
kubectl delete -f k8s/zuul-gateway-deployment.yaml

# Recreate
kubectl apply -f k8s/zuul-gateway-deployment.yaml
```

## Clean Up

### Delete specific resources

```powershell
kubectl delete -f k8s/zuul-gateway-deployment.yaml
kubectl delete -f k8s/eureka-server-deployment.yaml
```

### Delete entire namespace

```powershell
kubectl delete namespace finance-tracker
```

### Stop Minikube

```powershell
minikube stop
minikube delete
```

## Architecture

```
┌─────────────────────────────────────────────┐
│          Ingress (finance-tracker.local)    │
└─────────────────┬───────────────────────────┘
                  │
         ┌────────┴─────────┐
         │                  │
    ┌────▼─────┐      ┌────▼──────┐
    │  Eureka  │      │  Gateway  │
    │  Server  │◄─────┤  (Zuul)   │
    └──────────┘      └─────┬─────┘
                            │
              ┌─────────────┼─────────────┐
              │             │             │
         ┌────▼────┐   ┌────▼────┐   ┌───▼─────┐
         │  User   │   │  Trans  │   │ Analyt  │
         │  Auth   │   │ action  │   │  ics    │
         │ Service │   │ Service │   │ Service │
         └─────────┘   └─────────┘   └─────────┘
```

## Configuration Files

- `namespace.yaml` - Namespace definition
- `configmap.yaml` - Application configuration
- `secrets.yaml` - Sensitive data (credentials, API keys)
- `eureka-server-deployment.yaml` - Eureka Server deployment & service
- `zuul-gateway-deployment.yaml` - API Gateway deployment & service
- `user-auth-service-deployment.yaml` - User Auth microservice
- `transaction-service-deployment.yaml` - Transaction microservice
- `analytics-service-deployment.yaml` - Analytics microservice
- `ingress.yaml` - Ingress rules for external access

## Service Types

- **LoadBalancer**: Eureka Server, Zuul Gateway (external access)
- **ClusterIP**: Microservices (internal only, accessed via Gateway)

## Resource Requests/Limits

Default settings per service:

- Requests: 512Mi memory, 250m CPU
- Limits: 1Gi memory, 500m CPU

Adjust based on actual usage and available resources.
