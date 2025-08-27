#!/bin/bash

# Day 7 Monitoring & Logging Deployment Script
# This script automates the entire setup process

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE="monitoring"
APP_NAME="sample-app"
REGISTRY="localhost:5000"  # Change this for your registry

echo -e "${BLUE}🚀 Day 7: Monitoring & Logging Setup${NC}"
echo "=================================="

# Function to check prerequisites
check_prerequisites() {
    echo -e "${YELLOW}📋 Checking prerequisites...${NC}"
    
    # Check if kubectl is installed
    if ! command -v kubectl &> /dev/null; then
        echo -e "${RED}❌ kubectl is not installed${NC}"
        exit 1
    fi
    
    # Check if helm is installed
    if ! command -v helm &> /dev/null; then
        echo -e "${RED}❌ helm is not installed${NC}"
        exit 1
    fi
    
    # Check if docker is installed
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ docker is not installed${NC}"
        exit 1
    fi
    
    # Check if minikube is running (optional)
    if command -v minikube &> /dev/null; then
        if ! minikube status | grep -q "Running"; then
            echo -e "${YELLOW}⚠️  Minikube is not running. Starting it...${NC}"
            minikube start
        fi
    fi
    
    echo -e "${GREEN}✅ Prerequisites check passed${NC}"
}

# Function to build and push the application
build_application() {
    echo -e "${YELLOW}🔨 Building application...${NC}"
    
    # Build the Docker image
    docker build -t $APP_NAME:latest .
    
    # Tag for registry
    docker tag $APP_NAME:latest $REGISTRY/$APP_NAME:latest
    
    # Push to registry (if registry is available)
    if docker push $REGISTRY/$APP_NAME:latest 2>/dev/null; then
        echo -e "${GREEN}✅ Image pushed to registry${NC}"
    else
        echo -e "${YELLOW}⚠️  Could not push to registry, using local image${NC}"
        # For local development, we'll use the local image
        REGISTRY=""
    fi
    
    echo -e "${GREEN}✅ Application built successfully${NC}"
}

# Function to install monitoring stack
install_monitoring() {
    echo -e "${YELLOW}📊 Installing monitoring stack...${NC}"
    
    # Add Helm repositories
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo add grafana https://grafana.github.io/helm-charts
    helm repo update
    
    # Create monitoring namespace
    kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
    
    # Install Prometheus Stack
    echo -e "${YELLOW}Installing Prometheus & Grafana...${NC}"
    helm install monitoring prometheus-community/kube-prometheus-stack \
        --namespace $NAMESPACE \
        --set grafana.enabled=true \
        --set prometheus.enabled=true \
        --set alertmanager.enabled=true \
        --wait --timeout=10m
    
    # Install Loki for logging
    echo -e "${YELLOW}Installing Loki for logging...${NC}"
    helm install loki grafana/loki \
        --namespace $NAMESPACE \
        --set loki.auth_enabled=false \
        --wait --timeout=5m
    
    echo -e "${GREEN}✅ Monitoring stack installed successfully${NC}"
}

# Function to deploy the sample application
deploy_application() {
    echo -e "${YELLOW}🚀 Deploying sample application...${NC}"
    
    # Update the deployment to use the correct image
    if [ -n "$REGISTRY" ]; then
        # Use registry image
        sed "s|image: sample-app:latest|image: $REGISTRY/$APP_NAME:latest|g" sample-app.yaml | kubectl apply -f -
    else
        # Use local image (for minikube)
        if command -v minikube &> /dev/null; then
            echo -e "${YELLOW}Loading image into minikube...${NC}"
            minikube image load $APP_NAME:latest
        fi
        kubectl apply -f sample-app.yaml
    fi
    
    # Apply ServiceMonitor
    kubectl apply -f servicemonitor.yaml
    
    # Apply Grafana dashboard
    kubectl apply -f grafana-dashboard.yaml
    
    # Wait for application to be ready
    echo -e "${YELLOW}Waiting for application to be ready...${NC}"
    kubectl wait --for=condition=available --timeout=300s deployment/$APP_NAME
    
    echo -e "${GREEN}✅ Application deployed successfully${NC}"
}

