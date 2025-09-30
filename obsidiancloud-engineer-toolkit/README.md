# Arch Linux WSL Development Environment Bootstrap

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Shell](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/Platform-WSL%202-orange.svg)](https://docs.microsoft.com/en-us/windows/wsl/)
[![Arch Linux](https://img.shields.io/badge/Distro-Arch%20Linux-blue.svg)](https://archlinux.org/)

> **Production-grade bootstrap script for setting up a comprehensive development environment on Arch Linux WSL**

Transform your Arch Linux WSL distribution into a powerful, modern development environment optimized for cloud-native development, AI/ML workflows, and full-stack application development.

## 🚀 Quick Start

```bash
# Download and run with default settings
curl -fsSL https://raw.githubusercontent.com/your-repo/bootstrap-arch-wsl/main/bootstrap-arch-wsl.sh | bash

# Or download first for customization
wget https://raw.githubusercontent.com/your-repo/bootstrap-arch-wsl/main/bootstrap-arch-wsl.sh
chmod +x bootstrap-arch-wsl.sh
./bootstrap-arch-wsl.sh --username mydev --enable-systemd --cloud aws --ai
```

## 📋 Prerequisites

### System Requirements
- **Windows 10** (version 21H2+) or **Windows 11**
- **WSL 2** installed and configured
- **Arch Linux** WSL distribution (e.g., [ArchWSL](https://github.com/yuk7/ArchWSL))
- **Minimum 4GB RAM** (8GB+ recommended for AI/ML)
- **10GB+ free disk space**
- **Internet connection** for package downloads

### Initial Setup
1. Install WSL 2 and Arch Linux distribution
2. Ensure network connectivity
3. Have administrator access for sudo operations

## 🛠 What Gets Installed

### Core Development Environment
- **Shell**: Zsh + Oh My Zsh + Powerlevel10k + plugins
- **Editor**: Visual Studio Code with essential extensions  
- **Version Control**: Git with optimized configuration
- **Build Tools**: GCC, Clang, CMake, Make, Ninja
- **Modern CLI**: ripgrep, fd, fzf, bat, eza, zoxide, fastfetch

### Runtime Management
- **asdf** version manager with plugins for:
  - Node.js (LTS) + npm ecosystem tools
  - Python (3.12+) + pipx tools (poetry, black, pytest)
  - Go (latest stable)
  - Java (Temurin 21 LTS)
  - Rust (stable) + Cargo tools
  - Terraform, kubectl, Helm

### Infrastructure & DevOps
- **Containers**: Docker, Docker Compose, Podman
- **Kubernetes**: kubectl, helm, k9s, stern, kubectx
- **Infrastructure as Code**: Terraform, Terragrunt, Ansible, Packer
- **Security**: Trivy, Checkov, SOPS, Age
- **Cloud CLIs**: AWS, GCP, Azure (configurable)

### AI/ML Environment (Optional)
- **Micromamba** with comprehensive Python data science stack
- **Libraries**: PyTorch, scikit-learn, pandas, numpy, matplotlib
- **Jupyter Lab** with custom kernel and sample notebooks
- **Additional**: OpenAI, LangChain, Transformers, HuggingFace

### Fonts & UI
- **Nerd Fonts**: MesloLGS, JetBrains Mono, Fira Code
- **System Fonts**: Noto fonts with emoji support

## ⚙️ Usage

### Basic Usage
```bash
./bootstrap-arch-wsl.sh [OPTIONS]
```

### Configuration Options

| Option | Description | Default |
|--------|-------------|---------|
| `--username <name>` | Developer username to create | `dev` |
| `--password <pass>` | User password (prompt if omitted) | *none* |
| `--hostname <name>` | System hostname | `arch-wsl` |
| `--enable-systemd` | Enable systemd in WSL | `false` |
| `--ai` / `--no-ai` | Install AI/ML environment | `true` |
| `--gpu` | Show GPU setup instructions | `false` |
| `--cloud <provider>` | Cloud CLIs: `all`\|`aws`\|`gcp`\|`azure`\|`none` | `all` |
| `--skip-ohmyzsh` | Skip Oh My Zsh installation | `false` |
| `--run-postfix "<cmd>"` | Command to run after setup | *none* |
| `-h, --help` | Show help message | - |

### Common Usage Patterns

#### Full Development Environment
```bash
./bootstrap-arch-wsl.sh \
  --username developer \
  --password mypassword \
  --hostname dev-machine \
  --enable-systemd \
  --cloud all \
  --ai \
  --gpu
```

#### Minimal Cloud Development
```bash
./bootstrap-arch-wsl.sh \
  --username dev \
  --cloud aws \
  --no-ai \
  --skip-ohmyzsh
```

#### AI/ML Focused Setup
```bash
./bootstrap-arch-wsl.sh \
  --username datascientist \
  --ai \
  --gpu \
  --cloud none \
  --run-postfix "micromamba activate ai && jupyter lab --generate-config"
```

## 🔧 Advanced Configuration

### Environment Variables
```bash
# Network timeout for downloads (seconds)
export NETWORK_TIMEOUT=60

# Installation timeout per operation (seconds)  
export INSTALL_TIMEOUT=900

# Custom package mirror
export CUSTOM_MIRROR="https://mirror.example.com/archlinux"
```

### Custom Package Lists
Create custom package lists in your environment:
```bash
# Additional packages to install
export EXTRA_PACMAN_PACKAGES="code tmux vim"
export EXTRA_AUR_PACKAGES="google-chrome discord"
```

## 📊 Post-Installation

### Verification
The script includes comprehensive validation:
```bash
# Check installation status
cat ~/.bootstrap_complete

# View installation log
tail -f /tmp/bootstrap-arch-wsl.*.log

# Test key components
fastfetch                    # System information
docker run hello-world       # Docker functionality
kubectl version --client     # Kubernetes tools
micromamba activate ai && python -c "import torch; print(torch.__version__)"
```

### Next Steps

1. **Configure Git Identity**:
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "you@example.com"
   ```

2. **Terminal Font**: Set terminal to use a Nerd Font (MesloLGS NF recommended)

3. **Docker Desktop**: Enable WSL integration for this distribution

4. **Restart WSL** (if systemd enabled):
   ```powershell
   # From Windows PowerShell
   wsl --shutdown
   ```

5. **Start Development**:
   ```bash
   # New shell session
   source ~/.zshrc
   
   # AI/ML development
   jl  # Start Jupyter Lab
   
   # Test environment
   fastfetch && docker ps && kubectl version --client
   ```

## 🛡️ Security & Best Practices

### Security Features
- **Minimal privilege escalation** with time-limited sudo
- **Secure package verification** with GPG keyring validation
- **Input validation** for all user-provided parameters
- **Safe file operations** with atomic updates and backups

### Best Practices Implemented
- **Idempotent operations** - safe to re-run multiple times
- **Comprehensive error handling** with retry logic and graceful degradation
- **Resource management** with cleanup on interruption
- **Extensive logging** with timestamps and structured output
- **Validation checks** to verify successful installation

### Network Security
- **HTTPS-only downloads** with certificate verification
- **Timeout protection** against hanging operations
- **Mirror validation** for package authenticity

## 🔍 Troubleshooting

### Common Issues

#### Permission Denied
```bash
# Ensure user is in correct groups
groups $USER
# Should include: wheel docker

# Fix Docker permissions
sudo usermod -aG docker $USER
# Logout and login again
```

#### Package Installation Failures
```bash
# Update keyring and refresh packages
sudo pacman-key --init
sudo pacman-key --populate archlinux
sudo pacman -Syyu
```

#### Docker Service Issues
```bash
# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Check Docker status
systemctl status docker

# Add user to docker group (logout/login required)
sudo usermod -aG docker $USER
```

#### GPU/CUDA Issues
```bash
# Check NVIDIA driver
nvidia-smi

# Reinstall CUDA if needed
sudo pacman -S cuda cudnn

# Verify PyTorch CUDA
micromamba activate ai
python -c "import torch; print(torch.cuda.is_available())"
```

#### Service Management
```bash
# Check failed services
systemctl --failed

# Enable essential services
sudo systemctl enable --now docker
sudo systemctl enable --now NetworkManager
```

### Hardware-Specific Issues

#### NVIDIA GPU
- Ensure proprietary drivers are installed: `sudo pacman -S nvidia nvidia-utils`
- For older cards: `sudo pacman -S nvidia-470xx-dkms`
- Verify kernel modules: `lsmod | grep nvidia`

#### AMD GPU  
- Install mesa drivers: `sudo pacman -S mesa vulkan-radeon`
- For older cards: `sudo pacman -S xf86-video-amdgpu`

#### Audio Issues (CachyOS)
```bash
# Install audio system
sudo pacman -S pipewire pipewire-alsa pipewire-pulse wireplumber
systemctl --user enable --now pipewire pipewire-pulse wireplumber
```

## 🏗️ Development Workflows

### Container Development
```bash
# Start with Docker Compose
cd your-project
docker-compose up -d

# Kubernetes development  
kubectl create namespace dev
kubectl config set-context --current --namespace=dev
```

### AI/ML Development
```bash
# Activate AI environment
micromamba activate ai

# Start Jupyter Lab with GPU support
jl

# Install additional packages
micromamba install -n ai tensorflow-gpu
```

### Cloud Development
```bash
# Configure AWS CLI
aws configure sso

# Deploy with Terraform
terraform init && terraform plan && terraform apply

# Kubernetes deployment
kubectl apply -f deployment.yaml

# Monitor deployments
kubectl get pods -w
```

## 📚 Additional Resources

### CachyOS Specific
- [CachyOS Documentation](https://wiki.cachyos.org/)
- [CachyOS GitHub](https://github.com/cachyos)
- [Performance Optimizations](https://wiki.cachyos.org/configuration/general_system_tweaks/)

### Development Resources  
- [Arch Linux Wiki](https://wiki.archlinux.org/)
- [AUR Guidelines](https://wiki.archlinux.org/title/Arch_User_Repository)
- [Paru AUR Helper](https://github.com/Morganamilo/paru)
- [systemd Services](https://wiki.archlinux.org/title/Systemd)

### GPU Development
- [CUDA Programming Guide](https://docs.nvidia.com/cuda/cuda-c-programming-guide/)
- [PyTorch CUDA Documentation](https://pytorch.org/docs/stable/notes/cuda.html)
- [ROCm Documentation](https://docs.amd.com/)

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Setup
```bash
# Clone repository  
git clone https://github.com/your-repo/bootstrap-cachyos.git
cd bootstrap-cachyos

# Test in container
docker run -it archlinux:latest bash
# Copy and test script
```

### Reporting Issues
- Use GitHub Issues for bug reports
- Include system information (`fastfetch`)
- Provide full error logs
- Specify hardware configuration (especially GPU)