#!/bin/bash

# Day 6 Kubernetes Deployment Script
# This script builds the Docker image and deploys to Kubernetes

set -e

echo "🚀 Starting Day 6 Kubernetes Deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker first."
    exit 1
fi

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    print_error "kubectl is not installed. Please install kubectl first."
    exit 1
fi

# Check if Kubernetes cluster is accessible
if ! kubectl cluster-info &> /dev/null; then
    print_error "Cannot connect to Kubernetes cluster. Please ensure your cluster is running."
    exit 1
fi

print_status "Building Docker image..."
docker build -t sample-app:latest .

print_status "Creating namespace..."
kubectl apply -f namespace.yaml

print_status "Deploying application..."
kubectl apply -f deployment.yaml

print_status "Creating service..."
kubectl apply -f service.yaml

print_status "Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=sample-app -n devops7days --timeout=300s

print_status "Deployment completed successfully! 🎉"

echo ""
echo "📊 Deployment Status:"
echo "====================="
kubectl get pods -n devops7days
echo ""
kubectl get svc -n devops7days
echo ""

print_status "Access your application:"
echo "  • Minikube: minikube service sample-app-service -n devops7days"
echo "  • NodePort: http://localhost:30007 (if using Kind or other local cluster)"
echo "  • Port-forward: kubectl port-forward svc/sample-app-service 8080:80 -n devops7days"

echo ""
print_status "Useful commands:"
echo "  • Check logs: kubectl logs -f deployment/sample-app -n devops7days"
echo "  • Scale up: kubectl scale deployment sample-app --replicas=3 -n devops7days"
echo "  • Cleanup: kubectl delete namespace devops7days"
