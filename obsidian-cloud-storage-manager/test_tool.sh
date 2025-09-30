#!/bin/bash
#
# Test Script for Obsidian Cloud Storage Manager
# Demonstrates all features without requiring root privileges where possible
#

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║      Obsidian Cloud Storage Manager - Test Suite            ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOL="${SCRIPT_DIR}/storage_manager.py"

# Check if tool exists
if [ ! -f "$TOOL" ]; then
    echo -e "${RED}✗ storage_manager.py not found${NC}"
    exit 1
fi

# Make executable
chmod +x "$TOOL"

echo -e "${BLUE}Test 1: Help and Version${NC}"
python3 "$TOOL" --help || echo "No help flag implemented (OK)"
echo ""

echo -e "${BLUE}Test 2: Disk Overview (requires sudo)${NC}"
echo "Command: sudo python3 $TOOL overview"
echo -e "${YELLOW}Run manually: sudo python3 $TOOL overview${NC}"
echo ""

echo -e "${BLUE}Test 3: LVM Information (requires sudo)${NC}"
echo "Command: sudo python3 $TOOL lvm"
echo -e "${YELLOW}Run manually: sudo python3 $TOOL lvm${NC}"
echo ""

echo -e "${BLUE}Test 4: Space Analysis${NC}"
echo "Command: sudo python3 $TOOL analyze --path $HOME"
echo -e "${YELLOW}Run manually: sudo python3 $TOOL analyze --path $HOME${NC}"
echo ""

echo -e "${BLUE}Test 5: List Backups (no sudo needed)${NC}"
python3 "$TOOL" list-backups
echo ""

echo -e "${BLUE}Test 6: Backup Partition Table (requires sudo)${NC}"
echo "Command: sudo python3 $TOOL backup --device /dev/sda"
echo -e "${YELLOW}Run manually after checking your device name with 'lsblk'${NC}"
echo ""

echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                    Test Suite Complete!                      ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}Quick Start Commands:${NC}"
echo ""
echo -e "  ${GREEN}sudo python3 $TOOL overview${NC}"
echo -e "    └─ View all disks, partitions, and usage"
echo ""
echo -e "  ${GREEN}sudo python3 $TOOL analyze --path /${NC}"
echo -e "    └─ Find what's using space on root partition"
echo ""
echo -e "  ${GREEN}sudo python3 $TOOL lvm${NC}"
echo -e "    └─ View LVM configuration (if using LVM)"
echo ""
echo -e "  ${GREEN}python3 $TOOL list-backups${NC}"
echo -e "    └─ List all partition table backups"
echo ""
echo -e "${YELLOW}For full installation:${NC}"
echo -e "  ${CYAN}./install.sh${NC}"
echo ""
