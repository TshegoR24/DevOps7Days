#!/usr/bin/env python3
"""
Sample Application with Monitoring & Logging
- Prometheus metrics endpoint
- Structured logging
- Health checks
- Load generation endpoints
"""

import time
import random
import logging
import json
from datetime import datetime
from flask import Flask, jsonify, request
from prometheus_client import generate_latest, Counter, Histogram, Gauge
from prometheus_client import CONTENT_TYPE_LATEST

# Configure structured logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

app = Flask(__name__)

# Prometheus metrics
REQUEST_COUNT = Counter(
    'app_request_total',
    'Total number of requests',
    ['method', 'endpoint', 'status']
)

REQUEST_LATENCY = Histogram(
    'app_request_latency_seconds',
    'Request latency in seconds',
    ['method', 'endpoint']
)

ACTIVE_REQUESTS = Gauge(
    'app_active_requests',
    'Number of active requests'
)

ERROR_COUNT = Counter(
    'app_error_total',
    'Total number of errors',
    ['error_type']
)

# Application state
app_start_time = datetime.now()
request_counter = 0

@app.before_request
def before_request():
    """Log request details and start timing"""
    global request_counter
    request_counter += 1
    
    # Log request
    logger.info("Request received", extra={
        'method': request.method,
        'endpoint': request.endpoint,
        'ip': request.remote_addr,
        'user_agent': request.headers.get('User-Agent', 'Unknown'),
        'request_id': request_counter
    })
    
    # Start timing
    request.start_time = time.time()
    ACTIVE_REQUESTS.inc()

@app.after_request
def after_request(response):
    """Log response and record metrics"""
    # Calculate latency
    latency = time.time() - request.start_time
    
    # Log response
    logger.info("Request completed", extra={
        'method': request.method,
        'endpoint': request.endpoint,
        'status_code': response.status_code,
        'latency': round(latency, 3),
        'request_id': request_counter
    })
    
    # Record Prometheus metrics
    REQUEST_COUNT.labels(
        method=request.method,
        endpoint=request.endpoint,
        status=response.status_code
    ).inc()
    
    REQUEST_LATENCY.labels(
        method=request.method,
        endpoint=request.endpoint
    ).observe(latency)
    
    ACTIVE_REQUESTS.dec()
    
    return response

@app.errorhandler(Exception)
def handle_exception(e):
    """Handle exceptions and log them"""
    logger.error("Application error", extra={
        'error_type': type(e).__name__,
        'error_message': str(e),
        'request_id': request_counter
    })
    
    ERROR_COUNT.labels(error_type=type(e).__name__).inc()
    
    return jsonify({
        'error': 'Internal server error',
        'message': str(e)
    }), 500

@app.route('/')
def home():
    """Home endpoint"""
    logger.info("Home endpoint accessed")
    return jsonify({
        'message': 'Welcome to the Sample Application',
        'version': '1.0.0',
        'timestamp': datetime.now().isoformat(),
        'uptime': str(datetime.now() - app_start_time)
    })

@app.route('/health')
def health():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        'uptime': str(datetime.now() - app_start_time),
        'requests_processed': request_counter
    })

@app.route('/metrics')
def metrics():
    """Prometheus metrics endpoint"""
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}

@app.route('/api/data')
def get_data():
    """API endpoint that returns sample data"""
    # Simulate some processing time
    time.sleep(random.uniform(0.1, 0.5))
    
    data = {
        'id': random.randint(1, 1000),
        'name': f'Item {random.randint(1, 100)}',
        'value': random.uniform(0, 100),
        'timestamp': datetime.now().isoformat()
    }
    
    logger.info("Data generated", extra={
        'data_id': data['id'],
        'data_value': data['value']
    })
    
    return jsonify(data)

@app.route('/api/error')
def generate_error():
    """Endpoint to generate errors for testing"""
    error_types = ['ValueError', 'RuntimeError', 'ConnectionError']
    error_type = random.choice(error_types)
    
    logger.warning("Error endpoint accessed", extra={
        'error_type': error_type
    })
    
    if error_type == 'ValueError':
        raise ValueError("Simulated value error")
    elif error_type == 'RuntimeError':
        raise RuntimeError("Simulated runtime error")
    else:
        raise ConnectionError("Simulated connection error")

@app.route('/api/slow')
def slow_endpoint():
    """Slow endpoint for testing latency"""
    # Simulate slow processing
    sleep_time = random.uniform(1, 3)
    time.sleep(sleep_time)
    
    logger.info("Slow endpoint completed", extra={
        'sleep_time': sleep_time
    })
    
    return jsonify({
        'message': 'Slow operation completed',
        'duration': sleep_time,
        'timestamp': datetime.now().isoformat()
    })

@app.route('/api/load')
def generate_load():
    """Generate load for testing"""
    iterations = request.args.get('iterations', 100, type=int)
    
    logger.info("Load generation started", extra={
        'iterations': iterations
    })
    
    results = []
    for i in range(iterations):
        # Simulate work
        time.sleep(0.01)
        results.append({
            'iteration': i,
            'value': random.uniform(0, 1),
            'timestamp': datetime.now().isoformat()
        })
    
    logger.info("Load generation completed", extra={
        'iterations': iterations,
        'results_count': len(results)
    })
    
    return jsonify({
        'message': 'Load generation completed',
        'iterations': iterations,
        'results': results[:10]  # Return first 10 results
    })

@app.route('/api/status')
def status():
    """Detailed status endpoint"""
    import psutil
    
    # Get system information
    cpu_percent = psutil.cpu_percent(interval=1)
    memory = psutil.virtual_memory()
    
    status_data = {
        'application': {
            'status': 'running',
            'uptime': str(datetime.now() - app_start_time),
            'requests_processed': request_counter,
            'version': '1.0.0'
        },
        'system': {
            'cpu_percent': cpu_percent,
            'memory_percent': memory.percent,
            'memory_available': memory.available,
            'memory_total': memory.total
        },
        'timestamp': datetime.now().isoformat()
    }
    
    logger.info("Status check performed", extra={
        'cpu_percent': cpu_percent,
        'memory_percent': memory.percent
    })
    
    return jsonify(status_data)

if __name__ == '__main__':
    logger.info("Starting Sample Application with Monitoring")
    app.run(host='0.0.0.0', port=8080, debug=False)
