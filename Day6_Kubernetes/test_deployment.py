#!/usr/bin/env python3
"""
Simple test script to verify Kubernetes deployment
"""

import requests
import time
import sys

def test_endpoint(url, expected_status=200):
    """Test a single endpoint"""
    try:
        response = requests.get(url, timeout=10)
        if response.status_code == expected_status:
            print(f"✅ {url} - Status: {response.status_code}")
            return True
        else:
            print(f"❌ {url} - Expected: {expected_status}, Got: {response.status_code}")
            return False
    except requests.exceptions.RequestException as e:
        print(f"❌ {url} - Error: {e}")
        return False

def test_post_endpoint(url, data, expected_status=200):
    """Test a POST endpoint"""
    try:
        response = requests.post(url, json=data, timeout=10)
        if response.status_code == expected_status:
            print(f"✅ {url} - Status: {response.status_code}")
            return True
        else:
            print(f"❌ {url} - Expected: {expected_status}, Got: {response.status_code}")
            return False
    except requests.exceptions.RequestException as e:
        print(f"❌ {url} - Error: {e}")
        return False

def main():
    # Configuration
    base_url = "http://localhost:30007"
    
    print("🧪 Testing Kubernetes Deployment...")
    print("=" * 40)
    
    # Wait a bit for service to be ready
    print("⏳ Waiting for service to be ready...")
    time.sleep(5)
    
    # Test endpoints
    tests = [
        ("Health Check", f"{base_url}/health"),
        ("Home Page", f"{base_url}/"),
        ("Pod Info", f"{base_url}/info"),
    ]
    
    passed = 0
    total = len(tests) + 2  # +2 for POST tests
    
    for name, url in tests:
        if test_endpoint(url):
            passed += 1
    
    # Test POST endpoint
    if test_post_endpoint(f"{base_url}/add", {"x": 10, "y": 5}):
        passed += 1
    
    # Test invalid POST
    if test_post_endpoint(f"{base_url}/add", {"x": 10}, 400):
        passed += 1
    
    print("=" * 40)
    print(f"📊 Test Results: {passed}/{total} tests passed")
    
    if passed == total:
        print("🎉 All tests passed! Deployment is working correctly.")
        return 0
    else:
        print("⚠️  Some tests failed. Check your deployment.")
        return 1

if __name__ == "__main__":
    sys.exit(main())
