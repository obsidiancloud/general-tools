#!/usr/bin/env bash
#
# Priority Manager Uninstallation Script
#
# License: GPL-3.0
# Repository: https://github.com/obsidiancloud/general-tools
#

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BOLD}${RED}Priority Manager Uninstallation${NC}"
echo ""
echo "This will remove:"
echo "  - Priority manager scripts"
echo "  - Systemd service"
echo "  - Log files"
echo ""

read -p "Are you sure you want to uninstall? (y/N): " -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstallation cancelled."
    exit 0
fi

echo -e "${YELLOW}Stopping and disabling service...${NC}"
systemctl --user stop priority-manager.service 2>/dev/null || true
systemctl --user disable priority-manager.service 2>/dev/null || true
echo -e "${GREEN}✓${NC} Service stopped"
echo ""

echo -e "${YELLOW}Removing files...${NC}"
rm -f ~/.local/bin/priority-manager.sh
rm -f ~/.local/bin/boost-now.sh
rm -f ~/.local/bin/priority-dashboard.sh
rm -f ~/.config/systemd/user/priority-manager.service
rm -rf ~/.local/var/log/priority-manager.log
echo -e "${GREEN}✓${NC} Files removed"
echo ""

echo -e "${YELLOW}Reloading systemd...${NC}"
systemctl --user daemon-reload
echo -e "${GREEN}✓${NC} Systemd reloaded"
echo ""

if [[ -f "/etc/sudoers.d/priority-manager" ]]; then
    echo -e "${YELLOW}Sudoers rule detected. Remove it manually with:${NC}"
    echo "  sudo rm /etc/sudoers.d/priority-manager"
    echo ""
fi

echo -e "${GREEN}✅ Uninstallation complete!${NC}"
