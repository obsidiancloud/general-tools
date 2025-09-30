# Usage Guide

## Basic Usage

### Starting the Service

The service starts automatically on login after installation. To manually control it:

```bash
# Start
systemctl --user start priority-manager

# Stop
systemctl --user stop priority-manager

# Restart
systemctl --user restart priority-manager

# Check status
systemctl --user status priority-manager
```

### Viewing Current Priorities

```bash
# Visual dashboard
~/.local/bin/priority-dashboard.sh

# Text-based status
~/.local/bin/priority-manager.sh status

# Watch live updates
watch -c -n 5 ~/.local/bin/priority-dashboard.sh
```

### Emergency Priority Boost

If your critical application is struggling right now:

```bash
# With sudo (recommended)
sudo ~/.local/bin/boost-now.sh

# Without sudo (limited)
~/.local/bin/boost-now.sh
```

## Configuration

### Customizing Applications

Edit `~/.local/bin/priority-manager.sh`:

```bash
# Applications to prioritize (highest priority)
CRITICAL_APPS=("your-app" "another-app")

# Applications to deprioritize (lowest priority)
DEPRIORITIZE_APPS=("browser" "email")
```

After editing, restart the service:

```bash
systemctl --user restart priority-manager
```

### Adjusting Priority Levels

Edit `~/.local/bin/priority-manager.sh`:

```bash
# CPU priority (-20 = highest, 19 = lowest)
CRITICAL_NICE=-20

# I/O priority (1 = realtime, 2 = best-effort, 3 = idle)
CRITICAL_IONICE_CLASS=1

# OOM protection (-1000 = maximum protection, 1000 = first to kill)
CRITICAL_OOM_SCORE=-1000
```

### Changing Check Interval

Edit `~/.local/bin/priority-manager.sh`:

```bash
# Check every 30 seconds (default)
CHECK_INTERVAL=30

# Or check more frequently
CHECK_INTERVAL=15

# Or less frequently
CHECK_INTERVAL=60
```

## Monitoring

### View Logs

```bash
# Live logs from systemd
journalctl --user -u priority-manager -f

# Application logs
tail -f ~/.local/var/log/priority-manager.log

# Last 50 entries
journalctl --user -u priority-manager -n 50
```

### Check Process Priorities

```bash
# Using priority manager
~/.local/bin/priority-manager.sh status

# Using system tools
ps -eo pid,ni,comm | grep your-app
ionice -p <pid>
cat /proc/<pid>/oom_score_adj
```

## Advanced Usage

### Running Manually

```bash
# Run once and exit
~/.local/bin/priority-manager.sh oneshot

# Run continuously (foreground)
~/.local/bin/priority-manager.sh monitor

# With sudo for full control
sudo ~/.local/bin/priority-manager.sh oneshot
```

### Customizing the Dashboard

Edit `~/.local/bin/priority-dashboard.sh` to add/remove applications from the display:

```bash
# Critical Applications section
show_process_info "your-app" "critical"

# Deprioritized Applications section
show_process_info "browser" "deprioritized"
```

### Integration with Other Tools

#### Launch Applications with Priority

Create a wrapper script:

```bash
#!/bin/bash
# Launch app with priority boost
~/.local/bin/boost-now.sh
/path/to/your/application "$@"
```

#### Desktop Entry

Create a `.desktop` file with priority boost:

```ini
[Desktop Entry]
Name=Your App (High Priority)
Exec=sh -c '~/.local/bin/boost-now.sh && /path/to/app'
Type=Application
```

## Best Practices

### 1. Start Conservative

Begin with a small number of critical applications:

```bash
CRITICAL_APPS=("your-main-app")
DEPRIORITIZE_APPS=()
```

Gradually add more as needed.

### 2. Monitor System Impact

Check system resources regularly:

```bash
htop
~/.local/bin/priority-dashboard.sh
```

### 3. Use Specific Process Names

Instead of generic names like "python", use specific application names:

```bash
# Bad
CRITICAL_APPS=("python")

# Good
CRITICAL_APPS=("jupyter-notebook" "pycharm")
```

### 4. Don't Deprioritize System Services

Avoid deprioritizing critical system processes:

```bash
# Bad
DEPRIORITIZE_APPS=("systemd" "dbus" "pulseaudio")

# Good
DEPRIORITIZE_APPS=("chrome" "firefox" "slack")
```

### 5. Test Changes

After configuration changes:

```bash
# Restart service
systemctl --user restart priority-manager

# Check status
~/.local/bin/priority-manager.sh status

# Monitor for issues
journalctl --user -u priority-manager -f
```

## Common Workflows

### Development Workflow

```bash
# 1. Configure for development
CRITICAL_APPS=("code" "docker" "node")
DEPRIORITIZE_APPS=("chrome" "slack")

# 2. Restart service
systemctl --user restart priority-manager

# 3. Verify
~/.local/bin/priority-dashboard.sh
```

### Gaming Workflow

```bash
# 1. Before gaming session
sudo ~/.local/bin/boost-now.sh

# 2. Launch game
steam

# 3. Monitor performance
~/.local/bin/priority-dashboard.sh
```

### Content Creation Workflow

```bash
# 1. Configure for rendering
CRITICAL_APPS=("blender" "davinci-resolve")
DEPRIORITIZE_APPS=("chrome" "discord")

# 2. Start render
# 3. Monitor in another terminal
watch -c -n 5 ~/.local/bin/priority-dashboard.sh
```

## Troubleshooting

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for detailed troubleshooting steps.

Quick checks:

```bash
# Is service running?
systemctl --user is-active priority-manager

# Any errors?
journalctl --user -u priority-manager -n 20

# Are priorities being set?
~/.local/bin/priority-manager.sh status
```
