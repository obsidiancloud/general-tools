# Solana Development Environment Makefile
# Provides convenient commands for container management

.PHONY: help build start stop restart shell logs status clean update setup-env

# Default target
help: ## Show this help message
	@echo "Solana Blockchain Development Environment"
	@echo "========================================="
	@echo ""
	@echo "Available commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

build: ## Build the Docker container
	@echo "🔨 Building Solana development container..."
	docker build -t solana-dev:latest .
	@echo "✅ Container built successfully"

start: ## Start the development environment
	@echo "🚀 Starting Solana development environment..."
	@mkdir -p projects solana-projects serverless-projects terraform-projects
	docker-compose up -d solana-dev
	@echo "✅ Development environment started"
	@echo "💡 Access with: make shell"

stop: ## Stop the development environment
	@echo "🛑 Stopping development environment..."
	docker-compose down
	@echo "✅ Development environment stopped"

restart: stop start ## Restart the development environment

shell: ## Open a shell in the container
	@echo "🐚 Opening shell in development container..."
	docker-compose exec solana-dev bash

shell-user: ## Open a shell as the solana user
	@echo "🐚 Opening shell as solana user..."
	docker-compose exec --user solana solana-dev bash

logs: ## Show container logs
	docker-compose logs -f solana-dev

status: ## Show container status and resource usage
	@echo "📊 Container status:"
	docker-compose ps
	@echo ""
	@echo "📈 Resource usage:"
	@docker stats --no-stream solana-blockchain-dev 2>/dev/null || echo "Container not running"

clean: ## Remove container and image
	@echo "🧹 Cleaning up development environment..."
	@read -p "This will remove the container and image. Continue? (y/N): " confirm && \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		docker-compose down -v; \
		docker rmi solana-dev:latest 2>/dev/null || true; \
		echo "✅ Cleanup completed"; \
	else \
		echo "❌ Cleanup cancelled"; \
	fi

update: stop build start ## Rebuild and restart the container

setup-env: ## Set up environment configuration
	@echo "⚙️  Setting up environment configuration..."
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo "✅ Created .env file from template"; \
		echo "💡 Edit .env file to customize your configuration"; \
	else \
		echo "⚠️  .env file already exists"; \
	fi

# Development workflow commands
init-solana: ## Initialize a new Solana project
	@read -p "Enter project name: " name && \
	docker-compose exec solana-dev bash -c "cd /workspace/solana-projects && anchor init $$name"

init-serverless: ## Initialize a new Serverless project
	@read -p "Enter project name: " name && \
	docker-compose exec solana-dev bash -c "cd /workspace/serverless-projects && serverless create --template aws-nodejs-typescript --name $$name"

init-sst: ## Initialize a new SST project
	@read -p "Enter project name: " name && \
	docker-compose exec solana-dev bash -c "cd /workspace/serverless-projects && npx create-sst@latest $$name"

init-nextjs: ## Initialize a new Next.js project
	@read -p "Enter project name: " name && \
	docker-compose exec solana-dev bash -c "cd /workspace/serverless-projects && npx create-next-app@latest $$name --typescript --tailwind --eslint"

init-terraform: ## Initialize a new Terraform project
	@read -p "Enter project name: " name && \
	docker-compose exec solana-dev bash -c "mkdir -p /workspace/terraform-projects/$$name && cd /workspace/terraform-projects/$$name && terraform init"

# Service management
start-all: ## Start all services (main + optional services)
	@echo "🚀 Starting all services..."
	docker-compose up -d
	@echo "✅ All services started"

stop-all: ## Stop all services
	@echo "🛑 Stopping all services..."
	docker-compose down
	@echo "✅ All services stopped"

start-localstack: ## Start LocalStack for local AWS development
	docker-compose up -d localstack
	@echo "✅ LocalStack started on port 4566"

start-db: ## Start database services (PostgreSQL + Redis)
	docker-compose up -d postgres redis
	@echo "✅ Database services started"

# Utility commands
check-deps: ## Check if required dependencies are installed
	@echo "🔍 Checking dependencies..."
	@command -v docker >/dev/null 2>&1 || { echo "❌ Docker is not installed"; exit 1; }
	@command -v docker-compose >/dev/null 2>&1 || { echo "❌ Docker Compose is not installed"; exit 1; }
	@echo "✅ All dependencies are installed"

version: ## Show version information
	@echo "Solana Development Environment"
	@echo "=============================="
	@echo "Docker version:"
	@docker --version
	@echo ""
	@echo "Docker Compose version:"
	@docker-compose --version
	@echo ""
	@if docker images solana-dev:latest --format "table {{.Repository}}:{{.Tag}}\t{{.CreatedAt}}" | grep -q solana-dev; then \
		echo "Container image:"; \
		docker images solana-dev:latest --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"; \
	else \
		echo "Container image: Not built yet (run 'make build')"; \
	fi

# Development helpers
test-solana: ## Test Solana CLI installation
	docker-compose exec solana-dev solana --version

test-anchor: ## Test Anchor installation
	docker-compose exec solana-dev anchor --version

test-aws: ## Test AWS CLI installation
	docker-compose exec solana-dev aws --version

test-terraform: ## Test Terraform installation
	docker-compose exec solana-dev terraform --version

test-sst: ## Test SST installation
	docker-compose exec solana-dev sst --version

test-nextjs: ## Test Next.js installation
	docker-compose exec solana-dev next --version

test-git: ## Test Git installation
	docker-compose exec solana-dev git --version

test-all: test-solana test-anchor test-aws test-terraform test-sst test-nextjs test-git ## Test all tool installations
