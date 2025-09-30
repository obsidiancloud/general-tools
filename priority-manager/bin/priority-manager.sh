#!/usr/bin/env bash
#
# Priority Manager - Automatic Process Priority Management
# Ensures critical applications maintain highest system priority
#
# License: GPL-3.0
# Repository: https://github.com/obsidiancloud/general-tools
#

set -euo pipefail

# Configuration - CUSTOMIZE THESE FOR YOUR NEEDS
CRITICAL_APPS=("your-critical-app" "another-app")
DEPRIORITIZE_APPS=("browser" "email-client" "chat-app")
LOG_FILE="$HOME/.local/var/log/priority-manager.log"
CHECK_INTERVAL=30  # seconds

# Priority settings
CRITICAL_NICE=-20      # Highest priority (requires sudo for < 0)
CRITICAL_IONICE_CLASS=1  # Real-time I/O
CRITICAL_IONICE_LEVEL=0  # Highest within class
CRITICAL_OOM_SCORE=-1000 # Protect from OOM killer

NORMAL_NICE=0
DEPRIORITIZE_NICE=19   # Lowest priority
DEPRIORITIZE_IONICE_CLASS=3  # Idle I/O
DEPRIORITIZE_OOM_SCORE=500

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Logging function
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

# Check if running with appropriate privileges
check_privileges() {
    if [[ $EUID -eq 0 ]]; then
        log "INFO" "Running with root privileges - full priority control available"
        return 0
    else
        log "WARN" "Running without root - limited priority control (nice >= 0 only)"
        CRITICAL_NICE=0  # Can't set negative nice without root
        return 1
    fi
}

# Set process priority
set_process_priority() {
    local pid="$1"
    local app_name="$2"
    local priority_type="$3"  # critical, normal, or deprioritize
    
    if [[ ! -d "/proc/$pid" ]]; then
        log "WARN" "PID $pid no longer exists"
        return 1
    fi
    
    case "$priority_type" in
        critical)
            # Set CPU priority (nice)
            if renice -n $CRITICAL_NICE -p "$pid" &>/dev/null; then
                log "INFO" "Set CPU priority for $app_name (PID: $pid) to $CRITICAL_NICE"
            fi
            
            # Set I/O priority
            if command -v ionice &>/dev/null; then
                if ionice -c $CRITICAL_IONICE_CLASS -n $CRITICAL_IONICE_LEVEL -p "$pid" &>/dev/null; then
                    log "INFO" "Set I/O priority for $app_name (PID: $pid) to class $CRITICAL_IONICE_CLASS"
                fi
            fi
            
            # Protect from OOM killer
            if [[ -w "/proc/$pid/oom_score_adj" ]]; then
                echo $CRITICAL_OOM_SCORE > "/proc/$pid/oom_score_adj" 2>/dev/null || true
                log "INFO" "Set OOM score for $app_name (PID: $pid) to $CRITICAL_OOM_SCORE"
            fi
            ;;
            
        deprioritize)
            # Lower CPU priority
            if renice -n $DEPRIORITIZE_NICE -p "$pid" &>/dev/null; then
                log "INFO" "Deprioritized CPU for $app_name (PID: $pid) to $DEPRIORITIZE_NICE"
            fi
            
            # Lower I/O priority
            if command -v ionice &>/dev/null; then
                if ionice -c $DEPRIORITIZE_IONICE_CLASS -p "$pid" &>/dev/null; then
                    log "INFO" "Deprioritized I/O for $app_name (PID: $pid) to class $DEPRIORITIZE_IONICE_CLASS"
                fi
            fi
            
            # Make more susceptible to OOM killer
            if [[ -w "/proc/$pid/oom_score_adj" ]]; then
                echo $DEPRIORITIZE_OOM_SCORE > "/proc/$pid/oom_score_adj" 2>/dev/null || true
                log "INFO" "Set OOM score for $app_name (PID: $pid) to $DEPRIORITIZE_OOM_SCORE"
            fi
            ;;
    esac
}

