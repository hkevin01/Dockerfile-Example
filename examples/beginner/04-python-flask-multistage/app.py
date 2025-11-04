"""
Simple Flask Web Application
Demonstrates a basic web server with multiple endpoints
"""

from flask import Flask, jsonify, render_template_string
import os
import sys

app = Flask(__name__)

# HTML template for the home page
HOME_TEMPLATE = """
<!DOCTYPE html>
<html>
<head>
    <title>Flask Multi-Stage Build Demo</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            background-color: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 { color: #2c3e50; }
        .endpoint {
            background-color: #ecf0f1;
            padding: 15px;
            margin: 10px 0;
            border-radius: 5px;
            border-left: 4px solid #3498db;
        }
        .endpoint code {
            background-color: #2c3e50;
            color: #ecf0f1;
            padding: 2px 6px;
            border-radius: 3px;
        }
        .badge {
            display: inline-block;
            padding: 5px 10px;
            background-color: #27ae60;
            color: white;
            border-radius: 3px;
            font-size: 12px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Flask Multi-Stage Build Demo</h1>
        <p><span class="badge">Running in Docker</span></p>
        <p>This application demonstrates a Python Flask web server built using Docker multi-stage builds.</p>
        
        <h2>Available Endpoints:</h2>
        
        <div class="endpoint">
            <strong>GET <code>/</code></strong><br>
            Home page (this page)
        </div>
        
        <div class="endpoint">
            <strong>GET <code>/api/health</code></strong><br>
            Health check endpoint - Returns application status
        </div>
        
        <div class="endpoint">
            <strong>GET <code>/api/info</code></strong><br>
            System information - Returns Python version and environment details
        </div>
        
        <div class="endpoint">
            <strong>GET <code>/api/hello</code></strong><br>
            Simple greeting endpoint - Returns a JSON greeting
        </div>
        
        <div class="endpoint">
            <strong>GET <code>/api/hello/&lt;name&gt;</code></strong><br>
            Personalized greeting - Returns a greeting with your name
        </div>
        
        <h2>Benefits of Multi-Stage Builds:</h2>
        <ul>
            <li>✅ Smaller final image size (excludes build dependencies)</li>
            <li>✅ More secure (minimal attack surface)</li>
            <li>✅ Faster deployment (smaller images transfer faster)</li>
            <li>✅ Cleaner production environment</li>
        </ul>
    </div>
</body>
</html>
"""


@app.route('/')
def home():
    """Home page with endpoint documentation"""
    return render_template_string(HOME_TEMPLATE)


@app.route('/api/health')
def health():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'message': 'Application is running correctly',
        'service': 'flask-multistage-demo'
    }), 200


@app.route('/api/info')
def info():
    """System information endpoint"""
    return jsonify({
        'python_version': sys.version,
        'flask_version': Flask.__version__,
        'environment': os.environ.get('FLASK_ENV', 'production'),
        'container': 'docker-multistage'
    }), 200


@app.route('/api/hello')
def hello():
    """Simple greeting endpoint"""
    return jsonify({
        'message': 'Hello from Flask!',
        'description': 'This is a multi-stage Docker build example'
    }), 200


@app.route('/api/hello/<name>')
def hello_name(name):
    """Personalized greeting endpoint"""
    return jsonify({
        'message': f'Hello, {name}!',
        'personalized': True,
        'from': 'Flask Multi-Stage Build'
    }), 200


@app.errorhandler(404)
def not_found(error):
    """404 error handler"""
    return jsonify({
        'error': 'Not found',
        'message': 'The requested endpoint does not exist',
        'status': 404
    }), 404


@app.errorhandler(500)
def internal_error(error):
    """500 error handler"""
    return jsonify({
        'error': 'Internal server error',
        'message': 'An unexpected error occurred',
        'status': 500
    }), 500


if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    debug = os.environ.get('FLASK_DEBUG', 'False').lower() == 'true'
    
    print(f"🚀 Starting Flask application on port {port}...")
    print(f"📝 Debug mode: {debug}")
    print(f"🐍 Python version: {sys.version}")
    print(f"🌶️  Flask version: {Flask.__version__}")
    
    app.run(
        host='0.0.0.0',
        port=port,
        debug=debug
    )
