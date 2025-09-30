# Obsidian Cloud - Storage Manager

Production-grade disk management utility for Linux systems with comprehensive safety features and error handling.

## Features

✅ **Disk Overview** - View all physical disks, partitions, and LVM volumes  
✅ **LVM Management** - Display Physical Volumes, Volume Groups, and Logical Volumes  
✅ **Space Analysis** - Analyze disk space usage with top consumers  
✅ **Partition Backup** - Safely backup partition tables before operations  
✅ **Risk Management** - Multi-level risk warnings for dangerous operations  
✅ **Error Handling** - Graceful error handling with detailed messages  
✅ **Production Ready** - Tested on CachyOS/Arch Linux systems  

## Installation

```bash
# Navigate to the tool directory
cd /home/radicaledward/projects/obsidiancloud/repos/general-tools/obsidian-cloud-storage-manager

# Make executable
chmod +x storage_manager.py

# Optional: Create symlink for easy access
sudo ln -s $(pwd)/storage_manager.py /usr/local/bin/obsidian-storage

# Optional: Install to user bin
mkdir -p ~/.local/bin
ln -s $(pwd)/storage_manager.py ~/.local/bin/obsidian-storage
```

## Usage

### Basic Commands

```bash
# Display disk overview
sudo python3 storage_manager.py overview

# Display LVM information
sudo python3 storage_manager.py lvm

# Analyze space usage (default: /)
sudo python3 storage_manager.py analyze

# Analyze specific path
sudo python3 storage_manager.py analyze --path /home

# Backup partition table
sudo python3 storage_manager.py backup --device /dev/sda

# List all backups
python3 storage_manager.py list-backups
```

### Using the Symlink

```bash
# If you created the symlink
sudo obsidian-storage overview
sudo obsidian-storage lvm
sudo obsidian-storage analyze --path /var
```

## Command Reference

### `overview`
Display comprehensive disk overview including:
- Physical disks
- Partitions (mounted/unmounted status)
- LVM volumes
- Usage statistics
- Filesystem types
- Mount points

**Example:**
```bash
sudo python3 storage_manager.py overview
```

### `lvm`
Display LVM configuration:
- Physical Volumes (PVs)
- Volume Groups (VGs)
- Logical Volumes (LVs)
- Size and free space information

**Requires:** Root privileges

**Example:**
```bash
sudo python3 storage_manager.py lvm
```

### `analyze`
Analyze disk space usage for a given path:
- Total/used/free space
- Top 10 space consumers
- Usage percentages

**Options:**
- `--path PATH` - Path to analyze (default: /)

**Example:**
```bash
sudo python3 storage_manager.py analyze --path /home/radicaledward
```

### `backup`
Backup partition table for a device using sfdisk:
- Creates timestamped backup
- Stores in /var/backups/storage-manager (or ~/.storage-manager-backups)
- Required before any partition modifications

**Requires:** Root privileges

**Options:**
- `--device DEVICE` - Device to backup (e.g., /dev/sda)

**Example:**
```bash
sudo python3 storage_manager.py backup --device /dev/sda
```

### `list-backups`
List all partition table backups:
- Filename
- Size
- Creation timestamp
- Full path

**Example:**
```bash
python3 storage_manager.py list-backups
```

## Safety Features

### Risk Levels

The tool implements 5 risk levels for operations:

- **SAFE** - No risk (green)
- **LOW** - Minimal risk (blue)
- **MEDIUM** - Moderate risk, requires confirmation (yellow)
- **HIGH** - High risk, requires explicit confirmation (red)
- **CRITICAL** - Critical risk, requires typing confirmation phrase (red bold)

### Confirmation Mechanisms

**Medium/Low Risk:**
```
Type 'yes' to continue:
```

**High/Critical Risk:**
```
Type 'I UNDERSTAND THE RISKS' to continue:
```

### Automatic Backups

Before any destructive operation, the tool:
1. Automatically backs up partition tables
2. Stores backup with timestamp
3. Displays backup location
4. Aborts if backup fails

## Expanding Partitions

⚠️ **CRITICAL WARNING** ⚠️

The tool provides information and backups but does NOT perform automatic partition resizing for safety reasons.

### Recommended Manual Process

1. **Backup Everything**
   ```bash
   # Backup partition table
   sudo python3 storage_manager.py backup --device /dev/sda
   
   # Backup important data
   rsync -av /source /backup
   ```

2. **Check Current State**
   ```bash
   sudo python3 storage_manager.py overview
   lsblk
   df -h
   ```

