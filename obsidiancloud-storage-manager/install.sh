#!/bin/bash
#
# Obsidian Cloud Storage Manager - Installation Script
# Production-grade disk management utility installer
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_TARGET="${1:-user}"  # 'user' or 'system'

echo -e "${CYAN}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║         Obsidian Cloud Storage Manager Installer             ║"
echo "║                     Version 1.0.0                            ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check Python version
echo -e "${BLUE}[1/6]${NC} Checking Python version..."
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}✗ Python 3 not found. Please install Python 3.6 or higher.${NC}"
    exit 1
fi

PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
echo -e "${GREEN}✓ Python ${PYTHON_VERSION} found${NC}"

# Check required commands
echo -e "${BLUE}[2/6]${NC} Checking required dependencies..."

REQUIRED_COMMANDS=("lsblk" "df" "du" "sfdisk")
MISSING_COMMANDS=()

for cmd in "${REQUIRED_COMMANDS[@]}"; do
    if ! command -v "$cmd" &> /dev/null; then
        MISSING_COMMANDS+=("$cmd")
    fi
done

if [ ${#MISSING_COMMANDS[@]} -gt 0 ]; then
    echo -e "${YELLOW}⚠ Missing required commands: ${MISSING_COMMANDS[*]}${NC}"
    echo -e "${YELLOW}  Please install: sudo pacman -S util-linux${NC}"
else
    echo -e "${GREEN}✓ All required commands found${NC}"
fi

# Check optional commands
OPTIONAL_COMMANDS=("pvs" "vgs" "lvs" "parted" "smartctl")
MISSING_OPTIONAL=()

for cmd in "${OPTIONAL_COMMANDS[@]}"; do
    if ! command -v "$cmd" &> /dev/null; then
        MISSING_OPTIONAL+=("$cmd")
    fi
done

if [ ${#MISSING_OPTIONAL[@]} -gt 0 ]; then
    echo -e "${YELLOW}⚠ Missing optional commands: ${MISSING_OPTIONAL[*]}${NC}"
    echo -e "${YELLOW}  For full functionality: sudo pacman -S lvm2 parted smartmontools${NC}"
else
    echo -e "${GREEN}✓ All optional commands found${NC}"
fi

# Make script executable
echo -e "${BLUE}[3/6]${NC} Making storage_manager.py executable..."
chmod +x "${SCRIPT_DIR}/storage_manager.py"
echo -e "${GREEN}✓ Made executable${NC}"

# Install script
echo -e "${BLUE}[4/6]${NC} Installing storage manager..."

if [ "$INSTALL_TARGET" == "system" ]; then
    # System-wide installation
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}✗ System installation requires root privileges${NC}"
        echo -e "${YELLOW}  Run: sudo ./install.sh system${NC}"
        exit 1
    fi
    
    INSTALL_DIR="/usr/local/bin"
    INSTALL_PATH="${INSTALL_DIR}/obsidian-storage"
    
    ln -sf "${SCRIPT_DIR}/storage_manager.py" "$INSTALL_PATH"
    echo -e "${GREEN}✓ Installed to: ${INSTALL_PATH}${NC}"
else
    # User installation
    INSTALL_DIR="${HOME}/.local/bin"
    INSTALL_PATH="${INSTALL_DIR}/obsidian-storage"
    
    mkdir -p "$INSTALL_DIR"
    ln -sf "${SCRIPT_DIR}/storage_manager.py" "$INSTALL_PATH"
    echo -e "${GREEN}✓ Installed to: ${INSTALL_PATH}${NC}"
    
    # Check if ~/.local/bin is in PATH
    if [[ ":$PATH:" != *":${HOME}/.local/bin:"* ]]; then
        echo -e "${YELLOW}⚠ ${HOME}/.local/bin is not in your PATH${NC}"
        echo -e "${YELLOW}  Add to ~/.zshrc or ~/.bashrc:${NC}"
        echo -e "${CYAN}  export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}"
    fi
fi

# Create backup directory
echo -e "${BLUE}[5/6]${NC} Creating backup directory..."
BACKUP_DIR="${HOME}/.storage-manager-backups"
mkdir -p "$BACKUP_DIR"
echo -e "${GREEN}✓ Backup directory: ${BACKUP_DIR}${NC}"

# Test installation
echo -e "${BLUE}[6/6]${NC} Testing installation..."
if command -v obsidian-storage &> /dev/null; then
    echo -e "${GREEN}✓ Installation successful!${NC}"
else
    echo -e "${YELLOW}⚠ Command not found in PATH. You may need to restart your shell.${NC}"
fi

# Print usage instructions
echo ""
echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                   Installation Complete!                     ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Usage:${NC}"
echo ""
echo -e "  ${CYAN}obsidian-storage overview${NC}        - View disk overview"
echo -e "  ${CYAN}obsidian-storage lvm${NC}             - View LVM information"
echo -e "  ${CYAN}obsidian-storage analyze${NC}         - Analyze disk usage"
echo -e "  ${CYAN}obsidian-storage backup --device /dev/sda${NC} - Backup partition table"
echo -e "  ${CYAN}obsidian-storage list-backups${NC}    - List all backups"
echo ""
echo -e "${YELLOW}Note: Most commands require root privileges (sudo)${NC}"
echo ""
echo -e "${BLUE}Documentation: ${SCRIPT_DIR}/README.md${NC}"
echo ""

# Check if need to reload shell
if [[ "$INSTALL_TARGET" == "user" ]] && [[ ":$PATH:" != *":${HOME}/.local/bin:"* ]]; then
    echo -e "${YELLOW}Remember to add ~/.local/bin to your PATH or restart your shell!${NC}"
    echo ""
fi

exit 0
