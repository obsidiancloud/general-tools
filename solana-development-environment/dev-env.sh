#!/bin/bash

# Solana Blockchain Development Environment Manager
# Usage: ./dev-env.sh [command]

set -e

CONTAINER_NAME="solana-blockchain-dev"
IMAGE_NAME="solana-dev:latest"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        log_error "Docker is not running. Please start Docker first."
        exit 1
    fi
}

# Create project directories
setup_directories() {
    log_info "Creating project directories..."
    mkdir -p projects solana-projects serverless-projects terraform-projects
    log_success "Project directories created"
}

# Build the Docker image
build() {
    log_info "Building Solana development container..."
    docker build -t $IMAGE_NAME .
    log_success "Container built successfully"
}

# Start the development environment
start() {
    check_docker
    setup_directories
    
    log_info "Starting Solana development environment..."
    
    if docker-compose ps | grep -q $CONTAINER_NAME; then
        log_warning "Container is already running"
        return
    fi
    
    docker-compose up -d solana-dev
    log_success "Development environment started"
    log_info "Access the container with: ./dev-env.sh shell"
}

# Stop the development environment
stop() {
    log_info "Stopping development environment..."
    docker-compose down
    log_success "Development environment stopped"
}

# Restart the development environment
restart() {
    log_info "Restarting development environment..."
    stop
    start
}

# Open shell in the container
shell() {
    check_docker
    
    if ! docker-compose ps | grep -q $CONTAINER_NAME; then
        log_warning "Container is not running. Starting it first..."
        start
        sleep 3
    fi
    
    log_info "Opening shell in development container..."
    docker-compose exec solana-dev bash
}

# Show container logs
logs() {
    docker-compose logs -f solana-dev
}

# Show container status
status() {
    log_info "Container status:"
    docker-compose ps
    
    if docker-compose ps | grep -q $CONTAINER_NAME; then
        log_info "Container resource usage:"
        docker stats --no-stream $CONTAINER_NAME
    fi
}

# Clean up everything
clean() {
    log_warning "This will remove the container and image. Are you sure? (y/N)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        log_info "Cleaning up development environment..."
        docker-compose down -v
        docker rmi $IMAGE_NAME 2>/dev/null || true
        log_success "Cleanup completed"
    else
        log_info "Cleanup cancelled"
    fi
}

# Update container (rebuild and restart)
update() {
    log_info "Updating development environment..."
    stop
    build
    start
    log_success "Development environment updated"
}

# Show help
help() {
    echo "Solana Blockchain Development Environment Manager"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  build     Build the Docker container"
    echo "  start     Start the development environment"
    echo "  stop      Stop the development environment"
    echo "  restart   Restart the development environment"
    echo "  shell     Open a shell in the container"
    echo "  logs      Show container logs"
    echo "  status    Show container status and resource usage"
    echo "  update    Rebuild and restart the container"
    echo "  clean     Remove container and image"
    echo "  help      Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 start     # Start the development environment"
    echo "  $0 shell     # Open a shell for development"
    echo "  $0 logs      # Monitor container logs"
}

# Main script logic
case "${1:-help}" in
    build)
        build
        ;;
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        restart
        ;;
    shell)
        shell
        ;;
    logs)
        logs
        ;;
    status)
        status
        ;;
    update)
        update
        ;;
    clean)
        clean
        ;;
    help|--help|-h)
        help
        ;;
    *)
        log_error "Unknown command: $1"
        help
        exit 1
        ;;
esac
