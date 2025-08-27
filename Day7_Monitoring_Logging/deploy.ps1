# Day 7 Monitoring & Logging Deployment Script (PowerShell)
# This script automates the entire setup process

param(
    [string]$Namespace = "monitoring",
    [string]$AppName = "sample-app",
    [string]$Registry = "localhost:5000"  # Change this for your registry
)

# Configuration
$ErrorActionPreference = "Stop"

Write-Host "🚀 Day 7: Monitoring & Logging Setup" -ForegroundColor Blue
Write-Host "==================================" -ForegroundColor Blue

# Function to check prerequisites
function Test-Prerequisites {
    Write-Host "📋 Checking prerequisites..." -ForegroundColor Yellow
    
    # Check if kubectl is installed
    if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
        Write-Host "❌ kubectl is not installed" -ForegroundColor Red
        exit 1
    }
    
    # Check if helm is installed
    if (-not (Get-Command helm -ErrorAction SilentlyContinue)) {
        Write-Host "❌ helm is not installed" -ForegroundColor Red
        exit 1
    }
    
    # Check if docker is installed
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        Write-Host "❌ docker is not installed" -ForegroundColor Red
        exit 1
    }
    
    # Check if minikube is running (optional)
    if (Get-Command minikube -ErrorAction SilentlyContinue) {
        $minikubeStatus = minikube status 2>$null
        if ($minikubeStatus -notmatch "Running") {
            Write-Host "⚠️  Minikube is not running. Starting it..." -ForegroundColor Yellow
            minikube start
        }
    }
    
    Write-Host "✅ Prerequisites check passed" -ForegroundColor Green
}

# Function to build and push the application
function Build-Application {
    Write-Host "🔨 Building application..." -ForegroundColor Yellow
    
    # Build the Docker image
    docker build -t $AppName:latest .
    
    # Tag for registry
    docker tag $AppName:latest $Registry/$AppName:latest
    
    # Push to registry (if registry is available)
    try {
        docker push $Registry/$AppName:latest 2>$null
        Write-Host "✅ Image pushed to registry" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  Could not push to registry, using local image" -ForegroundColor Yellow
        # For local development, we'll use the local image
        $script:Registry = ""
    }
    
    Write-Host "✅ Application built successfully" -ForegroundColor Green
}

# Function to install monitoring stack
function Install-Monitoring {
    Write-Host "📊 Installing monitoring stack..." -ForegroundColor Yellow
    
    # Add Helm repositories
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo add grafana https://grafana.github.io/helm-charts
    helm repo update
    
    # Create monitoring namespace
    kubectl create namespace $Namespace --dry-run=client -o yaml | kubectl apply -f -
    
    # Install Prometheus Stack
    Write-Host "Installing Prometheus & Grafana..." -ForegroundColor Yellow
    helm install monitoring prometheus-community/kube-prometheus-stack `
        --namespace $Namespace `
        --set grafana.enabled=true `
        --set prometheus.enabled=true `
        --set alertmanager.enabled=true `
        --wait --timeout=10m
    
    # Install Loki for logging
    Write-Host "Installing Loki for logging..." -ForegroundColor Yellow
    helm install loki grafana/loki `
        --namespace $Namespace `
        --set loki.auth_enabled=false `
        --wait --timeout=5m
    
    Write-Host "✅ Monitoring stack installed successfully" -ForegroundColor Green
}

# Function to deploy the sample application
function Deploy-Application {
    Write-Host "🚀 Deploying sample application..." -ForegroundColor Yellow
    
    # Update the deployment to use the correct image
    if ($Registry) {
        # Use registry image
        (Get-Content sample-app.yaml) -replace "image: sample-app:latest", "image: $Registry/$AppName:latest" | kubectl apply -f -
    } else {
        # Use local image (for minikube)
        if (Get-Command minikube -ErrorAction SilentlyContinue) {
            Write-Host "Loading image into minikube..." -ForegroundColor Yellow
            minikube image load $AppName:latest
        }
        kubectl apply -f sample-app.yaml
    }
    
    # Apply ServiceMonitor
    kubectl apply -f servicemonitor.yaml
    
    # Apply Grafana dashboard
    kubectl apply -f grafana-dashboard.yaml
    
    # Wait for application to be ready
    Write-Host "Waiting for application to be ready..." -ForegroundColor Yellow
    kubectl wait --for=condition=available --timeout=300s deployment/$AppName
    
    Write-Host "✅ Application deployed successfully" -ForegroundColor Green
}

# Function to verify the setup
function Test-Setup {
    Write-Host "🔍 Verifying setup..." -ForegroundColor Yellow
    
    # Check if all pods are running
    Write-Host "Checking pod status..." -ForegroundColor Yellow
    kubectl get pods -n $Namespace
    kubectl get pods -l app=$AppName
    
    # Check if services are created
    Write-Host "Checking services..." -ForegroundColor Yellow
    kubectl get svc -n $Namespace
    kubectl get svc -l app=$AppName
    
    # Check if ServiceMonitor is created
    Write-Host "Checking ServiceMonitor..." -ForegroundColor Yellow
    kubectl get servicemonitor
    
    Write-Host "✅ Setup verification completed" -ForegroundColor Green
}

