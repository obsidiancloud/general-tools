#!/usr/bin/env bash
# Debug script to identify bootstrap issues

echo "=== System Information ==="
echo "Current user: $(whoami)"
echo "UID: $(id -u)"
echo "Groups: $(groups)"
echo "PWD: $PWD"
echo "Shell: $SHELL"
echo

echo "=== Distribution Check ==="
if [[ -f /etc/os-release ]]; then
    echo "Found /etc/os-release:"
    cat /etc/os-release | head -10
    echo
    
    # Source the file safely
    ID=""
    ID_LIKE=""
    PRETTY_NAME=""
    source /etc/os-release 2>/dev/null
    
    echo "Parsed values:"
    echo "ID: ${ID:-not set}"
    echo "ID_LIKE: ${ID_LIKE:-not set}"  
    echo "PRETTY_NAME: ${PRETTY_NAME:-not set}"
    echo
else
    echo "ERROR: /etc/os-release not found"
fi

if [[ -f /etc/arch-release ]]; then
    echo "Found /etc/arch-release (Arch Linux marker)"
else
    echo "No /etc/arch-release found"
fi

echo "=== Network Check ==="
if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
    echo "Network connectivity: OK"
else
    echo "Network connectivity: FAILED"
fi

echo "=== Disk Space Check ==="
df -h / | head -2

echo "=== Package Manager Check ==="
if command -v pacman >/dev/null 2>&1; then
    echo "pacman: Available"
    echo "pacman version: $(pacman --version | head -1)"
else
    echo "pacman: NOT AVAILABLE"
fi

echo "=== Permissions Check ==="
if sudo -n true 2>/dev/null; then
    echo "Sudo: Available (cached credentials)"
elif sudo -v 2>/dev/null; then
    echo "Sudo: Available (prompted for password)"
else
    echo "Sudo: NOT AVAILABLE or user not in sudoers"
fi

echo "=== Environment Variables ==="
echo "HOME: $HOME"
echo "USER: $USER" 
echo "PATH: $PATH"

echo "=== Log Test ==="
TEST_LOG="/tmp/bootstrap-test.log"
echo "Test log entry" > "$TEST_LOG" 2>&1
if [[ -f "$TEST_LOG" ]]; then
    echo "Log file creation: OK ($TEST_LOG)"
    rm -f "$TEST_LOG"
else
    echo "Log file creation: FAILED"
fi

echo "=== Exit Code Test ==="
echo "Testing set -euo pipefail behavior..."

# Test function that should work
test_function() {
    echo "Test function executed"
    return 0
}

if test_function; then
    echo "Function execution: OK"
else
    echo "Function execution: FAILED"
fi

echo "=== Debug Complete ==="