# Function to verify the setup
verify_setup() {
    echo -e "${YELLOW}🔍 Verifying setup...${NC}"
    
    # Check if all pods are running
    echo -e "${YELLOW}Checking pod status...${NC}"
    kubectl get pods -n $NAMESPACE
    kubectl get pods -l app=$APP_NAME
    
    # Check if services are created
    echo -e "${YELLOW}Checking services...${NC}"
    kubectl get svc -n $NAMESPACE
    kubectl get svc -l app=$APP_NAME
    
    # Check if ServiceMonitor is created
    echo -e "${YELLOW}Checking ServiceMonitor...${NC}"
    kubectl get servicemonitor
    
    echo -e "${GREEN}✅ Setup verification completed${NC}"
}

# Function to show access information
show_access_info() {
    echo -e "${BLUE}🎯 Access Information${NC}"
    echo "=================="
    echo ""
    echo -e "${YELLOW}📊 Grafana Dashboard:${NC}"
    echo "  kubectl port-forward svc/monitoring-grafana 3000:80 -n $NAMESPACE"
    echo "  URL: http://localhost:3000"
    echo "  Username: admin"
    echo "  Password: prom-operator"
    echo ""
    echo -e "${YELLOW}📈 Prometheus:${NC}"
    echo "  kubectl port-forward svc/monitoring-kube-prometheus-prometheus 9090:9090 -n $NAMESPACE"
    echo "  URL: http://localhost:9090"
    echo ""
    echo -e "${YELLOW}🚀 Sample Application:${NC}"
    echo "  kubectl port-forward svc/sample-app-service 8080:80"
    echo "  URL: http://localhost:8080"
    echo "  Health: http://localhost:8080/health"
    echo "  Metrics: http://localhost:8080/metrics"
    echo ""
    echo -e "${YELLOW}📝 Load Testing:${NC}"
    echo "  ./load-test.sh (Linux/Mac)"
    echo "  ./load-test.ps1 (Windows PowerShell)"
    echo ""
    echo -e "${YELLOW}🔍 Useful Commands:${NC}"
    echo "  kubectl logs -l app=$APP_NAME"
    echo "  kubectl get pods -n $NAMESPACE"
    echo "  kubectl get svc -n $NAMESPACE"
    echo ""
}

# Function to run quick test
run_quick_test() {
    echo -e "${YELLOW}🧪 Running quick test...${NC}"
    
    # Port forward the application
    kubectl port-forward svc/sample-app-service 8080:80 &
    PF_PID=$!
    
    # Wait for port forward to be ready
    sleep 5
    
    # Test the application
    if curl -s http://localhost:8080/health > /dev/null; then
        echo -e "${GREEN}✅ Application is responding${NC}"
        
        # Test metrics endpoint
        if curl -s http://localhost:8080/metrics | grep -q "app_request_total"; then
            echo -e "${GREEN}✅ Metrics endpoint is working${NC}"
        else
            echo -e "${YELLOW}⚠️  Metrics endpoint may not be working properly${NC}"
        fi
        
        # Generate some test traffic
        echo -e "${YELLOW}Generating test traffic...${NC}"
        for i in {1..10}; do
            curl -s http://localhost:8080/ > /dev/null
            curl -s http://localhost:8080/api/data > /dev/null
            sleep 0.1
        done
        echo -e "${GREEN}✅ Test traffic generated${NC}"
        
    else
        echo -e "${RED}❌ Application is not responding${NC}"
    fi
    
    # Kill port forward
    kill $PF_PID 2>/dev/null || true
}

# Main execution
main() {
    check_prerequisites
    build_application
    install_monitoring
    deploy_application
    verify_setup
    show_access_info
    
    echo -e "${GREEN}🎉 Setup completed successfully!${NC}"
    echo ""
    
    # Ask if user wants to run a quick test
    read -p "Do you want to run a quick test? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        run_quick_test
    fi
    
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo "1. Access Grafana and explore the dashboards"
    echo "2. Run load tests to generate traffic"
    echo "3. Check Prometheus targets and metrics"
    echo "4. Explore logs in Grafana with Loki"
    echo ""
    echo -e "${GREEN}Happy monitoring! 🚀${NC}"
}

# Run main function
main "$@"
