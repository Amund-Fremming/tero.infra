#!/bin/bash

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Function to print status messages
print_status() {
    echo -e "${YELLOW}[RUN]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}  Tero Infrastructure Runner${NC}"
echo -e "${GREEN}======================================${NC}"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check if service repos exist
if [ ! -d "../tero.session" ]; then
    print_error "tero.session directory not found at ../tero.session"
    exit 1
fi

if [ ! -d "../tero.platform" ]; then
    print_error "tero.platform directory not found at ../tero.platform"
    exit 1
fi

# Check if tero.platform has .env file
if [ ! -f "../tero.platform/.env" ]; then
    print_error "tero.platform/.env not found!"
    print_info "Please copy ../tero.platform/.env.example to ../tero.platform/.env and configure it."
    exit 1
fi

# Start all services
print_status "Starting all services (building if needed)..."
docker-compose up -d --build

# Wait for services to be healthy
print_status "Waiting for services to start..."
sleep 5

# Check service health
echo ""
print_info "Checking service health..."

# Function to check if a service is healthy
check_service() {
    local service=$1
    local max_attempts=30
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        local status=$(docker inspect --format='{{.State.Health.Status}}' "$service" 2>/dev/null || echo "starting")
        
        if [ "$status" = "healthy" ]; then
            print_success "$service is healthy"
            return 0
        elif [ "$status" = "unhealthy" ]; then
            print_error "$service is unhealthy"
            return 1
        fi
        
        attempt=$((attempt + 1))
        sleep 2
    done
    
    print_error "$service health check timeout"
    return 1
}

# Check Platform
check_service "tero-platform"

# Check Session
check_service "tero-session"

echo ""
print_success "All core services are running!"
echo ""

# Display service information
echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}  Service URLs${NC}"
echo -e "${GREEN}======================================${NC}"
echo -e "${BLUE}Platform API:${NC}     http://localhost:3000"
echo -e "${BLUE}Session Service:${NC}  http://localhost:8080"
echo -e "${BLUE}PostgreSQL:${NC}       localhost:5432"
echo ""

# Display WireGuard info if running
if docker ps | grep -q tero-wireguard; then
    echo -e "${GREEN}======================================${NC}"
    echo -e "${GREEN}  WireGuard VPN${NC}"
    echo -e "${GREEN}======================================${NC}"
    echo -e "${BLUE}Port:${NC}             51820/udp"
    echo -e "${BLUE}Config Location:${NC}  Run 'docker exec tero-wireguard cat /config/peer1/peer1.conf' to get config"
    echo -e "${BLUE}QR Code:${NC}          Run 'docker exec tero-wireguard cat /config/peer1/peer1.png' | base64"
    echo ""
fi

# Display Cloudflare Tunnel info if running
if docker ps | grep -q tero-cloudflared; then
    echo -e "${GREEN}======================================${NC}"
    echo -e "${GREEN}  Cloudflare Tunnel${NC}"
    echo -e "${GREEN}======================================${NC}"
    echo -e "${BLUE}Status:${NC}           Running"
    echo -e "${BLUE}Configure at:${NC}     https://one.dash.cloudflare.com/"
    echo ""
fi

# Show logs command
echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}  Useful Commands${NC}"
echo -e "${GREEN}======================================${NC}"
echo -e "${BLUE}View all logs:${NC}        docker-compose logs -f"
echo -e "${BLUE}View platform logs:${NC}   docker-compose logs -f tero-platform"
echo -e "${BLUE}View session logs:${NC}    docker-compose logs -f tero-session"
echo -e "${BLUE}Stop all services:${NC}   docker-compose down"
echo -e "${BLUE}Restart services:${NC}    docker-compose restart"
echo ""

print_success "Infrastructure is ready!"
