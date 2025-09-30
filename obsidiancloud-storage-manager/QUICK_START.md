# Quick Start Guide - Obsidian Cloud Storage Manager

## Installation (30 seconds)

```bash
cd /home/radicaledward/projects/obsidiancloud/repos/general-tools/obsidian-cloud-storage-manager
chmod +x install.sh
./install.sh
```

If you want system-wide installation:
```bash
sudo ./install.sh system
```

## First Steps

### 1. Check Your Disk Situation

```bash
sudo obsidian-storage overview
```

This shows you:
- All your disks and partitions
- What's mounted where
- How much space is used/available
- LVM volumes if you have them

### 2. Find What's Eating Your Space

```bash
sudo obsidian-storage analyze --path /
```

This will show the top 10 directories using the most space.

Check specific directories:
```bash
sudo obsidian-storage analyze --path /home
sudo obsidian-storage analyze --path /var
sudo obsidian-storage analyze --path /home/radicaledward
```

### 3. Clean Up Space

Run the automated cleanup script:
```bash
sudo ./examples/space-cleanup.sh
```

This safely cleans:
- Package manager caches
- Old logs
- Docker images (if using Docker)
- Browser caches
- Temporary files

## Common Scenarios

### "My root partition is full!"

```bash
# 1. See what's using space
sudo obsidian-storage overview
sudo obsidian-storage analyze --path /

# 2. Clean up
sudo ./examples/space-cleanup.sh

# 3. Find large files
sudo find / -type f -size +1G -exec ls -lh {} \; 2>/dev/null | head -20

# 4. Check logs
sudo du -sh /var/log/*
sudo journalctl --vacuum-time=3d  # Keep only 3 days of logs
```

### "I need to expand my partition"

**⚠️ CRITICAL: Backup everything first!**

```bash
# 1. Backup partition table
sudo obsidian-storage backup --device /dev/sda

# 2. Check if you're using LVM
sudo obsidian-storage lvm

# If using LVM (easier):
sudo ./examples/expand-lvm-volume.sh

# If NOT using LVM:
# - Boot from live USB
# - Use GParted to resize
# - Or follow manual steps in README.md
```

### "Check if my disk is healthy"

```bash
# Install smartmontools if not present
sudo pacman -S smartmontools

# Check SMART status
sudo smartctl -H /dev/sda
sudo smartctl -a /dev/sda  # Detailed info
```

### "I want to see my backups"

```bash
obsidian-storage list-backups
```

## Pro Tips

### Alias for Quick Access

Add to your `.zshrc`:
```bash
alias dsm='sudo obsidian-storage'
alias dso='sudo obsidian-storage overview'
alias dsa='sudo obsidian-storage analyze'
```

Then use:
```bash
dso           # Quick overview
dsa --path /  # Quick analysis
```

### Regular Maintenance

Create a monthly cron job:
```bash
sudo crontab -e
```

Add:
```cron
# Run cleanup first Sunday of each month at 3 AM
0 3 1-7 * 0 /home/radicaledward/projects/obsidiancloud/repos/general-tools/obsidian-cloud-storage-manager/examples/space-cleanup.sh
```

### Monitor Disk Usage

Watch disk usage in real-time:
```bash
watch -n 5 'df -h | grep -E "^/dev/(sd|nvme)"'
```

### Find Recently Modified Large Files

```bash
# Files modified in last 7 days > 100MB
find /home -type f -mtime -7 -size +100M -exec ls -lh {} \; 2>/dev/null
```

## Understanding Your Disk Layout

### Scenario 1: Simple Partitioning
```
/dev/sda          500GB disk
├─/dev/sda1       512MB  /boot
├─/dev/sda2       50GB   /
└─/dev/sda3       449GB  /home
```
To expand: Use GParted or fdisk + resize2fs

### Scenario 2: LVM (Recommended)
```
/dev/sda                500GB disk
├─/dev/sda1             512MB  /boot
└─/dev/sda2             499GB  (LVM PV)
   └─vg_main            499GB  (VG)
      ├─lv_root         50GB   /
      ├─lv_home         200GB  /home
      └─lv_data         200GB  /data
      (Free: 49GB)
```
To expand: Use lvextend + resize2fs (easy!)

### Scenario 3: Btrfs Subvolumes
```
/dev/sda          500GB disk
├─/dev/sda1       512MB  /boot
└─/dev/sda2       499GB  / (btrfs)
   ├─@rootfs      /
   ├─@home        /home
   └─@snapshots   /.snapshots
```
To expand: btrfs filesystem resize

## Emergency: "Disk Full, System Won't Boot"

1. **Boot from live USB/rescue mode**

2. **Mount your root partition:**
   ```bash
   mkdir /mnt/rescue
   mount /dev/sdaX /mnt/rescue  # Replace X with your root partition
   ```

3. **Clear space:**
   ```bash
   # Clear package cache
   rm -rf /mnt/rescue/var/cache/pacman/pkg/*
   
   # Clear logs
   rm -rf /mnt/rescue/var/log/journal/*
   
   # Clear tmp
   rm -rf /mnt/rescue/tmp/*
   ```

4. **Reboot:**
   ```bash
   umount /mnt/rescue
   reboot
   ```

## Troubleshooting

### "obsidian-storage: command not found"

After installation, either:
```bash
# Restart your shell
exec zsh

# Or source your profile
source ~/.zshrc
```

### "Permission denied"

Use sudo:
```bash
sudo obsidian-storage overview
```

### "pvs: command not found"

Install LVM tools:
```bash
sudo pacman -S lvm2
```

## Learn More

- Full documentation: `README.md`
- Example scripts: `examples/` directory
- GitHub: obsidiancloud/general-tools

## Support

- Issues: GitHub Issues
- Email: support@obsidiancloud.io
- Documentation: Full README.md in this directory
