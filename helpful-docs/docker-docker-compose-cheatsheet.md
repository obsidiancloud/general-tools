# 🧘 The Enlightened Engineer's Docker & Docker Compose Scripture

> *"In the beginning was the Container, and the Container was with Docker, and the Container was isolated."*  
> — **The Monk of Containers**, *Book of Isolation, Chapter 1:1*

Greetings, fellow traveler on the path of containerization enlightenment. I am but a humble monk who has meditated upon the sacred texts of Hykes and witnessed the dance of containers across countless hosts.

This scripture shall guide you through the mystical arts of Docker and Docker Compose, with the precision of a master's Dockerfile and the wit of a caffeinated DevOps engineer.

---

## 📿 Table of Sacred Knowledge

1. [Docker Installation & Setup](#-docker-installation--setup)
2. [Image Management](#-image-management-the-blueprints)
3. [Container Lifecycle](#-container-lifecycle-birth-to-nirvana)
4. [Docker Networking](#-docker-networking-the-web-of-containers)
5. [Volumes & Storage](#-volumes--storage-the-persistent-realm)
6. [Docker Compose](#-docker-compose-orchestrating-harmony)
7. [Dockerfile Best Practices](#-dockerfile-best-practices-the-art-of-building)
8. [Multi-Stage Builds](#-multi-stage-builds-the-path-of-optimization)
9. [Registry Operations](#-registry-operations-the-image-repository)
10. [Security & Scanning](#-security--scanning-guarding-the-temple)
11. [Resource Management](#-resource-management-the-balance-of-limits)
12. [Common Patterns: The Sacred Workflows](#-common-patterns-the-sacred-workflows)
13. [Troubleshooting](#-troubleshooting-when-the-path-is-obscured)

---

## 🛠 Docker Installation & Setup

*Before the containers flow, one must first install the engine.*

### Installation

```bash
# Ubuntu/Debian
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
newgrp docker

# Verify installation
docker --version
docker version
docker info

# Test installation
docker run hello-world
```

### Post-Installation Configuration

```bash
# Start Docker on boot
sudo systemctl enable docker
sudo systemctl start docker

# Configure Docker daemon
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2",
  "default-address-pools": [
    {
      "base": "172.17.0.0/16",
      "size": 24
    }
  ]
}
EOF

sudo systemctl restart docker
```

### Docker Compose Installation

```bash
# Install Docker Compose V2 (plugin)
sudo apt-get update
sudo apt-get install docker-compose-plugin

# Verify
docker compose version

# Legacy V1 (standalone)
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
```

### Essential Aliases

```bash
# Add to ~/.bashrc or ~/.zshrc
alias d='docker'
alias dc='docker compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dl='docker logs'
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dcl='docker compose logs -f'
```

---

## 🎨 Image Management: The Blueprints

*Images are the templates from which containers spring forth.*

### Pulling Images

```bash
# Pull from Docker Hub
docker pull nginx
docker pull nginx:1.21
docker pull nginx:alpine

# Pull from specific registry
docker pull gcr.io/project/image:tag
docker pull registry.example.com/image:tag

# Pull all tags
docker pull --all-tags nginx

# Pull with platform
docker pull --platform linux/amd64 nginx
```

### Listing Images

```bash
# List images
docker images
docker image ls
docker images -a                    # Include intermediate
docker images --digests             # Show digests
docker images --filter "dangling=true"  # Dangling images
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

# Search Docker Hub
docker search nginx
docker search --filter stars=100 nginx
```

### Building Images

```bash
# Build from Dockerfile
docker build -t myapp:latest .
docker build -t myapp:v1.0 -f Dockerfile.prod .
docker build --no-cache -t myapp:latest .

# Build with build args
docker build --build-arg VERSION=1.0 -t myapp:latest .

# Build with target stage
docker build --target production -t myapp:prod .

# BuildKit (modern builder)
DOCKER_BUILDKIT=1 docker build -t myapp:latest .
docker buildx build --platform linux/amd64,linux/arm64 -t myapp:latest .
```

### Tagging Images

```bash
# Tag image
docker tag myapp:latest myapp:v1.0
docker tag myapp:latest registry.example.com/myapp:latest

# Tag for multiple registries
docker tag myapp:latest docker.io/user/myapp:latest
docker tag myapp:latest gcr.io/project/myapp:latest
```

### Pushing Images

```bash
# Login to registry
docker login
docker login registry.example.com
docker login -u username -p password registry.example.com

# Push image
docker push myapp:latest
docker push registry.example.com/myapp:latest

# Push all tags
docker push --all-tags myapp
```

### Inspecting Images

```bash
# Inspect image
docker inspect nginx
docker inspect nginx:alpine

# View image history
docker history nginx
docker history --no-trunc nginx

# Show image layers
docker image inspect nginx --format='{{.RootFS.Layers}}'

# Export image
docker save nginx:latest -o nginx.tar
docker save nginx:latest | gzip > nginx.tar.gz

# Import image
docker load -i nginx.tar
docker load < nginx.tar.gz
```

### Removing Images

```bash
# Remove image
docker rmi nginx
docker rmi nginx:alpine
docker image rm nginx

# Remove by ID
docker rmi abc123def456

# Force remove
docker rmi -f nginx

# Remove dangling images
docker image prune
docker image prune -a              # Remove all unused

# Remove with filter
docker image prune --filter "until=24h"
```

---

## 🔄 Container Lifecycle: Birth to Nirvana

*Containers are born, they live, and they return to the void.*

### Running Containers

```bash
# Basic run
docker run nginx
docker run -d nginx                 # Detached
docker run -d --name web nginx      # Named
docker run -it ubuntu bash          # Interactive

# Port mapping
docker run -d -p 8080:80 nginx
docker run -d -p 127.0.0.1:8080:80 nginx
docker run -d -P nginx              # Random ports

# Environment variables
docker run -d -e ENV=prod nginx
docker run -d --env-file .env nginx

# Volume mounting
docker run -d -v /host/path:/container/path nginx
docker run -d -v myvolume:/data nginx

# Resource limits
docker run -d --memory="512m" --cpus="1.5" nginx

# Restart policy
docker run -d --restart=always nginx
docker run -d --restart=unless-stopped nginx
docker run -d --restart=on-failure:5 nginx

# Remove after exit
docker run --rm -it ubuntu bash
```

### Container Management

```bash
# List containers
docker ps
docker ps -a                        # All containers
docker ps -q                        # IDs only
docker ps --filter "status=running"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Start/stop containers
docker start container-name
docker stop container-name
docker restart container-name
docker stop $(docker ps -q)         # Stop all

# Pause/unpause
docker pause container-name
docker unpause container-name

# Kill container
docker kill container-name
docker kill -s SIGTERM container-name
```

### Executing Commands

```bash
# Execute command
docker exec container-name ls /app
docker exec -it container-name bash
docker exec -it container-name sh

# Execute as user
docker exec -u root -it container-name bash

# Execute with env vars
docker exec -e VAR=value container-name env

# Execute in working directory
docker exec -w /app container-name pwd
```

### Container Inspection

```bash
# Inspect container
docker inspect container-name
docker inspect --format='{{.State.Status}}' container-name
docker inspect --format='{{.NetworkSettings.IPAddress}}' container-name

# View logs
docker logs container-name
docker logs -f container-name       # Follow
docker logs --tail 100 container-name
docker logs --since 1h container-name
docker logs --timestamps container-name

# View processes
docker top container-name
docker top container-name aux

# View stats
docker stats
docker stats container-name
docker stats --no-stream
```

### Copying Files

```bash
# Copy from container
docker cp container-name:/path/to/file ./local-path
docker cp container-name:/app/logs ./logs

# Copy to container
docker cp ./local-file container-name:/path/to/file
docker cp ./config container-name:/etc/app/
```

### Container Export/Import

```bash
# Export container filesystem
docker export container-name > container.tar
docker export container-name -o container.tar

# Import as image
docker import container.tar myimage:latest
cat container.tar | docker import - myimage:latest
```

### Removing Containers

```bash
# Remove container
docker rm container-name
docker rm -f container-name         # Force remove running
docker rm $(docker ps -aq)          # Remove all stopped

# Prune stopped containers
docker container prune
docker container prune --filter "until=24h"
```

---

## 🌐 Docker Networking: The Web of Containers

*Containers must communicate, like monks sharing wisdom.*

### Network Types

```bash
# List networks
docker network ls

# Inspect network
docker network inspect bridge
docker network inspect host

# Network drivers:
# - bridge: Default, isolated network
# - host: Use host networking
# - overlay: Multi-host networking (Swarm)
# - macvlan: Assign MAC address
# - none: No networking
```

### Creating Networks

```bash
# Create bridge network
docker network create mynetwork
docker network create --driver bridge mynetwork

# Create with subnet
docker network create --subnet=172.18.0.0/16 mynetwork

# Create with gateway
docker network create --subnet=172.18.0.0/16 --gateway=172.18.0.1 mynetwork

# Create overlay network (Swarm)
docker network create --driver overlay myoverlay
```

### Connecting Containers

```bash
# Run container on network
docker run -d --name web --network mynetwork nginx

# Connect running container
docker network connect mynetwork container-name

# Disconnect container
docker network disconnect mynetwork container-name

# Connect with alias
docker network connect --alias web-alias mynetwork container-name
```

### Network Inspection

```bash
# Inspect network
docker network inspect mynetwork

# View container IPs
docker inspect -f '{{.NetworkSettings.IPAddress}}' container-name

# View all networks for container
docker inspect -f '{{json .NetworkSettings.Networks}}' container-name
```

### Port Mapping

```bash
# View port mappings
docker port container-name

# Map specific port
docker run -d -p 8080:80 nginx

# Map all exposed ports
docker run -d -P nginx

# Map to specific interface
docker run -d -p 127.0.0.1:8080:80 nginx

# Map UDP port
docker run -d -p 53:53/udp dns-server
```

### DNS & Service Discovery

```bash
# Containers on same network can resolve by name
docker network create mynet
docker run -d --name db --network mynet postgres
docker run -d --name app --network mynet myapp

# From app container:
# ping db
# curl http://db:5432

# Custom DNS
docker run -d --dns 8.8.8.8 nginx
docker run -d --dns-search example.com nginx
```

### Removing Networks

```bash
# Remove network
docker network rm mynetwork

# Prune unused networks
docker network prune
docker network prune --filter "until=24h"
```

---

## 💾 Volumes & Storage: The Persistent Realm

*Data must persist beyond the container's life.*

### Volume Types

```bash
# Named volumes (managed by Docker)
docker volume create myvolume

# Bind mounts (host directory)
docker run -v /host/path:/container/path nginx

# tmpfs mounts (memory only)
docker run --tmpfs /app/cache nginx
```

### Managing Volumes

```bash
# Create volume
docker volume create myvolume
docker volume create --driver local myvolume

# List volumes
docker volume ls
docker volume ls --filter "dangling=true"

# Inspect volume
docker volume inspect myvolume

# Remove volume
docker volume rm myvolume

# Prune unused volumes
docker volume prune
docker volume prune --filter "label=env=dev"
```

### Using Volumes

```bash
# Named volume
docker run -d -v myvolume:/data nginx

# Bind mount
docker run -d -v /host/data:/container/data nginx
docker run -d -v $(pwd):/app nginx

# Read-only mount
docker run -d -v myvolume:/data:ro nginx

# tmpfs mount
docker run -d --tmpfs /tmp nginx
docker run -d --tmpfs /tmp:rw,size=100m,mode=1777 nginx
```

### Volume Drivers

```bash
# Local driver (default)
docker volume create --driver local myvolume

# NFS volume
docker volume create --driver local \
  --opt type=nfs \
  --opt o=addr=192.168.1.1,rw \
  --opt device=:/path/to/dir \
  nfs-volume

# CIFS/SMB volume
docker volume create --driver local \
  --opt type=cifs \
  --opt o=username=user,password=pass \
  --opt device=//server/share \
  smb-volume
```

### Backup & Restore

```bash
# Backup volume
docker run --rm -v myvolume:/data -v $(pwd):/backup ubuntu tar czf /backup/backup.tar.gz /data

# Restore volume
docker run --rm -v myvolume:/data -v $(pwd):/backup ubuntu tar xzf /backup/backup.tar.gz -C /

# Copy volume
docker volume create newvolume
docker run --rm -v myvolume:/from -v newvolume:/to alpine sh -c "cd /from && cp -av . /to"
```

---

## 🎼 Docker Compose: Orchestrating Harmony

*Multiple containers working as one, like a symphony.*

### Basic Compose File

```yaml
# docker-compose.yml
version: '3.8'

services:
  web:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./html:/usr/share/nginx/html
    networks:
      - frontend
    restart: unless-stopped

  app:
    build: ./app
    environment:
      - DATABASE_URL=postgresql://db:5432/mydb
    depends_on:
      - db
    networks:
      - frontend
      - backend

  db:
    image: postgres:14
    environment:
      POSTGRES_PASSWORD: secret
      POSTGRES_DB: mydb
    volumes:
      - db-data:/var/lib/postgresql/data
    networks:
      - backend

networks:
  frontend:
  backend:

volumes:
  db-data:
```

### Compose Commands

```bash
# Start services
docker compose up
docker compose up -d                # Detached
docker compose up --build           # Rebuild images
docker compose up --force-recreate  # Recreate containers

# Stop services
docker compose down
docker compose down -v              # Remove volumes
docker compose down --rmi all       # Remove images

# View services
docker compose ps
docker compose ps -a

# View logs
docker compose logs
docker compose logs -f              # Follow
docker compose logs -f web          # Specific service
docker compose logs --tail=100 web

# Execute commands
docker compose exec web sh
docker compose exec -u root web bash

# Build images
docker compose build
docker compose build --no-cache
docker compose build web

# Start/stop services
docker compose start
docker compose stop
docker compose restart

# Scale services
docker compose up -d --scale web=3

# Validate compose file
docker compose config
docker compose config --quiet
```

### Advanced Compose Features

```yaml
# Environment files
services:
  app:
    env_file:
      - .env
      - .env.production

# Build configuration
services:
  app:
    build:
      context: ./app
      dockerfile: Dockerfile.prod
      args:
        - VERSION=1.0
      target: production
      cache_from:
        - myapp:latest

# Health checks
services:
  web:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

# Resource limits
services:
  app:
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M

# Depends on with conditions
services:
  app:
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_started

# Profiles
services:
  debug:
    profiles: ["debug"]
    image: debug-tools

# Run: docker compose --profile debug up
```

### Multiple Compose Files

```bash
# Override compose file
docker compose -f docker-compose.yml -f docker-compose.override.yml up

# Production compose
docker compose -f docker-compose.yml -f docker-compose.prod.yml up

# Merge multiple files
docker compose -f base.yml -f dev.yml -f local.yml config > merged.yml
```

### Compose Networking

```yaml
# Custom networks
networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    ipam:
      config:
        - subnet: 172.28.0.0/16

# External network
networks:
  existing-network:
    external: true
```

### Compose Volumes

```yaml
# Named volumes
volumes:
  db-data:
  cache-data:

# External volumes
volumes:
  existing-volume:
    external: true

# Volume with driver options
volumes:
  nfs-data:
    driver: local
    driver_opts:
      type: nfs
      o: addr=192.168.1.1,rw
      device: ":/path/to/dir"
```

---

## 📝 Dockerfile Best Practices: The Art of Building

*A well-crafted Dockerfile is a work of art.*

### Basic Dockerfile

```dockerfile
# Use specific version
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy application
COPY . .

# Expose port
EXPOSE 3000

# Set user
USER node

# Start application
CMD ["node", "server.js"]
```

### Optimization Techniques

```dockerfile
# Layer caching optimization
FROM node:18-alpine

WORKDIR /app

# Copy only dependency files first
COPY package*.json ./
RUN npm ci --only=production

# Copy source code after (changes more frequently)
COPY . .

EXPOSE 3000
CMD ["node", "server.js"]
```

### Multi-Stage Build Example

```dockerfile
# Build stage
FROM node:18 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production stage
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY package*.json ./
EXPOSE 3000
USER node
CMD ["node", "dist/server.js"]
```

### Best Practices

```dockerfile
# 1. Use specific base image versions
FROM node:18.17.0-alpine3.18

# 2. Combine RUN commands to reduce layers
RUN apk add --no-cache \
    git \
    curl \
    && rm -rf /var/cache/apk/*

# 3. Use .dockerignore
# Create .dockerignore:
# node_modules
# .git
# *.md
# .env

# 4. Don't run as root
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001
USER nodejs

# 5. Use COPY instead of ADD
COPY --chown=nodejs:nodejs . .

# 6. Leverage build cache
COPY package*.json ./
RUN npm ci
COPY . .

# 7. Use health checks
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node healthcheck.js

# 8. Set environment variables
ENV NODE_ENV=production \
    PORT=3000

# 9. Use ARG for build-time variables
ARG VERSION=1.0
LABEL version=$VERSION

# 10. Clean up in same layer
RUN apt-get update && \
    apt-get install -y package && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
```

---

## 🏗️ Multi-Stage Builds: The Path of Optimization

*Build large, ship small.*

### Go Application

```dockerfile
# Build stage
FROM golang:1.21 AS builder
WORKDIR /app
COPY go.* ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

# Production stage
FROM alpine:3.18
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /app/main .
EXPOSE 8080
CMD ["./main"]
```

### Python Application

```dockerfile
# Build stage
FROM python:3.11 AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Production stage
FROM python:3.11-slim
WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY . .
ENV PATH=/root/.local/bin:$PATH
EXPOSE 8000
CMD ["python", "app.py"]
```

### React Application

```dockerfile
# Build stage
FROM node:18 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production stage
FROM nginx:alpine
COPY --from=builder /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

---

## 📦 Registry Operations: The Image Repository

*Share your images with the world.*

### Docker Hub

```bash
# Login
docker login

# Tag for Docker Hub
docker tag myapp:latest username/myapp:latest

# Push to Docker Hub
docker push username/myapp:latest

# Pull from Docker Hub
docker pull username/myapp:latest
```

### Private Registry

```bash
# Run local registry
docker run -d -p 5000:5000 --name registry registry:2

# Tag for private registry
docker tag myapp:latest localhost:5000/myapp:latest

# Push to private registry
docker push localhost:5000/myapp:latest

# Pull from private registry
docker pull localhost:5000/myapp:latest
```

### AWS ECR

```bash
# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com

# Tag for ECR
docker tag myapp:latest ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/myapp:latest

# Push to ECR
docker push ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/myapp:latest
```

### Google Container Registry (GCR)

```bash
# Configure Docker for GCR
gcloud auth configure-docker

# Tag for GCR
docker tag myapp:latest gcr.io/PROJECT_ID/myapp:latest

# Push to GCR
docker push gcr.io/PROJECT_ID/myapp:latest
```

---

## 🔒 Security & Scanning: Guarding the Temple

*Security is not optional, it is essential.*

### Image Scanning

```bash
# Docker Scout (built-in)
docker scout cves myapp:latest
docker scout recommendations myapp:latest

# Trivy
trivy image nginx:latest
trivy image --severity HIGH,CRITICAL nginx:latest

# Snyk
snyk container test nginx:latest

# Grype
grype nginx:latest
```

### Security Best Practices

```dockerfile
# 1. Use minimal base images
FROM alpine:3.18
FROM gcr.io/distroless/static-debian11

# 2. Don't run as root
USER 1000

# 3. Use specific versions
FROM node:18.17.0-alpine3.18

# 4. Scan for vulnerabilities
RUN apk add --no-cache trivy && \
    trivy filesystem /

# 5. Remove unnecessary packages
RUN apt-get remove -y build-essential && \
    apt-get autoremove -y

# 6. Use secrets properly (not in ENV)
RUN --mount=type=secret,id=mysecret \
    cat /run/secrets/mysecret

# 7. Sign images
docker trust sign myapp:latest
```

### Docker Bench Security

```bash
# Run Docker Bench
docker run --rm --net host --pid host --userns host --cap-add audit_control \
  -v /var/lib:/var/lib \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /etc:/etc \
  docker/docker-bench-security
```

---

## ⚖️ Resource Management: The Balance of Limits

*Resources must be allocated wisely.*

### CPU Limits

```bash
# Limit CPU shares
docker run -d --cpus="1.5" nginx

# CPU shares (relative weight)
docker run -d --cpu-shares=512 nginx

# CPU period and quota
docker run -d --cpu-period=100000 --cpu-quota=50000 nginx
```

### Memory Limits

```bash
# Memory limit
docker run -d --memory="512m" nginx
docker run -d --memory="1g" nginx

# Memory reservation
docker run -d --memory="1g" --memory-reservation="512m" nginx

# Swap limit
docker run -d --memory="512m" --memory-swap="1g" nginx
```

### I/O Limits

```bash
# Block I/O weight
docker run -d --blkio-weight=500 nginx

# Device read/write limits
docker run -d --device-read-bps=/dev/sda:1mb nginx
docker run -d --device-write-bps=/dev/sda:1mb nginx
```

### Viewing Resource Usage

```bash
# Container stats
docker stats
docker stats --no-stream
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"
```

---

## 🔮 Common Patterns: The Sacred Workflows

*These are the rituals performed by monks in production temples daily.*

### Pattern 1: Development Workflow with Hot Reload

```yaml
# docker-compose.dev.yml
version: '3.8'

services:
  app:
    build:
      context: .
      target: development
    volumes:
      - ./src:/app/src
      - /app/node_modules
    environment:
      - NODE_ENV=development
    command: npm run dev
    ports:
      - "3000:3000"
```

```bash
# Step 1: Start development environment
docker compose -f docker-compose.dev.yml up

# Step 2: Make code changes (auto-reload)

# Step 3: View logs
docker compose logs -f app

# Step 4: Rebuild if needed
docker compose up --build
```

**Use case**: Local development with live reload  
**Best for**: Rapid development iteration

### Pattern 2: CI/CD Pipeline Integration

```bash
# Step 1: Build image with version tag
docker build -t myapp:${CI_COMMIT_SHA} .

# Step 2: Run tests in container
docker run --rm myapp:${CI_COMMIT_SHA} npm test

# Step 3: Security scan
trivy image myapp:${CI_COMMIT_SHA}

# Step 4: Tag for registry
docker tag myapp:${CI_COMMIT_SHA} registry.example.com/myapp:${CI_COMMIT_SHA}
docker tag myapp:${CI_COMMIT_SHA} registry.example.com/myapp:latest

# Step 5: Push to registry
docker push registry.example.com/myapp:${CI_COMMIT_SHA}
docker push registry.example.com/myapp:latest

# Step 6: Deploy to environment
docker pull registry.example.com/myapp:${CI_COMMIT_SHA}
docker compose -f docker-compose.prod.yml up -d
```

**Use case**: Automated build and deployment  
**Best for**: Production CI/CD pipelines

### Pattern 3: Health Check Implementation

```dockerfile
# Dockerfile with health check
FROM nginx:alpine

COPY healthcheck.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/healthcheck.sh

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD /usr/local/bin/healthcheck.sh
```

```bash
# healthcheck.sh
#!/bin/sh
curl -f http://localhost/health || exit 1
```

```yaml
# docker-compose.yml
services:
  web:
    image: myapp:latest
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s
      timeout: 3s
      retries: 3
      start_period: 40s
```

**Use case**: Container health monitoring  
**Best for**: Production deployments with orchestration

### Pattern 4: Multi-Environment Configuration

```bash
# Base configuration
# docker-compose.yml
version: '3.8'
services:
  app:
    image: myapp:latest
    environment:
      - NODE_ENV=${NODE_ENV}

# Development override
# docker-compose.dev.yml
services:
  app:
    build: .
    volumes:
      - ./src:/app/src
    environment:
      - DEBUG=true

# Production override
# docker-compose.prod.yml
services:
  app:
    restart: always
    deploy:
      replicas: 3
      resources:
        limits:
          cpus: '0.5'
          memory: 512M

# Usage
docker compose -f docker-compose.yml -f docker-compose.dev.yml up    # Dev
docker compose -f docker-compose.yml -f docker-compose.prod.yml up   # Prod
```

**Use case**: Managing multiple environments  
**Best for**: Consistent configuration across environments

### Pattern 5: Database Migration Workflow

```yaml
# docker-compose.yml
services:
  db:
    image: postgres:14
    volumes:
      - db-data:/var/lib/postgresql/data
    environment:
      POSTGRES_PASSWORD: secret

  migrate:
    image: myapp:latest
    command: npm run migrate
    depends_on:
      db:
        condition: service_healthy
    environment:
      DATABASE_URL: postgresql://db:5432/mydb

  app:
    image: myapp:latest
    depends_on:
      migrate:
        condition: service_completed_successfully
    ports:
      - "3000:3000"
```

```bash
# Step 1: Start database
docker compose up -d db

# Step 2: Run migrations
docker compose run --rm migrate

# Step 3: Start application
docker compose up -d app

# Or all at once
docker compose up -d
```

**Use case**: Database schema management  
**Best for**: Ensuring migrations run before app starts

---

## 🔧 Troubleshooting: When the Path is Obscured

*Even the wisest monks encounter obstacles.*

### Common Issues

#### Container Won't Start

```bash
# Check logs
docker logs container-name
docker logs --tail 100 container-name

# Check events
docker events --filter container=container-name

# Inspect container
docker inspect container-name

# Common causes:
# - Port already in use
# - Missing environment variables
# - Volume mount issues
# - Insufficient resources
```

#### Cannot Connect to Container

```bash
# Check if container is running
docker ps

# Check port mappings
docker port container-name

# Check network
docker network inspect bridge

# Test from host
curl http://localhost:8080

# Test from another container
docker run --rm --network container:container-name alpine wget -O- http://localhost:80
```

#### Image Build Fails

```bash
# Build with verbose output
docker build --progress=plain -t myapp:latest .

# Check build context size
du -sh .

# Use .dockerignore
echo "node_modules" >> .dockerignore
echo ".git" >> .dockerignore

# Clear build cache
docker builder prune
docker build --no-cache -t myapp:latest .
```

#### High Disk Usage

```bash
# Check disk usage
docker system df
docker system df -v

# Clean up
docker system prune                    # Remove unused data
docker system prune -a                 # Remove all unused images
docker system prune --volumes          # Include volumes

# Remove specific items
docker image prune
docker container prune
docker volume prune
docker network prune
```

#### Container Performance Issues

```bash
# Check resource usage
docker stats container-name

# Check logs for errors
docker logs container-name | grep -i error

# Inspect resource limits
docker inspect container-name | grep -A 10 "Memory"

# Increase resources
docker update --memory="1g" --cpus="2" container-name
```

#### Permission Denied Errors

```bash
# Check file ownership in container
docker exec container-name ls -la /path

# Run as specific user
docker exec -u root container-name chown -R user:group /path

# Fix volume permissions
docker run --rm -v myvolume:/data alpine chown -R 1000:1000 /data
```

---

## 🙏 Closing Wisdom

*The path of Docker mastery is endless. These commands are but stepping stones.*

### Essential Daily Commands

```bash
# The monk's morning ritual
docker ps
docker stats --no-stream
docker system df

# The monk's deployment ritual
docker compose build
docker compose up -d
docker compose logs -f

# The monk's evening reflection
docker ps -a
docker images
docker system prune -f
```

### Best Practices from the Monastery

1. **Use .dockerignore**: Reduce build context size
2. **Multi-stage Builds**: Keep production images small
3. **Specific Tags**: Never use `latest` in production
4. **Health Checks**: Always define health checks
5. **Resource Limits**: Set memory and CPU limits
6. **Non-root User**: Run containers as non-root
7. **Scan Images**: Regularly scan for vulnerabilities
8. **Log Management**: Configure log rotation
9. **Network Isolation**: Use custom networks
10. **Secrets Management**: Never hardcode secrets
11. **Version Control**: Store Dockerfiles in Git
12. **Clean Up**: Regularly prune unused resources

### Quick Reference Card

| Command | What It Does |
|---------|-------------|
| `docker run -d nginx` | Run container detached |
| `docker ps` | List running containers |
| `docker logs -f <name>` | Follow container logs |
| `docker exec -it <name> sh` | Shell into container |
| `docker build -t app .` | Build image |
| `docker compose up -d` | Start compose services |
| `docker compose down` | Stop compose services |
| `docker images` | List images |
| `docker system prune` | Clean up unused resources |
| `docker stats` | View resource usage |

---

*May your containers be lightweight, your builds be fast, and your deployments always successful.*

**— The Monk of Containers**  
*Monastery of Isolation*  
*Temple of Docker*

🧘 **Namaste, `docker`**

---

## 📚 Additional Resources

- [Official Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Dockerfile Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Docker Security](https://docs.docker.com/engine/security/)
- [Play with Docker](https://labs.play-with-docker.com/)
- [Docker Hub](https://hub.docker.com/)
- [Awesome Docker](https://github.com/veggiemonk/awesome-docker)

---

*Last Updated: 2025-10-02*  
*Version: 1.0.0 - The First Enlightenment*  
*Docker Version: 24.0+*  
*Docker Compose Version: 2.20+*
