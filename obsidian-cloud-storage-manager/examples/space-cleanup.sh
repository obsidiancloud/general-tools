#!/bin/bash
#
# Example: Automated Space Cleanup Script
# Safely cleans up common space consumers on Linux systems
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║           Obsidian Cloud - Space Cleanup Utility             ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}This script must be run as root${NC}"
    exit 1
fi

# Initial disk usage
echo -e "${BLUE}=== Initial Disk Usage ===${NC}"
obsidian-storage overview

FREED_SPACE=0

# Function to calculate freed space
calculate_freed() {
    BEFORE=$(df / | tail -1 | awk '{print $3}')
    $1
    AFTER=$(df / | tail -1 | awk '{print $3}')
    DIFF=$((BEFORE - AFTER))
    FREED_SPACE=$((FREED_SPACE + DIFF))
    echo -e "${GREEN}✓ Freed: $(numfmt --to=iec-i --suffix=B $((DIFF * 1024)))${NC}"
}

# 1. Package manager cache
echo -e "\n${BLUE}[1/8]${NC} Cleaning package cache..."

if command -v pacman &> /dev/null; then
    echo "Removing pacman cache..."
    calculate_freed "pacman -Sc --noconfirm"
elif command -v apt &> /dev/null; then
    echo "Removing apt cache..."
    calculate_freed "apt clean"
    calculate_freed "apt autoremove -y"
elif command -v dnf &> /dev/null; then
    echo "Removing dnf cache..."
    calculate_freed "dnf clean all"
fi

# 2. Journalctl logs
echo -e "\n${BLUE}[2/8]${NC} Cleaning old journal logs..."
echo "Keeping last 3 days..."
calculate_freed "journalctl --vacuum-time=3d"

# 3. Temporary files
echo -e "\n${BLUE}[3/8]${NC} Cleaning temporary files..."
echo "Removing /tmp files older than 7 days..."
find /tmp -type f -atime +7 -delete 2>/dev/null || true
echo -e "${GREEN}✓ Done${NC}"

# 4. Old kernels (Arch-specific)
if command -v pacman &> /dev/null; then
    echo -e "\n${BLUE}[4/8]${NC} Cleaning old kernels..."
    CURRENT_KERNEL=$(uname -r | sed 's/-[^-]*$//')
    INSTALLED_KERNELS=$(pacman -Q | grep '^linux' | grep -v "$CURRENT_KERNEL" | awk '{print $1}')
    
    if [ -n "$INSTALLED_KERNELS" ]; then
        echo "Found old kernels:"
        echo "$INSTALLED_KERNELS"
        read -p "Remove old kernels? (yes/no): " CONFIRM
        if [ "$CONFIRM" == "yes" ]; then
            echo "$INSTALLED_KERNELS" | xargs pacman -R --noconfirm || true
        fi
    else
        echo "No old kernels found"
    fi
fi

# 5. Docker cleanup
if command -v docker &> /dev/null; then
    echo -e "\n${BLUE}[5/8]${NC} Cleaning Docker resources..."
    echo "Removing unused Docker images, containers, and volumes..."
    docker system prune -af --volumes 2>/dev/null || echo "Docker cleanup skipped"
fi

# 6. Thumbnail cache
echo -e "\n${BLUE}[6/8]${NC} Cleaning thumbnail cache..."
if [ -d "$HOME/.cache/thumbnails" ]; then
    THUMB_SIZE=$(du -sh "$HOME/.cache/thumbnails" 2>/dev/null | cut -f1)
    echo "Thumbnail cache size: $THUMB_SIZE"
    rm -rf "$HOME/.cache/thumbnails"/*
    echo -e "${GREEN}✓ Cleared thumbnail cache${NC}"
fi

# 7. Browser caches
echo -e "\n${BLUE}[7/8]${NC} Cleaning browser caches..."

# Chrome/Chromium
if [ -d "$HOME/.cache/google-chrome" ]; then
    CHROME_SIZE=$(du -sh "$HOME/.cache/google-chrome" 2>/dev/null | cut -f1)
    echo "Chrome cache: $CHROME_SIZE"
    rm -rf "$HOME/.cache/google-chrome/Default/Cache"/* 2>/dev/null || true
fi

# Firefox
if [ -d "$HOME/.cache/mozilla" ]; then
    FF_SIZE=$(du -sh "$HOME/.cache/mozilla" 2>/dev/null | cut -f1)
    echo "Firefox cache: $FF_SIZE"
    rm -rf "$HOME/.cache/mozilla/firefox/*/cache2"/* 2>/dev/null || true
fi

# Vivaldi
if [ -d "$HOME/.cache/vivaldi" ]; then
    VIV_SIZE=$(du -sh "$HOME/.cache/vivaldi" 2>/dev/null | cut -f1)
    echo "Vivaldi cache: $VIV_SIZE"
    rm -rf "$HOME/.cache/vivaldi/Default/Cache"/* 2>/dev/null || true
fi

echo -e "${GREEN}✓ Browser caches cleaned${NC}"

# 8. Find large files
echo -e "\n${BLUE}[8/8]${NC} Locating large files (>1GB)..."
echo "This may take a moment..."
echo ""

find / -type f -size +1G -exec ls -lh {} \; 2>/dev/null | \
    awk '{print $5, $9}' | \
    head -10 | \
    while read size path; do
        echo "  $size  $path"
    done

# Final report
echo ""
echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                     Cleanup Complete!                        ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

if [ $FREED_SPACE -gt 0 ]; then
    echo -e "${GREEN}Total space freed: $(numfmt --to=iec-i --suffix=B $((FREED_SPACE * 1024)))${NC}"
else
    echo -e "${GREEN}Space optimized!${NC}"
fi

echo ""
echo -e "${BLUE}=== Final Disk Usage ===${NC}"
obsidian-storage overview

echo ""
echo -e "${YELLOW}Recommendations:${NC}"
echo "  • Run this script monthly for maintenance"
echo "  • Use 'obsidian-storage analyze' to find space hogs"
echo "  • Consider moving large files to external storage"
echo "  • Enable automatic trim for SSDs: systemctl enable fstrim.timer"
echo ""
