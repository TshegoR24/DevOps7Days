# 🚀 Day 6 Quick Start Guide

## Prerequisites
- Docker running
- Kubernetes cluster (Minikube/Kind)
- kubectl installed

## One-Command Deployment

### Windows (PowerShell):
```powershell
.\deploy.ps1
```

### Linux/Mac:
```bash
chmod +x deploy.sh
./deploy.sh
```

## Manual Deployment Steps

1. **Build Image:**
   ```bash
   docker build -t sample-app:latest .
   ```

2. **Deploy to Kubernetes:**
   ```bash
   kubectl apply -f namespace.yaml
   kubectl apply -f deployment.yaml
   kubectl apply -f service.yaml
   ```

3. **Check Status:**
   ```bash
   kubectl get pods -n devops7days
   kubectl get svc -n devops7days
   ```

## Access Your App

- **Minikube:** `minikube service sample-app-service -n devops7days`
- **NodePort:** `http://localhost:30007`
- **Port-forward:** `kubectl port-forward svc/sample-app-service 8080:80 -n devops7days`

## Test Your App

```bash
python test_deployment.py
```

## Cleanup

```bash
kubectl delete namespace devops7days
```

## Key Endpoints

- `GET /` - Home page
- `GET /health` - Health check
- `POST /add` - Addition API
- `GET /info` - Pod information

## Useful Commands

```bash
# Scale up
kubectl scale deployment sample-app --replicas=3 -n devops7days

# Check logs
kubectl logs -f deployment/sample-app -n devops7days

# Describe resources
kubectl describe deployment sample-app -n devops7days
kubectl describe service sample-app-service -n devops7days
```
