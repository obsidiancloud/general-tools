# Solana Blockchain Development Environment

<div align="center">

![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![Rust](https://img.shields.io/badge/rust-%23000000.svg?style=for-the-badge&logo=rust&logoColor=white)
![Solana](https://img.shields.io/badge/Solana-9945FF?style=for-the-badge&logo=solana&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![Node.js](https://img.shields.io/badge/node.js-6DA55F?style=for-the-badge&logo=node.js&logoColor=white)
![TypeScript](https://img.shields.io/badge/typescript-%23007ACC.svg?style=for-the-badge&logo=typescript&logoColor=white)
![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54)

</div>

A comprehensive Docker-based development environment for Solana blockchain development with Rust, AWS Serverless Framework, and Terraform infrastructure management.

## 🚀 Overview

This development environment provides a complete, containerized setup for building Solana applications, smart contracts, and managing cloud infrastructure. It eliminates the need to install and configure multiple development tools locally, ensuring consistency across different development machines.

### 🏗️ Technology Stack

```mermaid
graph TB
    A[🐳 Docker Container] --> B[🦀 Rust Ecosystem]
    A --> C[☁️ AWS Tools]
    A --> D[🌐 Web3 Stack]
    A --> E[🏗️ Infrastructure]
    
    B --> B1[Rust 1.75.0]
    B --> B2[Cargo & Clippy]
    B --> B3[WASM Target]
    
    C --> C1[AWS CLI v2]
    C --> C2[Serverless Framework]
    C --> C3[LocalStack]
    
    D --> D1[Solana CLI]
    D --> D2[Anchor Framework]
    D --> D3[Web3.js]
    D --> D4[SPL Tokens]
    
    E --> E1[Terraform]
    E --> E2[Terragrunt]
    E --> E3[Docker-in-Docker]
```

## 🛠️ What's Included

### Core Blockchain Development
- ![Rust](https://img.shields.io/badge/rust-%23000000.svg?style=flat-square&logo=rust&logoColor=white) **Rust** (v1.75.0) with rustfmt, clippy, and WASM target support
- ![Solana](https://img.shields.io/badge/Solana-9945FF?style=flat-square&logo=solana&logoColor=white) **Solana CLI** (v1.17.15) with full blockchain development capabilities
- ⚓ **Anchor Framework** (latest) for Solana smart contract development
- 🪙 **SPL Token CLI** for Solana token operations
- ![JavaScript](https://img.shields.io/badge/javascript-%23323330.svg?style=flat-square&logo=javascript&logoColor=%23F7DF1E) **Solana Web3.js** and Project Serum Anchor libraries

### Cloud & Infrastructure Tools
- ![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=flat-square&logo=amazon-aws&logoColor=white) **AWS CLI** (v2.15.17) for cloud operations
- ⚡ **AWS Serverless Framework** (v3) with common plugins:
  - serverless-webpack
  - serverless-offline
  - serverless-dotenv-plugin
  - serverless-prune-plugin
- ![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=flat-square&logo=terraform&logoColor=white) **Terraform** (v1.6.6) for Infrastructure as Code
- 🏗️ **Terragrunt** for advanced Terraform workflows

### Development Environment
- ![Node.js](https://img.shields.io/badge/node.js-6DA55F?style=flat-square&logo=node.js&logoColor=white) **Node.js** (v20.x) with npm and Yarn
- ![TypeScript](https://img.shields.io/badge/typescript-%23007ACC.svg?style=flat-square&logo=typescript&logoColor=white) **TypeScript** with ESLint and Prettier
- ![Python](https://img.shields.io/badge/python-3670A0?style=flat-square&logo=python&logoColor=ffdd54) **Python 3** with boto3, pytest, and development tools
- ![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=flat-square&logo=docker&logoColor=white) **Docker CLI** for containerized workflows
- ![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=flat-square&logo=github&logoColor=white) **GitHub CLI** for repository management
- 🛠️ **Development utilities**: git, vim, nano, htop, tree, jq

### Optional Services (via docker-compose)
- ☁️ **LocalStack** for local AWS service emulation
- ![Redis](https://img.shields.io/badge/redis-%23DD0031.svg?style=flat-square&logo=redis&logoColor=white) **Redis** for caching and session storage
- ![PostgreSQL](https://img.shields.io/badge/postgres-%23316192.svg?style=flat-square&logo=postgresql&logoColor=white) **PostgreSQL** for database development

## 📋 Prerequisites

- Docker and Docker Compose installed
- At least 4GB of available RAM
- 10GB of free disk space
- Basic familiarity with Docker and command line

## 🚀 Quick Start

### 1. Clone and Setup

```bash
# Navigate to your development directory
cd ~/development

# Clone or copy the solana-development-environment folder
git clone <your-repo-url>/general-tools
cd general-tools/solana-development-environment

# Make the management script executable
chmod +x dev-env.sh
```

### 2. Start Development Environment

```bash
# Start the complete environment
./dev-env.sh start

# Or start just the main development container
docker-compose up -d solana-dev
```

### 3. Access the Container

```bash
# Open a shell in the development container
./dev-env.sh shell

# Or use docker-compose directly
docker-compose exec solana-dev bash
```

## 🔧 Configuration

### Directory Structure

The container creates and mounts the following directories:

```
./
├── projects/              # General development projects
├── solana-projects/       # Solana/Rust blockchain projects
├── serverless-projects/   # AWS Serverless applications
└── terraform-projects/    # Infrastructure as Code projects
```

### Volume Mounts

The docker-compose configuration automatically mounts:

- **Project directories**: Local development folders to container workspace
- **AWS credentials**: `~/.aws` (read-only) for cloud operations
- **SSH keys**: `~/.ssh` (read-only) for git operations
- **Git config**: `~/.gitconfig` (read-only) for version control
- **Docker socket**: For Docker-in-Docker scenarios

## 💻 Development Workflows

### Solana Smart Contract Development

```bash
# Enter the container
./dev-env.sh shell

# Navigate to Solana projects
cd /workspace/solana-projects

# Create a new Anchor project
anchor init my-solana-dapp
cd my-solana-dapp

# Build the project
anchor build

# Start local Solana test validator (in another terminal)
solana-test-validator

# Deploy to local network
anchor deploy

# Run tests
anchor test
```

### AWS Serverless Development

```bash
# Create a new serverless project
cd /workspace/serverless-projects
serverless create --template aws-nodejs-typescript --name my-api
cd my-api

# Install dependencies
npm install

# Deploy to AWS
serverless deploy

# Local development with offline plugin
serverless offline
```

### Terraform Infrastructure Management

```bash
# Create infrastructure project
cd /workspace/terraform-projects
mkdir my-infrastructure && cd my-infrastructure

# Create main.tf file
cat > main.tf << EOF
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
EOF

# Initialize and apply
terraform init
terraform plan
terraform apply
```

## 🌐 Port Mappings

| Port | Service | Description |
|------|---------|-------------|
| 3000 | Development Server | React/Next.js applications |
| 8000 | Web Server | General purpose web server |
| 8080 | Alternative Web | Alternative web server |
| 8545 | Blockchain | Ethereum/local blockchain |
| 8899 | Solana RPC | Solana localnet RPC endpoint |
| 8900 | Solana Validator | Solana test validator |
| 4566 | LocalStack | AWS services locally |
| 5432 | PostgreSQL | Database server |
| 6379 | Redis | Cache/session store |

## 🔍 Management Commands

The `dev-env.sh` script provides convenient management commands:

```bash
# Container lifecycle
./dev-env.sh build      # Build the Docker image
./dev-env.sh start      # Start the development environment
./dev-env.sh stop       # Stop the development environment
./dev-env.sh restart    # Restart the environment
./dev-env.sh shell      # Open a shell in the container

# Monitoring and maintenance
./dev-env.sh logs       # Show container logs
./dev-env.sh status     # Show container status and resource usage
./dev-env.sh update     # Rebuild and restart the container
./dev-env.sh clean      # Remove container and image
./dev-env.sh help       # Show help message
```

## 🔧 Customization

### Environment Variables

Customize the environment by modifying the `docker-compose.yml`:

```yaml
environment:
  - TZ=UTC                                    # Timezone
  - SOLANA_URL=https://api.devnet.solana.com  # Solana cluster
  - AWS_DEFAULT_REGION=us-east-1              # AWS region
  - NODE_ENV=development                      # Node.js environment
  - RUST_LOG=info                            # Rust logging level
```

### Adding Custom Tools

Extend the Dockerfile to include additional tools:

```dockerfile
# Add your custom tools
RUN apt-get update && apt-get install -y \
    your-custom-package \
    && rm -rf /var/lib/apt/lists/*

# Install custom npm packages
RUN npm install -g your-custom-package
```

## 🐛 Troubleshooting

### Common Issues

1. **Permission denied for Docker socket**
   ```bash
   sudo chmod 666 /var/run/docker.sock
   ```

2. **AWS credentials not found**
   - Ensure `~/.aws/credentials` exists and is properly formatted
   - Verify the volume mount in docker-compose.yml

3. **Port conflicts**
   - Check if ports are already in use: `netstat -tulpn | grep :8899`
   - Modify port mappings in docker-compose.yml if needed

4. **Out of memory errors**
   - Increase Docker memory allocation to at least 4GB
   - Monitor container resource usage: `./dev-env.sh status`

### Performance Optimization

1. **Use BuildKit for faster builds**
   ```bash
   export DOCKER_BUILDKIT=1
   ./dev-env.sh build
   ```

2. **Optimize .dockerignore**
   - Exclude unnecessary files to reduce build context
   - The provided .dockerignore covers common patterns

3. **Persistent volumes**
   - Use named volumes for data that should persist across container restarts
   - Consider mounting specific directories for better performance

## 📚 Learning Resources

### Solana Development
- [Solana Documentation](https://docs.solana.com/)
- [Anchor Framework Guide](https://www.anchor-lang.com/)
- [Solana Cookbook](https://solanacookbook.com/)
- [Solana Program Library](https://spl.solana.com/)

### AWS Serverless
- [Serverless Framework Documentation](https://www.serverless.com/framework/docs/)
- [AWS Lambda Developer Guide](https://docs.aws.amazon.com/lambda/)
- [LocalStack Documentation](https://docs.localstack.cloud/)

### Infrastructure as Code
- [Terraform Documentation](https://www.terraform.io/docs)
- [Terragrunt Documentation](https://terragrunt.gruntwork.io/)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

### Rust Programming
- [The Rust Programming Language](https://doc.rust-lang.org/book/)
- [Rust by Example](https://doc.rust-lang.org/rust-by-example/)
- [Cargo Book](https://doc.rust-lang.org/cargo/)

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

### Development Guidelines

- Follow existing code style and conventions
- Update documentation for any new features
- Test changes in multiple environments
- Consider backward compatibility

## 📄 License

This development environment is provided as-is for educational and development purposes. Individual tools and frameworks maintain their respective licenses.

## 🆘 Support

For issues and questions:

1. Check the troubleshooting section
2. Review the learning resources
3. Search existing issues in the repository
4. Create a new issue with detailed information

---

**Happy coding! 🚀**

Built with ❤️ for the Solana and Web3 development community.
