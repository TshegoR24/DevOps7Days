#!/bin/bash

# Load Testing Script for Sample Application
# This script generates various types of traffic to test monitoring

set -e

# Configuration
APP_URL="http://localhost:8080"
DURATION=300  # 5 minutes
CONCURRENT_USERS=10
RATE=50  # requests per second

echo "🚀 Starting Load Test for Sample Application"
echo "Target: $APP_URL"
echo "Duration: $DURATION seconds"
echo "Concurrent users: $CONCURRENT_USERS"
echo "Rate: $RATE requests/second"
echo ""

# Check if application is accessible
echo "📡 Checking application health..."
if ! curl -s "$APP_URL/health" > /dev/null; then
    echo "❌ Application is not accessible at $APP_URL"
    echo "Please ensure the application is running and port-forwarded"
    exit 1
fi
echo "✅ Application is healthy"

# Function to generate random traffic
generate_traffic() {
    local endpoint=$1
    local weight=$2
    
    for ((i=1; i<=$weight; i++)); do
        curl -s "$APP_URL$endpoint" > /dev/null &
    done
}

# Function to run load test
run_load_test() {
    echo "🔥 Starting load test..."
    echo "Press Ctrl+C to stop early"
    
    local start_time=$(date +%s)
    local end_time=$((start_time + DURATION))
    
    while [ $(date +%s) -lt $end_time ]; do
        # Generate different types of traffic with different weights
        generate_traffic "/" 10           # Home page
        generate_traffic "/health" 5      # Health checks
        generate_traffic "/api/data" 15   # Data API
        generate_traffic "/api/slow" 3    # Slow endpoint
        generate_traffic "/api/error" 2   # Error endpoint (for testing)
        generate_traffic "/api/status" 8  # Status endpoint
        
        # Sleep to control rate
        sleep 0.1
    done
    
    echo "✅ Load test completed"
}

# Function to run stress test
run_stress_test() {
    echo "💪 Starting stress test..."
    
    # Generate high load for 30 seconds
    for i in {1..30}; do
        echo "Stress test iteration $i/30"
        
        # Generate burst of requests
        for j in {1..20}; do
            curl -s "$APP_URL/api/load?iterations=50" > /dev/null &
        done
        
        sleep 1
    done
    
    echo "✅ Stress test completed"
}

# Function to run error test
run_error_test() {
    echo "⚠️  Starting error test..."
    
    # Generate errors for 30 seconds
    for i in {1..30}; do
        echo "Error test iteration $i/30"
        
        # Generate various errors
        curl -s "$APP_URL/api/error" > /dev/null &
        curl -s "$APP_URL/nonexistent" > /dev/null &
        curl -s "$APP_URL/api/data?invalid=param" > /dev/null &
        
        sleep 1
    done
    
    echo "✅ Error test completed"
}

# Function to run latency test
run_latency_test() {
    echo "⏱️  Starting latency test..."
    
    echo "Testing endpoint latencies:"
    
    # Test different endpoints
    endpoints=("/" "/health" "/api/data" "/api/slow" "/api/status")
    
    for endpoint in "${endpoints[@]}"; do
        echo -n "  $endpoint: "
        
        # Measure average latency over 10 requests
        total_time=0
        for i in {1..10}; do
            start_time=$(date +%s%N)
            curl -s "$APP_URL$endpoint" > /dev/null
            end_time=$(date +%s%N)
            
            duration=$((end_time - start_time))
            total_time=$((total_time + duration))
        done
        
        avg_time=$((total_time / 10 / 1000000))  # Convert to milliseconds
        echo "${avg_time}ms"
    done
    
    echo "✅ Latency test completed"
}

# Main execution
echo "🎯 Choose test type:"
echo "1) Load Test (normal traffic)"
echo "2) Stress Test (high load)"
echo "3) Error Test (generate errors)"
echo "4) Latency Test (measure response times)"
echo "5) All Tests (run everything)"
echo ""

read -p "Enter your choice (1-5): " choice

case $choice in
    1)
        run_load_test
        ;;
    2)
        run_stress_test
        ;;
    3)
        run_error_test
        ;;
    4)
        run_latency_test
        ;;
    5)
        echo "🔄 Running all tests..."
        run_load_test
        sleep 10
        run_stress_test
        sleep 10
        run_error_test
        sleep 10
        run_latency_test
        ;;
    *)
        echo "❌ Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "📊 Load test completed!"
echo "Check your Grafana dashboard to see the metrics:"
echo "  kubectl port-forward svc/monitoring-grafana 3000:80 -n monitoring"
echo "  Then visit: http://localhost:3000"
echo ""
echo "Default credentials: admin / prom-operator"
