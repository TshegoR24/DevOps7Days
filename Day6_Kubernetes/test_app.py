import pytest
import requests
import time
import os

# Test configuration
BASE_URL = os.environ.get('TEST_BASE_URL', 'http://localhost:30007')
TIMEOUT = 30

def test_health_endpoint():
    """Test the health check endpoint"""
    response = requests.get(f"{BASE_URL}/health", timeout=TIMEOUT)
    assert response.status_code == 200
    data = response.json()
    assert data['status'] == 'healthy'
    assert data['service'] == 'sample-app'

def test_home_endpoint():
    """Test the home endpoint"""
    response = requests.get(f"{BASE_URL}/", timeout=TIMEOUT)
    assert response.status_code == 200
    data = response.json()
    assert 'message' in data
    assert 'status' in data
    assert 'version' in data

def test_add_endpoint():
    """Test the addition API endpoint"""
    payload = {'x': 5, 'y': 3}
    response = requests.post(f"{BASE_URL}/add", json=payload, timeout=TIMEOUT)
    assert response.status_code == 200
    data = response.json()
    assert data['x'] == 5
    assert data['y'] == 3
    assert data['result'] == 8
    assert data['operation'] == 'addition'

def test_add_endpoint_invalid_input():
    """Test the addition API with invalid input"""
    payload = {'x': 5}  # Missing 'y'
    response = requests.post(f"{BASE_URL}/add", json=payload, timeout=TIMEOUT)
    assert response.status_code == 400
    data = response.json()
    assert 'error' in data

def test_info_endpoint():
    """Test the pod information endpoint"""
    response = requests.get(f"{BASE_URL}/info", timeout=TIMEOUT)
    assert response.status_code == 200
    data = response.json()
    assert 'pod_name' in data
    assert 'node_name' in data
    assert 'namespace' in data

if __name__ == "__main__":
    # Wait for service to be ready
    print("Waiting for service to be ready...")
    time.sleep(10)
    
    # Run tests
    pytest.main([__file__, "-v"])
