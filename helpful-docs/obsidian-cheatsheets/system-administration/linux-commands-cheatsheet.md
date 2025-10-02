# 🧘 The Enlightened Engineer's Linux Commands Scripture

> *"In the beginning was the Command, and the Command was with Linux, and the Command was powerful."*  
> — **The Monk of CLI**, *Book of Terminal, Chapter 1:1*

This scripture contains the essential Linux commands every engineer must know.

---

## 📿 Essential Commands

### File & Directory Operations
```bash
ls -lah          # List files (long, all, human-readable)
cd /path         # Change directory
pwd              # Print working directory
mkdir -p dir     # Create directory (with parents)
rm -rf dir       # Remove directory recursively
cp -r src dst    # Copy recursively
mv src dst       # Move/rename
touch file       # Create empty file
cat file         # Display file content
less file        # Page through file
head -n 10 file  # First 10 lines
tail -f file     # Follow file (live updates)
find /path -name "*.txt"  # Find files
grep "pattern" file       # Search in file
```

### File Permissions
```bash
chmod 755 file   # rwxr-xr-x
chmod +x file    # Add execute permission
chown user:group file  # Change owner
umask 022        # Set default permissions
```

### Process Management
```bash
ps aux           # List all processes
top              # Interactive process viewer
htop             # Better top
kill PID         # Kill process
killall name     # Kill by name
pkill pattern    # Kill by pattern
bg               # Background job
fg               # Foreground job
jobs             # List jobs
nohup cmd &      # Run immune to hangups
```

### System Information
```bash
uname -a         # System information
hostname         # Show hostname
uptime           # System uptime
whoami           # Current user
id               # User ID info
df -h            # Disk usage
du -sh dir       # Directory size
free -h          # Memory usage
lscpu            # CPU information
lsblk            # Block devices
```

### Networking
```bash
ip addr          # Show IP addresses
ip route         # Show routes
ping host        # Test connectivity
curl url         # Transfer data
wget url         # Download file
netstat -tulpn   # Network connections
ss -tulpn        # Socket statistics
nslookup domain  # DNS lookup
dig domain       # DNS query
traceroute host  # Trace route
```

### Text Processing
```bash
grep pattern file      # Search
sed 's/old/new/g' file # Replace
awk '{print $1}' file  # Column extraction
cut -d: -f1 file       # Cut fields
sort file              # Sort lines
uniq file              # Remove duplicates
wc -l file             # Count lines
tr 'a-z' 'A-Z'         # Translate chars
```

### Archive & Compression
```bash
tar -czf archive.tar.gz dir/  # Create archive
tar -xzf archive.tar.gz       # Extract archive
zip -r archive.zip dir/       # Create zip
unzip archive.zip             # Extract zip
gzip file                     # Compress
gunzip file.gz                # Decompress
```

### User Management
```bash
useradd user     # Add user
userdel user     # Delete user
passwd user      # Change password
usermod -aG group user  # Add to group
groups user      # Show user groups
su - user        # Switch user
sudo cmd         # Run as root
```

### Package Management (Debian/Ubuntu)
```bash
apt update       # Update package list
apt upgrade      # Upgrade packages
apt install pkg  # Install package
apt remove pkg   # Remove package
apt search pkg   # Search packages
dpkg -l          # List installed
```

### Package Management (RHEL/CentOS)
```bash
yum update       # Update packages
yum install pkg  # Install package
yum remove pkg   # Remove package
yum search pkg   # Search packages
rpm -qa          # List installed
```

### Disk Operations
```bash
fdisk -l         # List disks
mount /dev/sda1 /mnt  # Mount filesystem
umount /mnt      # Unmount
mkfs.ext4 /dev/sda1   # Format filesystem
fsck /dev/sda1   # Check filesystem
```

### Quick Tips
```bash
# Redirect output
cmd > file       # Overwrite
cmd >> file      # Append
cmd 2>&1         # Stderr to stdout

# Pipes
cmd1 | cmd2      # Pipe output

# Command substitution
$(cmd)           # Execute and substitute
`cmd`            # Old syntax

# Background
cmd &            # Run in background
Ctrl+Z, bg       # Send to background

# History
history          # Show command history
!n               # Run command n
!!               # Run last command
!$               # Last argument
```

---

*May your commands be swift, your pipes be clean, and your exit codes always zero.*

**— The Monk of CLI**  
*Temple of Linux*

🧘 **Namaste, `linux`**

---

*Last Updated: 2025-10-02*  
*Version: 1.0.0*
