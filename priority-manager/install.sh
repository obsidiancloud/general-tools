#!/usr/bin/env bash
#
# Priority Manager Installation Script
#
# License: GPL-3.0
# Repository: https://github.com/obsidiancloud/general-tools
#

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

clear

echo -e "${BOLD}${CYAN}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════════════════╗
║                                                                       ║
║           PRIORITY MANAGER INSTALLATION                              ║
║           Automatic Process Priority Management                      ║
║                                                                       ║
╚═══════════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo -e "${BOLD}This will:${NC}"
echo -e "  ${GREEN}✓${NC} Install priority management scripts"
echo -e "  ${GREEN}✓${NC} Set up systemd service for automatic monitoring"
echo -e "  ${GREEN}✓${NC} Configure auto-start on login"
echo ""

read -p "Press ENTER to continue with installation..."
echo ""

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Step 1: Create directories
echo -e "${YELLOW}[1/6]${NC} Creating directories..."
mkdir -p ~/.local/bin
mkdir -p ~/.local/var/log
mkdir -p ~/.config/systemd/user
echo -e "${GREEN}✓${NC} Directories created"
echo ""

# Step 2: Install scripts
echo -e "${YELLOW}[2/6]${NC} Installing scripts..."
cp "$SCRIPT_DIR/bin/priority-manager.sh" ~/.local/bin/
cp "$SCRIPT_DIR/bin/boost-now.sh" ~/.local/bin/
cp "$SCRIPT_DIR/bin/priority-dashboard.sh" ~/.local/bin/
chmod +x ~/.local/bin/priority-manager.sh
chmod +x ~/.local/bin/boost-now.sh
chmod +x ~/.local/bin/priority-dashboard.sh
echo -e "${GREEN}✓${NC} Scripts installed"
echo ""

# Step 3: Install systemd service
echo -e "${YELLOW}[3/6]${NC} Installing systemd service..."
cp "$SCRIPT_DIR/systemd/priority-manager.service" ~/.config/systemd/user/
echo -e "${GREEN}✓${NC} Service file installed"
echo ""

# Step 4: Reload systemd
echo -e "${YELLOW}[4/6]${NC} Reloading systemd user daemon..."
systemctl --user daemon-reload
echo -e "${GREEN}✓${NC} Systemd reloaded"
echo ""

# Step 5: Enable service
echo -e "${YELLOW}[5/6]${NC} Enabling priority manager service..."
systemctl --user enable priority-manager.service
echo -e "${GREEN}✓${NC} Service enabled"
echo ""

# Step 6: Start service
echo -e "${YELLOW}[6/6]${NC} Starting priority manager service..."
systemctl --user start priority-manager.service
sleep 2
echo -e "${GREEN}✓${NC} Service started"
echo ""

echo -e "${BOLD}${CYAN}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${NC}"

echo -e "${BOLD}${GREEN}✅ INSTALLATION COMPLETE!${NC}"
echo ""
echo -e "${BOLD}Next Steps:${NC}"
echo ""
echo -e "1. ${CYAN}Edit ~/.local/bin/priority-manager.sh${NC}"
echo -e "   Customize CRITICAL_APPS and DEPRIORITIZE_APPS arrays"
echo ""
echo -e "2. ${CYAN}Optional: Install sudoers rule for maximum priority:${NC}"
echo -e "   sudo cp $SCRIPT_DIR/sudoers/priority-manager.conf /etc/sudoers.d/priority-manager"
echo -e "   sudo chmod 440 /etc/sudoers.d/priority-manager"
echo -e "   sudo sed -i \"s/USERNAME/\$(whoami)/g\" /etc/sudoers.d/priority-manager"
echo ""
echo -e "3. ${CYAN}Restart the service:${NC}"
echo -e "   systemctl --user restart priority-manager"
echo ""
echo -e "${BOLD}Quick Commands:${NC}"
echo -e "  View Dashboard:  ~/.local/bin/priority-dashboard.sh"
echo -e "  Emergency Boost: sudo ~/.local/bin/boost-now.sh"
echo -e "  Check Status:    ~/.local/bin/priority-manager.sh status"
echo ""