# Function to show access information
function Show-AccessInfo {
    Write-Host "🎯 Access Information" -ForegroundColor Blue
    Write-Host "==================" -ForegroundColor Blue
    Write-Host ""
    Write-Host "📊 Grafana Dashboard:" -ForegroundColor Yellow
    Write-Host "  kubectl port-forward svc/monitoring-grafana 3000:80 -n $Namespace" -ForegroundColor Cyan
    Write-Host "  URL: http://localhost:3000" -ForegroundColor Cyan
    Write-Host "  Username: admin" -ForegroundColor Cyan
    Write-Host "  Password: prom-operator" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "📈 Prometheus:" -ForegroundColor Yellow
    Write-Host "  kubectl port-forward svc/monitoring-kube-prometheus-prometheus 9090:9090 -n $Namespace" -ForegroundColor Cyan
    Write-Host "  URL: http://localhost:9090" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "🚀 Sample Application:" -ForegroundColor Yellow
    Write-Host "  kubectl port-forward svc/sample-app-service 8080:80" -ForegroundColor Cyan
    Write-Host "  URL: http://localhost:8080" -ForegroundColor Cyan
    Write-Host "  Health: http://localhost:8080/health" -ForegroundColor Cyan
    Write-Host "  Metrics: http://localhost:8080/metrics" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "📝 Load Testing:" -ForegroundColor Yellow
    Write-Host "  ./load-test.sh (Linux/Mac)" -ForegroundColor Cyan
    Write-Host "  ./load-test.ps1 (Windows PowerShell)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "🔍 Useful Commands:" -ForegroundColor Yellow
    Write-Host "  kubectl logs -l app=$AppName" -ForegroundColor Cyan
    Write-Host "  kubectl get pods -n $Namespace" -ForegroundColor Cyan
    Write-Host "  kubectl get svc -n $Namespace" -ForegroundColor Cyan
    Write-Host ""
}

# Function to run quick test
function Test-QuickTest {
    Write-Host "🧪 Running quick test..." -ForegroundColor Yellow
    
    # Port forward the application
    $job = Start-Job -ScriptBlock {
        kubectl port-forward svc/sample-app-service 8080:80
    }
    
    # Wait for port forward to be ready
    Start-Sleep -Seconds 5
    
    # Test the application
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080/health" -UseBasicParsing -TimeoutSec 5
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ Application is responding" -ForegroundColor Green
            
            # Test metrics endpoint
            $metricsResponse = Invoke-WebRequest -Uri "http://localhost:8080/metrics" -UseBasicParsing -TimeoutSec 5
            if ($metricsResponse.Content -match "app_request_total") {
                Write-Host "✅ Metrics endpoint is working" -ForegroundColor Green
            } else {
                Write-Host "⚠️  Metrics endpoint may not be working properly" -ForegroundColor Yellow
            }
            
            # Generate some test traffic
            Write-Host "Generating test traffic..." -ForegroundColor Yellow
            for ($i = 1; $i -le 10; $i++) {
                try {
                    Invoke-WebRequest -Uri "http://localhost:8080/" -UseBasicParsing -TimeoutSec 5 | Out-Null
                    Invoke-WebRequest -Uri "http://localhost:8080/api/data" -UseBasicParsing -TimeoutSec 5 | Out-Null
                } catch {
                    # Ignore errors for testing
                }
                Start-Sleep -Milliseconds 100
            }
            Write-Host "✅ Test traffic generated" -ForegroundColor Green
            
        } else {
            Write-Host "❌ Application returned status: $($response.StatusCode)" -ForegroundColor Red
        }
    } catch {
        Write-Host "❌ Application is not responding" -ForegroundColor Red
    }
    
    # Stop port forward job
    Stop-Job $job
    Remove-Job $job
}

# Main execution
function Main {
    Test-Prerequisites
    Build-Application
    Install-Monitoring
    Deploy-Application
    Test-Setup
    Show-AccessInfo
    
    Write-Host "🎉 Setup completed successfully!" -ForegroundColor Green
    Write-Host ""
    
    # Ask if user wants to run a quick test
    $runTest = Read-Host "Do you want to run a quick test? (y/n)"
    if ($runTest -eq "y" -or $runTest -eq "Y") {
        Test-QuickTest
    }
    
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Blue
    Write-Host "1. Access Grafana and explore the dashboards" -ForegroundColor White
    Write-Host "2. Run load tests to generate traffic" -ForegroundColor White
    Write-Host "3. Check Prometheus targets and metrics" -ForegroundColor White
    Write-Host "4. Explore logs in Grafana with Loki" -ForegroundColor White
    Write-Host ""
    Write-Host "Happy monitoring! 🚀" -ForegroundColor Green
}

# Run main function
Main
