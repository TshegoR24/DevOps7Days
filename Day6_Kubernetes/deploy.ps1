# Day 6 Kubernetes Deployment Script for Windows
# This script builds the Docker image and deploys to Kubernetes

param(
    [switch]$SkipBuild
)

Write-Host "🚀 Starting Day 6 Kubernetes Deployment..." -ForegroundColor Green

# Function to print colored output
function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Check if Docker is running
try {
    docker info | Out-Null
} catch {
    Write-Error "Docker is not running. Please start Docker first."
    exit 1
}

# Check if kubectl is available
try {
    kubectl version --client | Out-Null
} catch {
    Write-Error "kubectl is not installed. Please install kubectl first."
    exit 1
}

# Check if Kubernetes cluster is accessible
try {
    kubectl cluster-info | Out-Null
} catch {
    Write-Error "Cannot connect to Kubernetes cluster. Please ensure your cluster is running."
    exit 1
}

if (-not $SkipBuild) {
    Write-Status "Building Docker image..."
    docker build -t sample-app:latest .
}

Write-Status "Creating namespace..."
kubectl apply -f namespace.yaml

Write-Status "Deploying application..."
kubectl apply -f deployment.yaml

Write-Status "Creating service..."
kubectl apply -f service.yaml

Write-Status "Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=sample-app -n devops7days --timeout=300s

Write-Status "Deployment completed successfully! 🎉"

Write-Host ""
Write-Host "📊 Deployment Status:" -ForegroundColor Cyan
Write-Host "=====================" -ForegroundColor Cyan
kubectl get pods -n devops7days
Write-Host ""
kubectl get svc -n devops7days
Write-Host ""

Write-Status "Access your application:"
Write-Host "  • Minikube: minikube service sample-app-service -n devops7days" -ForegroundColor White
Write-Host "  • NodePort: http://localhost:30007 (if using Kind or other local cluster)" -ForegroundColor White
Write-Host "  • Port-forward: kubectl port-forward svc/sample-app-service 8080:80 -n devops7days" -ForegroundColor White

Write-Host ""
Write-Status "Useful commands:"
Write-Host "  • Check logs: kubectl logs -f deployment/sample-app -n devops7days" -ForegroundColor White
Write-Host "  • Scale up: kubectl scale deployment sample-app --replicas=3 -n devops7days" -ForegroundColor White
Write-Host "  • Cleanup: kubectl delete namespace devops7days" -ForegroundColor White
