#!/bin/bash
set -euo pipefail

# Configuration
STEAMCMD="${STEAMCMD_HOME}/steamcmd.sh"
SERVER_FILES="${STEAM_HOME}/serverfiles"
APP_ID="${STEAM_APP_ID:-232250}"
SERVER_NAME="${SERVER_NAME:-Steam Game Server}"
MAX_PLAYERS="${MAX_PLAYERS:-32}"
SERVER_PASSWORD="${SERVER_PASSWORD:-}"
CONFIG_PATH="${STEAM_HOME}/server"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Function to install/update game server
install_game_server() {
    log_info "Installing/updating game server with App ID: $APP_ID"
    
    # Run steamcmd to download the server
    $STEAMCMD \
        +force_install_dir "${SERVER_FILES}" \
        +login anonymous \
        +app_update "${APP_ID}" \
        +quit
    
    if [ $? -eq 0 ]; then
        log_info "Game server installation completed successfully"
    else
        log_error "Game server installation failed"
        exit 1
    fi
}

# Function to setup health check endpoint
setup_health_check() {
    log_info "Setting up health check server"
    
    # Create a simple Python HTTP server for health checks
    cat > "${STEAM_HOME}/health_check.py" << 'EOF'
#!/usr/bin/env python3
import http.server
import socketserver
import os
import json
import time

PORT = 8080
PIDFILE = '/tmp/server.pid'

class HealthCheckHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/health':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            response = {'status': 'healthy', 'timestamp': time.time()}
            self.wfile.write(json.dumps(response).encode())
        elif self.path == '/ready':
            # Check if server process is running
            if os.path.exists(PIDFILE):
                try:
                    with open(PIDFILE, 'r') as f:
                        pid = int(f.read().strip())
                    # Check if process exists
                    os.kill(pid, 0)
                    self.send_response(200)
                    self.send_header('Content-type', 'application/json')
                    self.end_headers()
                    response = {'status': 'ready', 'timestamp': time.time()}
                    self.wfile.write(json.dumps(response).encode())
                except (OSError, ValueError):
                    self.send_response(503)
                    self.send_header('Content-type', 'application/json')
                    self.end_headers()
                    response = {'status': 'not_ready', 'timestamp': time.time()}
                    self.wfile.write(json.dumps(response).encode())
            else:
                self.send_response(503)
                self.send_header('Content-type', 'application/json')
                self.end_headers()
                response = {'status': 'not_ready', 'timestamp': time.time()}
                self.wfile.write(json.dumps(response).encode())
        else:
            self.send_response(404)
            self.end_headers()

    def log_message(self, format, *args):
        # Suppress default logging
        pass

if __name__ == '__main__':
    with socketserver.TCPServer(("", PORT), HealthCheckHandler) as httpd:
        print(f"Health check server running on port {PORT}", flush=True)
        httpd.serve_forever()
EOF
    chmod +x "${STEAM_HOME}/health_check.py"
}

# Main execution
main() {
    log_info "Starting Steam Game Server entrypoint"
    log_info "App ID: $APP_ID"
    log_info "Server Name: $SERVER_NAME"
    log_info "Max Players: $MAX_PLAYERS"
    
    # Create necessary directories
    mkdir -p "${SERVER_FILES}"
    mkdir -p "${CONFIG_PATH}"
    
    # Install/update the game server
    install_game_server
    
    # Setup health check
    setup_health_check
    
    # Start health check server in background
    log_info "Starting health check server"
    python3 "${STEAM_HOME}/health_check.py" > /tmp/health_check.log 2>&1 &
    echo $! > /tmp/server.pid
    
    log_info "Steam server preparation complete"
    log_info "Server files available at: $SERVER_FILES"
    
    # Keep the container running and wait for signals
    sleep infinity
}

main "$@"
