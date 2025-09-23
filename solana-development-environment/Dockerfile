# Solana Blockchain Development Container
# Includes: Rust, Solana CLI, Node.js, AWS Serverless Framework, Terraform, AWS CLI
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV RUST_VERSION=1.75.0
ENV NODE_VERSION=20.x
ENV TERRAFORM_VERSION=1.6.6
ENV SOLANA_VERSION=1.17.15
ENV AWS_CLI_VERSION=2.15.17

# Set working directory
WORKDIR /workspace

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    pkg-config \
    libudev-dev \
    libssl-dev \
    libclang-dev \
    python3 \
    python3-pip \
    unzip \
    jq \
    vim \
    nano \
    htop \
    tree \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common \
    apt-transport-https \
    && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain ${RUST_VERSION}
ENV PATH="/root/.cargo/bin:${PATH}"

# Install additional Rust components
RUN rustup component add rustfmt clippy
RUN rustup target add wasm32-unknown-unknown

# Install Node.js and npm
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION} | bash - \
    && apt-get install -y nodejs

# Install Yarn (alternative package manager)
RUN npm install -g yarn

# Install AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf aws awscliv2.zip

# Install Serverless Framework
RUN npm install -g serverless@3

# Install additional serverless plugins commonly used
RUN npm install -g \
    serverless-webpack \
    serverless-offline \
    serverless-dotenv-plugin \
    serverless-prune-plugin

# Install Terraform
RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && mv terraform /usr/local/bin/ \
    && rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Install Terragrunt (Terraform wrapper)
RUN wget https://github.com/gruntwork-io/terragrunt/releases/download/v0.54.8/terragrunt_linux_amd64 \
    && chmod +x terragrunt_linux_amd64 \
    && mv terragrunt_linux_amd64 /usr/local/bin/terragrunt

# Install Solana CLI
RUN sh -c "$(curl -sSfL https://release.solana.com/v${SOLANA_VERSION}/install)" \
    && echo 'export PATH="/root/.local/share/solana/install/active_release/bin:$PATH"' >> ~/.bashrc
ENV PATH="/root/.local/share/solana/install/active_release/bin:${PATH}"

# Install Anchor Framework for Solana
RUN cargo install --git https://github.com/coral-xyz/anchor avm --locked --force \
    && avm install latest \
    && avm use latest

# Install additional Solana development tools
RUN cargo install spl-token-cli
RUN npm install -g @solana/web3.js @project-serum/anchor

# Install Docker CLI (for Docker-in-Docker scenarios)
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && apt-get install -y docker-ce-cli \
    && rm -rf /var/lib/apt/lists/*

# Install additional development tools
RUN npm install -g \
    typescript \
    ts-node \
    eslint \
    prettier \
    @typescript-eslint/parser \
    @typescript-eslint/eslint-plugin

# Install Python packages for AWS and general development
RUN pip3 install \
    boto3 \
    awscli-local \
    localstack \
    pytest \
    black \
    flake8

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install gh -y \
    && rm -rf /var/lib/apt/lists/*

# Create development directories
RUN mkdir -p /workspace/solana-projects \
    && mkdir -p /workspace/serverless-projects \
    && mkdir -p /workspace/terraform-projects

# Set up shell environment
RUN echo 'alias ll="ls -la"' >> ~/.bashrc \
    && echo 'alias la="ls -la"' >> ~/.bashrc \
    && echo 'alias ..="cd .."' >> ~/.bashrc \
    && echo 'alias ...="cd ../.."' >> ~/.bashrc \
    && echo 'export EDITOR=nano' >> ~/.bashrc

# Create a startup script
RUN echo '#!/bin/bash\n\
echo "=== Solana Blockchain Development Environment ==="\n\
echo "Rust version: $(rustc --version)"\n\
echo "Solana CLI version: $(solana --version)"\n\
echo "Node.js version: $(node --version)"\n\
echo "npm version: $(npm --version)"\n\
echo "Serverless version: $(serverless --version)"\n\
echo "Terraform version: $(terraform --version | head -n1)"\n\
echo "AWS CLI version: $(aws --version)"\n\
echo "Anchor version: $(anchor --version)"\n\
echo ""\n\
echo "Available directories:"\n\
echo "  /workspace/solana-projects - For Solana/Rust projects"\n\
echo "  /workspace/serverless-projects - For AWS Serverless projects"\n\
echo "  /workspace/terraform-projects - For Infrastructure as Code"\n\
echo ""\n\
echo "Ready for development! 🚀"\n\
exec "$@"' > /usr/local/bin/startup.sh \
    && chmod +x /usr/local/bin/startup.sh

# Expose common ports
EXPOSE 3000 8000 8080 8545 8899 8900

# Set default command
ENTRYPOINT ["/usr/local/bin/startup.sh"]
CMD ["/bin/bash"]

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD solana --version && terraform --version && aws --version || exit 1
