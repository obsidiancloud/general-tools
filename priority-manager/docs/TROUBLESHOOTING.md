# Troubleshooting Guide

## Service Issues

### Service Won't Start

**Problem**: `systemctl --user status priority-manager` shows failed or inactive

**Solutions**:
```bash
# Check for errors
journalctl --user -u priority-manager -n 50

# Reload systemd
systemctl --user daemon-reload

# Restart service
systemctl --user restart priority-manager

# Check script permissions
chmod +x ~/.local/bin/priority-manager.sh
```

### Service Starts But Doesn't Work

**Problem**: Service is running but priorities aren't being set

**Solutions**:
1. Check if application names are correct:
   ```bash
   ps aux | grep your-app-name
   ```

2. Verify the script can find processes:
   ```bash
   ~/.local/bin/priority-manager.sh status
   ```

3. Check logs for errors:
   ```bash
   tail -f ~/.local/var/log/priority-manager.log
   ```

## Priority Issues

### Can't Set Negative Nice Values

**Problem**: Priorities limited to 0 or higher

**Solution**: Install sudoers configuration:
```bash
sudo cp /path/to/priority-manager/sudoers/priority-manager.conf /etc/sudoers.d/priority-manager
sudo chmod 440 /etc/sudoers.d/priority-manager
sudo sed -i "s/USERNAME/$(whoami)/g" /etc/sudoers.d/priority-manager
```

### Priorities Reset After Reboot

**Problem**: Priorities don't persist after system restart

**Solution**: Ensure service is enabled:
```bash
systemctl --user enable priority-manager
systemctl --user is-enabled priority-manager
```

### Application Still Slow

**Problem**: Application is prioritized but still performs poorly

**Troubleshooting**:
1. Verify priority is actually set:
   ```bash
   ~/.local/bin/priority-manager.sh status
   ```

2. Check system resources:
   ```bash
   htop
   free -h
   ```

3. Run emergency boost:
   ```bash
   sudo ~/.local/bin/boost-now.sh
   ```

4. Check if other resource constraints exist (RAM, disk I/O)

## Configuration Issues

### Wrong Process Name

**Problem**: Script can't find the application

**Solution**:
1. Find the correct process name:
   ```bash
   ps aux | grep -i app-name
   pgrep -l app-name
   ```

2. Update the configuration in `~/.local/bin/priority-manager.sh`

3. Restart service:
   ```bash
   systemctl --user restart priority-manager
   ```

### Multiple Applications with Similar Names

**Problem**: Script matches wrong processes

**Solution**: Use more specific process names or modify the script to use full path matching

## Permission Issues

### Permission Denied Errors

**Problem**: Script can't modify priorities

**Solutions**:
1. For negative nice values, install sudoers rule (see above)

2. For OOM score adjustment:
   ```bash
   # Check if you can write to oom_score_adj
   echo 0 > /proc/$$/oom_score_adj
   ```

3. Run with sudo for testing:
   ```bash
   sudo ~/.local/bin/priority-manager.sh oneshot
   ```

## Performance Issues

### High CPU Usage from Priority Manager

**Problem**: Priority manager itself uses too much CPU

**Solutions**:
1. Increase check interval in `~/.local/bin/priority-manager.sh`:
   ```bash
   CHECK_INTERVAL=60  # Check every 60 seconds instead of 30
   ```

2. Reduce number of monitored applications

3. Check for script errors in logs

### System Instability

**Problem**: System becomes unstable after installation

**Solutions**:
1. Stop the service immediately:
   ```bash
   systemctl --user stop priority-manager
   ```

2. Review configuration - ensure you're not deprioritizing critical system services

3. Adjust priority values to be less aggressive

## Logging Issues

### No Log File Created

**Problem**: Log file doesn't exist at `~/.local/var/log/priority-manager.log`

**Solution**:
```bash
# Create log directory
mkdir -p ~/.local/var/log

# Restart service
systemctl --user restart priority-manager
```

### Log File Too Large

**Problem**: Log file grows too large

**Solution**: Set up log rotation:
```bash
# Create logrotate config
cat > ~/.config/logrotate.conf << 'EOF'
~/.local/var/log/priority-manager.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
}
EOF

# Add to crontab
crontab -e
# Add: 0 0 * * * /usr/bin/logrotate ~/.config/logrotate.conf
```

## Uninstallation Issues

### Service Won't Stop

**Problem**: Can't stop the service

**Solution**:
```bash
# Force stop
systemctl --user kill priority-manager

# Disable
systemctl --user disable priority-manager

# Remove service file
rm ~/.config/systemd/user/priority-manager.service

# Reload
systemctl --user daemon-reload
```

## Getting Help

If you're still experiencing issues:

1. Check logs:
   ```bash
   journalctl --user -u priority-manager -n 100
   tail -n 100 ~/.local/var/log/priority-manager.log
   ```

2. Run in debug mode:
   ```bash
   bash -x ~/.local/bin/priority-manager.sh oneshot
   ```

3. Check system compatibility:
   - Linux kernel with nice/ionice support
   - systemd installed and running
   - User has permission to modify process priorities

4. Open an issue on the repository with:
   - Your Linux distribution and version
   - Output of `systemctl --user status priority-manager`
   - Relevant log entries
   - Steps to reproduce the issue
