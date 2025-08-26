# Day 6: Deploy Dockerized App to Kubernetes

This directory contains the Kubernetes manifests and application code for deploying a Flask web application to Kubernetes.

## Application Overview

The sample application is a Flask web server that provides:
- Health check endpoint (`/health`)
- Home page (`/`)
- Addition API (`/add` - POST endpoint)
- Pod information endpoint (`/info`)

## Files Structure

```
Day6_Kubernetes/
├── app.py              # Flask web application
├── requirements.txt    # Python dependencies
├── Dockerfile         # Container configuration
├── namespace.yaml     # Kubernetes namespace
├── deployment.yaml    # Kubernetes deployment
├── service.yaml       # Kubernetes service
└── README.md         # This file
```

## Prerequisites

1. **Docker** - for building the container image
2. **Kubernetes cluster** - Minikube, Kind, or cloud provider
3. **kubectl** - Kubernetes command-line tool

## Quick Start

### 1. Build the Docker Image

```bash
# Build the image
docker build -t sample-app:latest .

# For Minikube (if using local registry)
eval $(minikube docker-env)
docker build -t sample-app:latest .
```

### 2. Deploy to Kubernetes

```bash
# Create namespace
kubectl apply -f namespace.yaml

# Deploy the application
kubectl apply -f deployment.yaml

# Create the service
kubectl apply -f service.yaml
```

### 3. Verify Deployment

```bash
# Check pods
kubectl get pods -n devops7days

# Check services
kubectl get svc -n devops7days

# Check deployment
kubectl get deployment -n devops7days
```

### 4. Access the Application

#### Using Minikube:
```bash
minikube service sample-app-service -n devops7days
```

#### Using NodePort directly:
```bash
# Get the node IP
kubectl get nodes -o wide

# Access via: http://<node-ip>:30007
```

#### Using kubectl port-forward:
```bash
kubectl port-forward svc/sample-app-service 8080:80 -n devops7days
# Then access: http://localhost:8080
```

## API Endpoints

### Health Check
```bash
curl http://localhost:30007/health
```

### Home Page
```bash
curl http://localhost:30007/
```

### Addition API
```bash
curl -X POST http://localhost:30007/add \
  -H "Content-Type: application/json" \
  -d '{"x": 5, "y": 3}'
```

### Pod Information
```bash
curl http://localhost:30007/info
```

## Kubernetes Resources

### Deployment
- **Replicas**: 2 (for high availability)
- **Resource Limits**: 128Mi memory, 100m CPU
- **Resource Requests**: 64Mi memory, 50m CPU
- **Health Checks**: Liveness and readiness probes

### Service
- **Type**: NodePort
- **Port**: 80 (service port)
- **Target Port**: 5000 (container port)
- **Node Port**: 30007 (external access)

## Scaling

Scale the deployment:
```bash
kubectl scale deployment sample-app --replicas=3 -n devops7days
```

## Monitoring

Check pod logs:
```bash
kubectl logs -f deployment/sample-app -n devops7days
```

Check pod status:
```bash
kubectl describe pods -l app=sample-app -n devops7days
```

## Cleanup

Remove all resources:
```bash
kubectl delete namespace devops7days
```

## Troubleshooting

### Common Issues

1. **Image Pull Error**: Make sure the image is available in your cluster
2. **Port Access Issues**: Verify the NodePort is not conflicting
3. **Pod Not Ready**: Check logs and health probe configuration

### Useful Commands

```bash
# Get detailed pod information
kubectl describe pod <pod-name> -n devops7days

# Check events
kubectl get events -n devops7days

# Check service endpoints
kubectl get endpoints sample-app-service -n devops7days
```
