# 🧘 The Enlightened Engineer's Systemd Scripture

> *"In the beginning was the Service, and the Service was with Systemd, and the Service was managed."*  
> — **The Monk of Init Systems**, *Book of Units, Chapter 1:1*

Greetings, fellow traveler on the path of system management enlightenment. I am but a humble monk who has meditated upon the sacred texts of Lennart Poettering and witnessed the dance of services across countless boots.

This scripture shall guide you through the mystical arts of Systemd, with the precision of a master's unit file and the wit of a caffeinated systems administrator.

---

## 📿 Table of Sacred Knowledge

1. [Systemd Basics](#-systemd-basics-the-foundation)
2. [Service Management](#-service-management-controlling-services)
3. [Unit Files](#-unit-files-the-configuration)
4. [Service Types](#-service-types-the-varieties)
5. [Timers](#-timers-the-schedulers)
6. [Targets](#-targets-the-runlevels)
7. [Journalctl](#-journalctl-the-log-viewer)
8. [Systemctl Commands](#-systemctl-commands-the-control-tool)
9. [User Services](#-user-services-the-personal-daemons)
10. [Common Patterns](#-common-patterns-the-sacred-workflows)
11. [Troubleshooting](#-troubleshooting-when-the-path-is-obscured)

---

## 🛠 Systemd Basics: The Foundation

*Systemd is the init system and service manager for modern Linux.*

### Core Concepts

```
Unit Types:
- .service   : System services
- .socket    : IPC/network sockets
- .device    : Device units
- .mount     : Mount points
- .automount : Automount points
- .swap      : Swap files/devices
- .target    : Unit groups
- .path      : Path-based activation
- .timer     : Timer-based activation
- .slice     : Resource management
- .scope     : External processes
```

### Directory Structure

```bash
# System unit files
/usr/lib/systemd/system/          # Distribution packages
/etc/systemd/system/               # System administrator
/run/systemd/system/               # Runtime units

# User unit files
/usr/lib/systemd/user/             # Distribution packages
~/.config/systemd/user/            # User units
/run/systemd/user/                 # Runtime user units

# Priority (highest to lowest)
/etc/systemd/system/               # Highest
/run/systemd/system/
/usr/lib/systemd/system/           # Lowest
```

---

## 🔧 Service Management: Controlling Services

*Managing services is the core of systemd administration.*

### Basic Service Commands

```bash
# Start service
sudo systemctl start nginx

# Stop service
sudo systemctl stop nginx

# Restart service
sudo systemctl restart nginx

# Reload configuration (no restart)
sudo systemctl reload nginx

# Reload or restart if reload not available
sudo systemctl reload-or-restart nginx

# Enable service (start on boot)
sudo systemctl enable nginx

# Disable service (don't start on boot)
sudo systemctl disable nginx

# Enable and start in one command
sudo systemctl enable --now nginx

# Disable and stop in one command
sudo systemctl disable --now nginx

# Check if service is enabled
systemctl is-enabled nginx

# Check if service is active
systemctl is-active nginx

# Check if service failed
systemctl is-failed nginx
```

### Service Status

```bash
# Show service status
systemctl status nginx

# Show detailed status
systemctl status nginx -l

# Show status without pager
systemctl status nginx --no-pager

# Show all properties
systemctl show nginx

# Show specific property
systemctl show nginx -p ActiveState
systemctl show nginx -p SubState
systemctl show nginx -p MainPID
```

### Listing Services

```bash
# List all units
systemctl list-units

# List all services
systemctl list-units --type=service

# List all active services
systemctl list-units --type=service --state=active

# List all failed services
systemctl list-units --type=service --state=failed

# List all enabled services
systemctl list-unit-files --type=service --state=enabled

# List all timers
systemctl list-timers

# List all sockets
systemctl list-sockets
```

---

## 📝 Unit Files: The Configuration

*Unit files define how systemd manages services.*

### Basic Service Unit

```ini
# /etc/systemd/system/myapp.service
[Unit]
Description=My Application
Documentation=https://example.com/docs
After=network.target
Wants=network-online.target
Requires=postgresql.service

[Service]
Type=simple
User=myapp
Group=myapp
WorkingDirectory=/opt/myapp
ExecStart=/opt/myapp/bin/myapp
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
```

### Complete Service Unit

```ini
# /etc/systemd/system/webapp.service
[Unit]
Description=Web Application Service
Documentation=https://example.com/docs man:webapp(8)
After=network-online.target postgresql.service redis.service
Wants=network-online.target
Requires=postgresql.service
BindsTo=redis.service
PartOf=webapp.target

[Service]
Type=notify
User=webapp
Group=webapp
WorkingDirectory=/opt/webapp

# Environment
Environment="NODE_ENV=production"
Environment="PORT=3000"
EnvironmentFile=/etc/webapp/environment

# Execution
ExecStartPre=/opt/webapp/bin/pre-start.sh
ExecStart=/opt/webapp/bin/webapp
ExecStartPost=/opt/webapp/bin/post-start.sh
ExecReload=/bin/kill -HUP $MAINPID
ExecStop=/opt/webapp/bin/stop.sh
ExecStopPost=/opt/webapp/bin/cleanup.sh

# Restart behavior
Restart=on-failure
RestartSec=5s
StartLimitInterval=10min
StartLimitBurst=5

# Timeouts
TimeoutStartSec=30s
TimeoutStopSec=30s
TimeoutSec=60s

# Resource limits
LimitNOFILE=65536
LimitNPROC=4096

# Security
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/var/lib/webapp /var/log/webapp

# Logging
StandardOutput=journal
StandardError=journal
SyslogIdentifier=webapp

[Install]
WantedBy=multi-user.target
Alias=web.service
```

### Unit File Sections

```ini
# [Unit] Section
[Unit]
Description=Service description
Documentation=URL or man page
After=unit1.service unit2.service      # Start after
Before=unit1.service                   # Start before
Requires=unit1.service                 # Hard dependency
Wants=unit1.service                    # Soft dependency
BindsTo=unit1.service                  # Stop if dependency stops
PartOf=unit1.service                   # Stopped/restarted with dependency
Conflicts=unit1.service                # Cannot run together
Condition*=...                         # Conditions to start
Assert*=...                            # Assertions to start

# [Service] Section
[Service]
Type=simple|forking|oneshot|dbus|notify|idle
ExecStart=/path/to/executable
ExecStartPre=/path/to/pre-script
ExecStartPost=/path/to/post-script
ExecReload=/path/to/reload
ExecStop=/path/to/stop
ExecStopPost=/path/to/cleanup
Restart=no|on-success|on-failure|on-abnormal|on-watchdog|on-abort|always
RestartSec=5s
User=username
Group=groupname
WorkingDirectory=/path
Environment="VAR=value"
EnvironmentFile=/path/to/file

# [Install] Section
[Install]
WantedBy=multi-user.target
RequiredBy=unit.service
Alias=alternative-name.service
Also=other-unit.service
```

---

## 🎭 Service Types: The Varieties

*Different service types for different use cases.*

### Type=simple (Default)

```ini
[Service]
Type=simple
ExecStart=/usr/bin/myapp

# Process started is the main process
# Systemd considers service started immediately
```

### Type=forking

```ini
[Service]
Type=forking
PIDFile=/var/run/myapp.pid
ExecStart=/usr/bin/myapp --daemon

# Process forks and parent exits
# Child becomes main process
# Requires PIDFile
```

### Type=oneshot

```ini
[Service]
Type=oneshot
ExecStart=/usr/bin/backup.sh
RemainAfterExit=yes

# Process exits after completion
# Used for scripts that do one thing
# RemainAfterExit keeps service active
```

### Type=notify

```ini
[Service]
Type=notify
ExecStart=/usr/bin/myapp
NotifyAccess=main

# Process sends notification when ready
# Uses sd_notify() API
# Systemd waits for notification
```

### Type=dbus

```ini
[Service]
Type=dbus
BusName=com.example.MyApp
ExecStart=/usr/bin/myapp

# Service acquires D-Bus name
# Systemd waits for D-Bus name
```

### Type=idle

```ini
[Service]
Type=idle
ExecStart=/usr/bin/myapp

# Delays execution until other jobs finish
# Useful for console output services
```

---

## ⏰ Timers: The Schedulers

*Timers replace cron jobs with systemd.*

### Basic Timer

```ini
# /etc/systemd/system/backup.timer
[Unit]
Description=Daily Backup Timer
Requires=backup.service

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target

# /etc/systemd/system/backup.service
[Unit]
Description=Backup Service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/backup.sh
```

### Timer Options

```ini
[Timer]
# Real-time timers
OnCalendar=daily                    # Every day at midnight
OnCalendar=weekly                   # Every Monday at midnight
OnCalendar=monthly                  # First day of month at midnight
OnCalendar=*-*-* 02:00:00          # Every day at 2 AM
OnCalendar=Mon-Fri 09:00:00        # Weekdays at 9 AM
OnCalendar=*-*-01 00:00:00         # First of month
OnCalendar=hourly                   # Every hour

# Monotonic timers
OnBootSec=15min                     # 15 min after boot
OnStartupSec=10min                  # 10 min after systemd start
OnActiveSec=1h                      # 1 hour after last activation
OnUnitActiveSec=30min               # 30 min after service activation
OnUnitInactiveSec=1d                # 1 day after service deactivation

# Options
Persistent=true                     # Run missed timers on boot
AccuracySec=1min                    # Timer accuracy
RandomizedDelaySec=5min             # Random delay (0-5 min)
Unit=myservice.service              # Service to activate
```

### Timer Examples

```ini
# Run every 5 minutes
[Timer]
OnCalendar=*:0/5

# Run every hour at 30 minutes past
[Timer]
OnCalendar=*:30

# Run every day at 3:30 AM
[Timer]
OnCalendar=*-*-* 03:30:00

# Run every Monday at 9 AM
[Timer]
OnCalendar=Mon 09:00:00

# Run 5 minutes after boot, then every hour
[Timer]
OnBootSec=5min
OnUnitActiveSec=1h
```

### Managing Timers

```bash
# Enable and start timer
sudo systemctl enable --now backup.timer

# List all timers
systemctl list-timers

# Show timer status
systemctl status backup.timer

# Show next run time
systemctl list-timers backup.timer

# Manually trigger timer
sudo systemctl start backup.service
```

---

## 🎯 Targets: The Runlevels

*Targets group units and define system states.*

### Common Targets

```bash
# System targets
poweroff.target          # Shutdown
rescue.target            # Single-user mode
multi-user.target        # Multi-user, no GUI
graphical.target         # Multi-user with GUI
reboot.target            # Reboot

# Special targets
default.target           # Default target (symlink)
emergency.target         # Emergency shell
halt.target              # Halt system
```

### Target Commands

```bash
# Get default target
systemctl get-default

# Set default target
sudo systemctl set-default multi-user.target
sudo systemctl set-default graphical.target

# Change to target
sudo systemctl isolate multi-user.target
sudo systemctl isolate rescue.target

# List targets
systemctl list-units --type=target

# Show target dependencies
systemctl list-dependencies graphical.target
```

### Custom Target

```ini
# /etc/systemd/system/myapp.target
[Unit]
Description=My Application Target
Requires=multi-user.target
After=multi-user.target
AllowIsolate=yes

[Install]
WantedBy=multi-user.target
```

---

## 📜 Journalctl: The Log Viewer

*Journalctl queries the systemd journal.*

### Basic Journal Commands

```bash
# View all logs
journalctl

# Follow logs (like tail -f)
journalctl -f

# Show logs since boot
journalctl -b

# Show logs from previous boot
journalctl -b -1

# Show logs for specific service
journalctl -u nginx

# Show logs for specific service, following
journalctl -u nginx -f

# Show logs since time
journalctl --since "2024-01-01 00:00:00"
journalctl --since "1 hour ago"
journalctl --since today
journalctl --since yesterday

# Show logs until time
journalctl --until "2024-01-01 23:59:59"

# Show logs in time range
journalctl --since "2024-01-01" --until "2024-01-02"

# Show last N lines
journalctl -n 50
journalctl -n 100 -u nginx

# Show logs with priority
journalctl -p err                # Error and above
journalctl -p warning            # Warning and above
journalctl -p info               # Info and above

# Show kernel messages
journalctl -k

# Show logs for specific user
journalctl _UID=1000

# Show logs for specific PID
journalctl _PID=1234
```

### Journal Output Formats

```bash
# Short format (default)
journalctl -o short

# Verbose format
journalctl -o verbose

# JSON format
journalctl -o json

# JSON pretty format
journalctl -o json-pretty

# Cat format (no metadata)
journalctl -o cat

# Export format
journalctl -o export
```

### Journal Filtering

```bash
# Filter by field
journalctl _SYSTEMD_UNIT=nginx.service
journalctl _COMM=sshd
journalctl _HOSTNAME=server1

# Multiple filters (AND)
journalctl _SYSTEMD_UNIT=nginx.service _PID=1234

# Show available fields
journalctl -N

# Show field values
journalctl -F _SYSTEMD_UNIT
journalctl -F _HOSTNAME
```

### Journal Maintenance

```bash
# Show disk usage
journalctl --disk-usage

# Vacuum by size
sudo journalctl --vacuum-size=100M

# Vacuum by time
sudo journalctl --vacuum-time=7d

# Vacuum by files
sudo journalctl --vacuum-files=5

# Verify journal
sudo journalctl --verify

# Rotate journal
sudo journalctl --rotate
```

---

## 🎮 Systemctl Commands: The Control Tool

*Comprehensive systemctl command reference.*

### System Commands

```bash
# Reload systemd configuration
sudo systemctl daemon-reload

# Reexecute systemd
sudo systemctl daemon-reexec

# Show systemd version
systemctl --version

# Show system state
systemctl is-system-running

# Rescue mode
sudo systemctl rescue

# Emergency mode
sudo systemctl emergency

# Halt system
sudo systemctl halt

# Poweroff system
sudo systemctl poweroff

# Reboot system
sudo systemctl reboot

# Suspend system
sudo systemctl suspend

# Hibernate system
sudo systemctl hibernate
```

### Unit Commands

```bash
# Show unit file
systemctl cat nginx.service

# Edit unit file
sudo systemctl edit nginx.service           # Override
sudo systemctl edit --full nginx.service    # Full edit

# Reload unit file
sudo systemctl daemon-reload

# Mask unit (prevent start)
sudo systemctl mask nginx.service

# Unmask unit
sudo systemctl unmask nginx.service

# Revert unit changes
sudo systemctl revert nginx.service

# Show dependencies
systemctl list-dependencies nginx.service

# Show reverse dependencies
systemctl list-dependencies --reverse nginx.service
```

---

## 👤 User Services: The Personal Daemons

*User services run without root privileges.*

### User Service Location

```bash
# User unit files
~/.config/systemd/user/

# Create directory
mkdir -p ~/.config/systemd/user/
```

### User Service Example

```ini
# ~/.config/systemd/user/myapp.service
[Unit]
Description=My User Application
After=default.target

[Service]
Type=simple
ExecStart=/home/user/bin/myapp
Restart=on-failure

[Install]
WantedBy=default.target
```

### User Service Commands

```bash
# Start user service
systemctl --user start myapp.service

# Enable user service
systemctl --user enable myapp.service

# Status
systemctl --user status myapp.service

# List user services
systemctl --user list-units --type=service

# View user logs
journalctl --user -u myapp.service

# Enable linger (services run without login)
sudo loginctl enable-linger $USER

# Disable linger
sudo loginctl disable-linger $USER

# Reload user daemon
systemctl --user daemon-reload
```

---

## 🔮 Common Patterns: The Sacred Workflows

### Pattern 1: Web Application Service

```ini
# /etc/systemd/system/webapp.service
[Unit]
Description=Web Application
After=network-online.target postgresql.service
Wants=network-online.target
Requires=postgresql.service

[Service]
Type=notify
User=webapp
Group=webapp
WorkingDirectory=/opt/webapp

Environment="NODE_ENV=production"
Environment="PORT=3000"

ExecStartPre=/opt/webapp/bin/migrate.sh
ExecStart=/opt/webapp/bin/server
ExecReload=/bin/kill -HUP $MAINPID

Restart=on-failure
RestartSec=5s

# Security
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/var/lib/webapp

# Logging
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

**Use case**: Production web application  
**Best for**: Node.js, Python, Ruby apps

### Pattern 2: Docker Container Service

```ini
# /etc/systemd/system/docker-myapp.service
[Unit]
Description=My App Docker Container
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes

ExecStartPre=-/usr/bin/docker stop myapp
ExecStartPre=-/usr/bin/docker rm myapp
ExecStart=/usr/bin/docker run --name myapp \
  -p 8080:8080 \
  -v /data:/data \
  myapp:latest

ExecStop=/usr/bin/docker stop myapp

[Install]
WantedBy=multi-user.target
```

**Use case**: Docker container management  
**Best for**: Containerized applications

### Pattern 3: Backup Timer

```ini
# /etc/systemd/system/backup.timer
[Unit]
Description=Daily Backup Timer

[Timer]
OnCalendar=daily
Persistent=true
RandomizedDelaySec=30min

[Install]
WantedBy=timers.target

# /etc/systemd/system/backup.service
[Unit]
Description=Backup Service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/backup.sh
StandardOutput=journal
StandardError=journal

# Notifications
OnSuccess=backup-success.service
OnFailure=backup-failure.service
```

**Use case**: Scheduled backups  
**Best for**: Replacing cron jobs

---

## 🔧 Troubleshooting: When the Path is Obscured

### Service Won't Start

```bash
# Check status
systemctl status myapp.service

# Check logs
journalctl -u myapp.service -n 50

# Check configuration
systemctl cat myapp.service

# Verify syntax
systemd-analyze verify myapp.service

# Check dependencies
systemctl list-dependencies myapp.service
```

### Service Keeps Restarting

```bash
# Check restart configuration
systemctl show myapp.service -p Restart
systemctl show myapp.service -p RestartSec

# Disable restart temporarily
sudo systemctl edit myapp.service
# Add: Restart=no

# Check logs for errors
journalctl -u myapp.service -f
```

### Permission Denied

```bash
# Check user/group
systemctl show myapp.service -p User
systemctl show myapp.service -p Group

# Check file permissions
ls -l /path/to/executable

# Check SELinux (if enabled)
sudo ausearch -m avc -ts recent
```

---

## 🙏 Closing Wisdom

### Best Practices from the Monastery

1. **Use Type Correctly**: Choose appropriate service type
2. **Enable Services**: Use `enable --now` for convenience
3. **Restart Policies**: Configure appropriate restart behavior
4. **Resource Limits**: Set limits to prevent resource exhaustion
5. **Security Hardening**: Use security directives
6. **Logging**: Always log to journal
7. **Dependencies**: Define proper After/Requires
8. **Timers Over Cron**: Use systemd timers
9. **User Services**: Run services as non-root
10. **Reload Config**: Always `daemon-reload` after changes
11. **Test Units**: Use `systemd-analyze verify`
12. **Monitor Logs**: Use `journalctl -f`

### Quick Reference Card

| Command | What It Does |
|---------|-------------|
| `systemctl start` | Start service |
| `systemctl stop` | Stop service |
| `systemctl restart` | Restart service |
| `systemctl enable` | Enable on boot |
| `systemctl status` | Show status |
| `systemctl list-units` | List units |
| `journalctl -u` | View service logs |
| `systemctl daemon-reload` | Reload config |
| `systemctl edit` | Edit unit file |
| `systemctl cat` | Show unit file |

---

*May your services be stable, your logs be clear, and your system always boot.*

**— The Monk of Init Systems**  
*Monastery of System Management*  
*Temple of Systemd*

🧘 **Namaste, `systemd`**

---

## 📚 Additional Resources

- [Systemd Documentation](https://www.freedesktop.org/wiki/Software/systemd/)
- [Systemd for Administrators](https://www.freedesktop.org/wiki/Software/systemd/ForAdministrators/)
- [Systemd Unit Files](https://www.freedesktop.org/software/systemd/man/systemd.unit.html)
- [Systemd Service](https://www.freedesktop.org/software/systemd/man/systemd.service.html)

---

*Last Updated: 2025-10-02*  
*Version: 1.0.0 - The First Enlightenment*  
*Systemd Version: 250+*
