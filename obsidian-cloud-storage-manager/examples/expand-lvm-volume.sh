#!/bin/bash
#
# Example: Expand LVM Logical Volume
# This script demonstrates how to safely expand an LVM volume
#
# WARNING: Review and modify before running!
#

set -e

# Configuration - MODIFY THESE
VG_NAME="vg_main"           # Volume Group name
LV_NAME="lv_root"           # Logical Volume name
EXPAND_SIZE="+10G"          # How much to expand (e.g., +10G, +50%FREE)
FILESYSTEM="ext4"           # Filesystem type (ext4, xfs, btrfs)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== LVM Volume Expansion Script ===${NC}"
echo ""
echo "Configuration:"
echo "  Volume Group: $VG_NAME"
echo "  Logical Volume: $LV_NAME"
echo "  Expand Size: $EXPAND_SIZE"
echo "  Filesystem: $FILESYSTEM"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}This script must be run as root${NC}"
    exit 1
fi

# Confirm
read -p "Continue with expansion? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    echo -e "${YELLOW}Aborted${NC}"
    exit 0
fi

# Step 1: Display current state
echo -e "\n${BLUE}[1/6]${NC} Current LVM state:"
obsidian-storage lvm

# Step 2: Check volume group has free space
echo -e "\n${BLUE}[2/6]${NC} Checking free space in volume group..."
VG_FREE=$(vgs --noheadings -o vg_free --units g "$VG_NAME" | tr -d ' ')
echo "Free space: $VG_FREE"

if [ "$VG_FREE" == "0g" ]; then
    echo -e "${RED}No free space in volume group!${NC}"
    echo "You may need to:"
    echo "  1. Add a new physical volume: pvcreate /dev/sdXN"
    echo "  2. Extend volume group: vgextend $VG_NAME /dev/sdXN"
    exit 1
fi

# Step 3: Backup partition table
echo -e "\n${BLUE}[3/6]${NC} Creating backup..."
LV_DEVICE=$(lvs --noheadings -o lv_path "$VG_NAME/$LV_NAME" | tr -d ' ')
MOUNT_POINT=$(findmnt -n -o TARGET --source "$LV_DEVICE")

# Get parent disk
PARENT_DISK=$(pvs --noheadings -o pv_name,vg_name | grep "$VG_NAME" | head -1 | awk '{print $1}' | sed 's/[0-9]*$//')
obsidian-storage backup --device "$PARENT_DISK"

# Step 4: Extend logical volume
echo -e "\n${BLUE}[4/6]${NC} Extending logical volume..."
echo "Running: lvextend -L $EXPAND_SIZE $LV_DEVICE"
lvextend -L "$EXPAND_SIZE" "$LV_DEVICE"

# Step 5: Resize filesystem
echo -e "\n${BLUE}[5/6]${NC} Resizing filesystem..."

case "$FILESYSTEM" in
    ext4|ext3|ext2)
        echo "Running: resize2fs $LV_DEVICE"
        resize2fs "$LV_DEVICE"
        ;;
    xfs)
        echo "Running: xfs_growfs $MOUNT_POINT"
        xfs_growfs "$MOUNT_POINT"
        ;;
    btrfs)
        echo "Running: btrfs filesystem resize max $MOUNT_POINT"
        btrfs filesystem resize max "$MOUNT_POINT"
        ;;
    *)
        echo -e "${RED}Unknown filesystem: $FILESYSTEM${NC}"
        echo "Filesystem was NOT resized. You must resize it manually."
        exit 1
        ;;
esac

# Step 6: Verify
echo -e "\n${BLUE}[6/6]${NC} Verification:"
obsidian-storage overview

echo ""
echo -e "${GREEN}✓ LVM volume expansion completed successfully!${NC}"
echo ""
echo "New size:"
lvs --units g "$VG_NAME/$LV_NAME"
echo ""
echo "Disk usage:"
df -h "$MOUNT_POINT"
