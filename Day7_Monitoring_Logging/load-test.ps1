# Load Testing Script for Sample Application (PowerShell)
# This script generates various types of traffic to test monitoring

param(
    [string]$AppUrl = "http://localhost:8080",
    [int]$Duration = 300,  # 5 minutes
    [int]$ConcurrentUsers = 10,
    [int]$Rate = 50  # requests per second
)

Write-Host "🚀 Starting Load Test for Sample Application" -ForegroundColor Green
Write-Host "Target: $AppUrl" -ForegroundColor Yellow
Write-Host "Duration: $Duration seconds" -ForegroundColor Yellow
Write-Host "Concurrent users: $ConcurrentUsers" -ForegroundColor Yellow
Write-Host "Rate: $Rate requests/second" -ForegroundColor Yellow
Write-Host ""

# Check if application is accessible
Write-Host "📡 Checking application health..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "$AppUrl/health" -UseBasicParsing -TimeoutSec 5
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Application is healthy" -ForegroundColor Green
    } else {
        Write-Host "❌ Application returned status: $($response.StatusCode)" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Application is not accessible at $AppUrl" -ForegroundColor Red
    Write-Host "Please ensure the application is running and port-forwarded" -ForegroundColor Yellow
    exit 1
}

# Function to generate random traffic
function Generate-Traffic {
    param(
        [string]$Endpoint,
        [int]$Weight
    )
    
    for ($i = 1; $i -le $Weight; $i++) {
        try {
            Invoke-WebRequest -Uri "$AppUrl$Endpoint" -UseBasicParsing -TimeoutSec 10 | Out-Null
        } catch {
            # Ignore errors for load testing
        }
    }
}

# Function to run load test
function Start-LoadTest {
    Write-Host "🔥 Starting load test..." -ForegroundColor Green
    Write-Host "Press Ctrl+C to stop early" -ForegroundColor Yellow
    
    $startTime = Get-Date
    $endTime = $startTime.AddSeconds($Duration)
    
    while ((Get-Date) -lt $endTime) {
        # Generate different types of traffic with different weights
        Generate-Traffic -Endpoint "/" -Weight 10           # Home page
        Generate-Traffic -Endpoint "/health" -Weight 5      # Health checks
        Generate-Traffic -Endpoint "/api/data" -Weight 15   # Data API
        Generate-Traffic -Endpoint "/api/slow" -Weight 3    # Slow endpoint
        Generate-Traffic -Endpoint "/api/error" -Weight 2   # Error endpoint (for testing)
        Generate-Traffic -Endpoint "/api/status" -Weight 8  # Status endpoint
        
        # Sleep to control rate
        Start-Sleep -Milliseconds 100
    }
    
    Write-Host "✅ Load test completed" -ForegroundColor Green
}

# Function to run stress test
function Start-StressTest {
    Write-Host "💪 Starting stress test..." -ForegroundColor Green
    
    # Generate high load for 30 seconds
    for ($i = 1; $i -le 30; $i++) {
        Write-Host "Stress test iteration $i/30" -ForegroundColor Yellow
        
        # Generate burst of requests
        for ($j = 1; $j -le 20; $j++) {
            try {
                Invoke-WebRequest -Uri "$AppUrl/api/load?iterations=50" -UseBasicParsing -TimeoutSec 30 | Out-Null
            } catch {
                # Ignore errors for stress testing
            }
        }
        
        Start-Sleep -Seconds 1
    }
    
    Write-Host "✅ Stress test completed" -ForegroundColor Green
}

# Function to run error test
function Start-ErrorTest {
    Write-Host "⚠️  Starting error test..." -ForegroundColor Yellow
    
    # Generate errors for 30 seconds
    for ($i = 1; $i -le 30; $i++) {
        Write-Host "Error test iteration $i/30" -ForegroundColor Yellow
        
        # Generate various errors
        try {
            Invoke-WebRequest -Uri "$AppUrl/api/error" -UseBasicParsing -TimeoutSec 5 | Out-Null
        } catch {
            # Expected errors
        }
        
        try {
            Invoke-WebRequest -Uri "$AppUrl/nonexistent" -UseBasicParsing -TimeoutSec 5 | Out-Null
        } catch {
            # Expected 404
        }
        
        try {
            Invoke-WebRequest -Uri "$AppUrl/api/data?invalid=param" -UseBasicParsing -TimeoutSec 5 | Out-Null
        } catch {
            # Expected errors
        }
        
        Start-Sleep -Seconds 1
    }
    
    Write-Host "✅ Error test completed" -ForegroundColor Green
}

# Function to run latency test
function Start-LatencyTest {
    Write-Host "⏱️  Starting latency test..." -ForegroundColor Green
    
    Write-Host "Testing endpoint latencies:" -ForegroundColor Yellow
    
    # Test different endpoints
    $endpoints = @("/", "/health", "/api/data", "/api/slow", "/api/status")
    
    foreach ($endpoint in $endpoints) {
        Write-Host "  $endpoint: " -NoNewline -ForegroundColor Cyan
        
        # Measure average latency over 10 requests
        $totalTime = 0
        for ($i = 1; $i -le 10; $i++) {
            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
            try {
                Invoke-WebRequest -Uri "$AppUrl$endpoint" -UseBasicParsing -TimeoutSec 10 | Out-Null
            } catch {
                # Ignore errors for latency testing
            }
            $stopwatch.Stop()
            $totalTime += $stopwatch.ElapsedMilliseconds
        }
        
        $avgTime = [math]::Round($totalTime / 10)
        Write-Host "${avgTime}ms" -ForegroundColor White
    }
    
    Write-Host "✅ Latency test completed" -ForegroundColor Green
}

# Main execution
Write-Host "🎯 Choose test type:" -ForegroundColor Magenta
Write-Host "1) Load Test (normal traffic)" -ForegroundColor White
Write-Host "2) Stress Test (high load)" -ForegroundColor White
Write-Host "3) Error Test (generate errors)" -ForegroundColor White
Write-Host "4) Latency Test (measure response times)" -ForegroundColor White
Write-Host "5) All Tests (run everything)" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Enter your choice (1-5)"

switch ($choice) {
    "1" {
        Start-LoadTest
    }
    "2" {
        Start-StressTest
    }
    "3" {
        Start-ErrorTest
    }
    "4" {
        Start-LatencyTest
    }
    "5" {
        Write-Host "🔄 Running all tests..." -ForegroundColor Green
        Start-LoadTest
        Start-Sleep -Seconds 10
        Start-StressTest
        Start-Sleep -Seconds 10
        Start-ErrorTest
        Start-Sleep -Seconds 10
        Start-LatencyTest
    }
    default {
        Write-Host "❌ Invalid choice" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "📊 Load test completed!" -ForegroundColor Green
Write-Host "Check your Grafana dashboard to see the metrics:" -ForegroundColor Yellow
Write-Host "  kubectl port-forward svc/monitoring-grafana 3000:80 -n monitoring" -ForegroundColor Cyan
Write-Host "  Then visit: http://localhost:3000" -ForegroundColor Cyan
Write-Host ""
Write-Host "Default credentials: admin / prom-operator" -ForegroundColor Yellow