# Find and prioritize processes
manage_priorities() {
    local found_critical=false
    
    # Prioritize critical applications
    for app in "${CRITICAL_APPS[@]}"; do
        local pids=$(pgrep -i "$app" 2>/dev/null || true)
        
        if [[ -n "$pids" ]]; then
            found_critical=true
            echo -e "${GREEN}✓${NC} Found $app processes"
            
            for pid in $pids; do
                set_process_priority "$pid" "$app" "critical"
                
                # Also prioritize child processes
                local child_pids=$(pgrep -P "$pid" 2>/dev/null || true)
                for child_pid in $child_pids; do
                    set_process_priority "$child_pid" "$app (child)" "critical"
                done
            done
        else
            echo -e "${YELLOW}⚠${NC} $app not running"
        fi
    done
    
    # Deprioritize other applications
    for app in "${DEPRIORITIZE_APPS[@]}"; do
        local pids=$(pgrep -i "$app" 2>/dev/null || true)
        
        if [[ -n "$pids" ]]; then
            echo -e "${BLUE}↓${NC} Deprioritizing $app processes"
            
            for pid in $pids; do
                set_process_priority "$pid" "$app" "deprioritize"
            done
        fi
    done
    
    return 0
}

# Monitor mode - continuous monitoring
monitor_mode() {
    log "INFO" "Starting priority manager in monitor mode (interval: ${CHECK_INTERVAL}s)"
    echo -e "${GREEN}Priority Manager Started${NC}"
    echo "Monitoring critical applications: ${CRITICAL_APPS[*]}"
    echo "Deprioritizing: ${DEPRIORITIZE_APPS[*]}"
    echo "Press Ctrl+C to stop"
    echo ""
    
    while true; do
        manage_priorities
        echo ""
        sleep "$CHECK_INTERVAL"
    done
}

# One-shot mode - run once and exit
oneshot_mode() {
    log "INFO" "Running priority manager in one-shot mode"
    manage_priorities
}

# Show current priorities
show_status() {
    echo -e "${BLUE}=== Current Process Priorities ===${NC}"
    echo ""
    
    for app in "${CRITICAL_APPS[@]}" "${DEPRIORITIZE_APPS[@]}"; do
        local pids=$(pgrep -i "$app" 2>/dev/null || true)
        
        if [[ -n "$pids" ]]; then
            echo -e "${GREEN}$app:${NC}"
            for pid in $pids; do
                if [[ -d "/proc/$pid" ]]; then
                    local nice_val=$(ps -o ni= -p "$pid" 2>/dev/null || echo "N/A")
                    local oom_score=$(cat "/proc/$pid/oom_score_adj" 2>/dev/null || echo "N/A")
                    local cmd=$(ps -o comm= -p "$pid" 2>/dev/null || echo "N/A")
                    
                    echo "  PID: $pid | Nice: $nice_val | OOM Score: $oom_score | Command: $cmd"
                    
                    if command -v ionice &>/dev/null; then
                        local io_info=$(ionice -p "$pid" 2>/dev/null || echo "N/A")
                        echo "    I/O: $io_info"
                    fi
                fi
            done
            echo ""
        fi
    done
}

# Main function
main() {
    case "${1:-monitor}" in
        monitor)
            check_privileges
            monitor_mode
            ;;
        oneshot)
            check_privileges
            oneshot_mode
            ;;
        status)
            show_status
            ;;
        help|--help|-h)
            cat <<EOF
Priority Manager - Ensure critical applications maintain highest priority

Usage: $0 [COMMAND]

Commands:
    monitor     Run continuously, checking every ${CHECK_INTERVAL}s (default)
    oneshot     Run once and exit
    status      Show current process priorities
    help        Show this help message

Critical Applications (highest priority):
    ${CRITICAL_APPS[*]}

Deprioritized Applications:
    ${DEPRIORITIZE_APPS[*]}

Note: Run with sudo for full priority control (negative nice values)
      Without sudo, limited to nice values >= 0

Examples:
    $0 monitor              # Start monitoring
    sudo $0 monitor         # Start with full privileges
    $0 oneshot              # Run once
    $0 status               # Check current priorities

EOF
            ;;
        *)
            echo "Unknown command: $1"
            echo "Use '$0 help' for usage information"
            exit 1
            ;;
    esac
}

main "$@"