3. **For Standard Partitions (ext4)**
   ```bash
   # Unmount partition
   sudo umount /dev/sdaX
   
   # Check filesystem
   sudo e2fsck -f /dev/sdaX
   
   # Use parted or fdisk to resize partition
   sudo parted /dev/sda
   
   # Resize filesystem
   sudo resize2fs /dev/sdaX
   
   # Remount
   sudo mount /dev/sdaX /mount/point
   ```

4. **For LVM Volumes**
   ```bash
   # Check LVM info
   sudo python3 storage_manager.py lvm
   
   # Extend logical volume
   sudo lvextend -L +10G /dev/vg_name/lv_name
   
   # Resize filesystem
   sudo resize2fs /dev/vg_name/lv_name
   ```

5. **For Btrfs Filesystems**
   ```bash
   # Btrfs can resize while mounted
   sudo btrfs filesystem resize +10G /mount/point
   ```

## Error Handling

The tool handles errors gracefully:

- **Command Not Found** - Checks if required tools are installed
- **Permission Denied** - Clearly indicates when root is required
- **Invalid Device** - Validates device exists before operations
- **JSON Parse Errors** - Handles malformed command output
- **File System Errors** - Catches and reports filesystem issues

## Dependencies

### Required
- Python 3.6+
- `lsblk` - Disk information
- `df` - Disk usage
- `du` - Directory usage

### Optional (for full functionality)
- `sfdisk` - Partition table backup/restore
- `pvs`, `vgs`, `lvs` - LVM management (lvm2 package)
- `e2fsck`, `resize2fs` - ext2/3/4 filesystem operations
- `parted` - Partition manipulation
- `smartctl` - SMART disk health (smartmontools package)

### Installing Missing Tools

**Arch/CachyOS:**
```bash
sudo pacman -S lvm2 parted smartmontools
```

**Debian/Ubuntu:**
```bash
sudo apt install lvm2 parted smartmontools
```

**RHEL/Fedora:**
```bash
sudo dnf install lvm2 parted smartmontools
```

## Backup Directory

Backups are stored in (in order of preference):
1. `/var/backups/storage-manager` (if writable)
2. `~/.storage-manager-backups` (fallback)

## Common Use Cases

### Scenario: Running Out of Space

```bash
# 1. Check current usage
sudo python3 storage_manager.py overview

# 2. Analyze what's using space
sudo python3 storage_manager.py analyze --path /

# 3. Check specific directories
sudo python3 storage_manager.py analyze --path /home
sudo python3 storage_manager.py analyze --path /var

# 4. Find large files
sudo find / -type f -size +1G -exec ls -lh {} \; 2>/dev/null

# 5. Clean package cache (Arch)
sudo pacman -Sc
```

### Scenario: Expanding Partition with Free Space

```bash
# 1. View current layout
sudo python3 storage_manager.py overview

# 2. Backup partition table
sudo python3 storage_manager.py backup --device /dev/sda

# 3. Check LVM (if using LVM)
sudo python3 storage_manager.py lvm

# 4. Perform expansion (manual steps based on your setup)
# See "Expanding Partitions" section above
```

### Scenario: Moving to Larger Disk

```bash
# 1. Backup current partition table
sudo python3 storage_manager.py backup --device /dev/sda

# 2. Clone disk
sudo dd if=/dev/sda of=/dev/sdb bs=64K conv=noerror,sync status=progress

# 3. Verify new disk
sudo python3 storage_manager.py overview

# 4. Extend partitions on new disk
# Use parted/fdisk + resize2fs
```

## Troubleshooting

### "Command not found" errors
Install missing packages:
```bash
sudo pacman -S lvm2 parted util-linux
```

### Permission denied
Most operations require root:
```bash
sudo python3 storage_manager.py <command>
```

### LVM commands fail
Ensure LVM kernel modules are loaded:
```bash
sudo modprobe dm-mod
sudo systemctl start lvm2-lvmetad
```

### Backup directory not accessible
The tool will fallback to `~/.storage-manager-backups` automatically

## Development

### Project Structure
```
obsidian-cloud-storage-manager/
├── storage_manager.py       # Main application
├── README.md                # Documentation
├── examples/                # Example usage scripts
└── tests/                   # Test suite (future)
```

### Contributing

When adding features:
1. Follow existing error handling patterns
2. Add appropriate risk levels
3. Implement confirmations for dangerous operations
4. Update documentation
5. Test on multiple Linux distributions

## License

Proprietary - Obsidian Cloud
For internal use and authorized clients only.

## Support

For issues or questions:
- GitHub Issues: obsidiancloud/general-tools
- Email: support@obsidiancloud.io

## Version History

### v1.0.0 (2025-09-30)
- Initial production release
- Disk overview functionality
- LVM information display
- Space usage analysis
- Partition table backup
- Multi-level risk management
- Comprehensive error handling
- Production-grade safety features
