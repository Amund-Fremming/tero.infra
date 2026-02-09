#!/bin/bash

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}  Tero Infrastructure Build Script${NC}"
echo -e "${GREEN}======================================${NC}"
echo ""

# Function to print status messages
print_status() {
    echo -e "${YELLOW}[BUILD]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check if service directories exist
if [ ! -d "${SCRIPT_DIR}/../tero.session" ]; then
    print_error "tero.session directory not found at ${SCRIPT_DIR}/../tero.session"
    exit 1
fi

if [ ! -d "${SCRIPT_DIR}/../tero.platform" ]; then
    print_error "tero.platform directory not found at ${SCRIPT_DIR}/../tero.platform"
    exit 1
fi

# Build using docker-compose
print_status "Building all services with docker-compose..."
cd "$SCRIPT_DIR"

if docker-compose build; then
    print_success "All images built successfully!"
else
    print_error "Build failed"
    exit 1
fi

echo ""
print_success "All images built successfully!"
echo ""
echo -e "${GREEN}Docker images created:${NC}"
echo "  - tero-session:latest"
echo "  - tero-platform:latest"
echo ""
