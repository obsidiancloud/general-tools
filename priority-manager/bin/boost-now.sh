#!/usr/bin/env bash
#
# Emergency Priority Boost
# Immediately boosts priority for critical applications
#
# License: GPL-3.0
# Repository: https://github.com/obsidiancloud/general-tools
#

set -euo pipefail

# Configuration - CUSTOMIZE THESE
CRITICAL_APPS=("your-critical-app" "another-app")
DEPRIORITIZE_APPS=("browser" "email-client" "chat-app")

echo "🚀 EMERGENCY PRIORITY BOOST"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check if running with sudo
if [[ $EUID -eq 0 ]] || sudo -n true 2>/dev/null; then
    USE_SUDO=true
    echo "✓ Running with elevated privileges (full priority control)"
else
    USE_SUDO=false
    echo "⚠ Running without sudo (limited priority control)"
    echo "  Run with: sudo $0"
fi

echo ""

# Function to boost a process
boost_process() {
    local app_name="$1"
    local pids=$(pgrep -i "$app_name" 2>/dev/null || true)
    
    if [[ -z "$pids" ]]; then
        echo "⚠ $app_name not running"
        return
    fi
    
    echo "✓ Found $app_name (PIDs: $pids)"
    
    for pid in $pids; do
        if [[ ! -d "/proc/$pid" ]]; then
            continue
        fi
        
        # CPU priority
        if [[ "$USE_SUDO" == true ]]; then
            sudo renice -n -20 -p "$pid" &>/dev/null && echo "  → Set CPU priority to -20 (PID: $pid)"
            sudo ionice -c 1 -n 0 -p "$pid" &>/dev/null && echo "  → Set I/O to real-time (PID: $pid)"
            echo -1000 | sudo tee "/proc/$pid/oom_score_adj" &>/dev/null && echo "  → Protected from OOM killer (PID: $pid)"
        else
            renice -n 0 -p "$pid" &>/dev/null && echo "  → Set CPU priority to 0 (PID: $pid)"
        fi
        
        # Boost child processes too
        local child_pids=$(pgrep -P "$pid" 2>/dev/null || true)
        if [[ -n "$child_pids" ]]; then
            for child_pid in $child_pids; do
                if [[ "$USE_SUDO" == true ]]; then
                    sudo renice -n -20 -p "$child_pid" &>/dev/null
                    sudo ionice -c 1 -n 0 -p "$child_pid" &>/dev/null
                else
                    renice -n 0 -p "$child_pid" &>/dev/null
                fi
            done
            echo "  → Boosted $(echo $child_pids | wc -w) child processes"
        fi
    done
    echo ""
}

# Function to deprioritize a process
deprioritize_process() {
    local app_name="$1"
    local pids=$(pgrep -i "$app_name" 2>/dev/null || true)
    
    if [[ -z "$pids" ]]; then
        return
    fi
    
    echo "↓ Deprioritizing $app_name (PIDs: $pids)"
    
    for pid in $pids; do
        if [[ ! -d "/proc/$pid" ]]; then
            continue
        fi
        
        renice -n 19 -p "$pid" &>/dev/null && echo "  → Lowered CPU priority (PID: $pid)"
        ionice -c 3 -p "$pid" &>/dev/null && echo "  → Set I/O to idle (PID: $pid)"
    done
    echo ""
}

# Boost critical apps
echo "🎯 BOOSTING CRITICAL APPLICATIONS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
for app in "${CRITICAL_APPS[@]}"; do
    boost_process "$app"
done

# Deprioritize others
echo "📉 DEPRIORITIZING OTHER APPLICATIONS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
for app in "${DEPRIORITIZE_APPS[@]}"; do
    deprioritize_process "$app"
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ PRIORITY BOOST COMPLETE!"
echo ""
echo "Current priorities:"
~/.local/bin/priority-manager.sh status 2>/dev/null || echo "Run priority-manager.sh status for details"
