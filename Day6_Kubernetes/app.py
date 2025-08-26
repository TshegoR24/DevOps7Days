from flask import Flask, jsonify, request
import os

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({
        'message': 'Welcome to DevOps 7 Days - Day 6 Kubernetes App!',
        'status': 'running',
        'version': '1.0.0'
    })

@app.route('/health')
def health():
    return jsonify({
        'status': 'healthy',
        'service': 'sample-app'
    })

@app.route('/add', methods=['POST'])
def add():
    data = request.get_json()
    if not data or 'x' not in data or 'y' not in data:
        return jsonify({'error': 'Please provide x and y values'}), 400
    
    x = data['x']
    y = data['y']
    result = x + y
    
    return jsonify({
        'x': x,
        'y': y,
        'result': result,
        'operation': 'addition'
    })

@app.route('/info')
def info():
    return jsonify({
        'pod_name': os.environ.get('HOSTNAME', 'unknown'),
        'node_name': os.environ.get('NODE_NAME', 'unknown'),
        'namespace': os.environ.get('NAMESPACE', 'default')
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
