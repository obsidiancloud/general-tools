# CachyOS Bootstrap Test Version - Minimal implementation for debugging

set -euo pipefail

# Globals
USERNAME="dev"
HOSTNAME_SET="cachyos-dev" 
LAST_STEP="<init>"
LOG_FILE="/tmp/bootstrap-cachyos.$(date +%s).log"

# Logging
/*************  ✨ Windsurf Command ⭐  *************/
# Print a log message to the console and log file
# Format: [INFO timestamp] message
/*******  0cc3a4c0-6d8a-4644-9b4b-707c341939de  *******/
log() { 
    local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    printf "\033[1;34m[INFO %s]\033[0m %s\n" "$timestamp" "$*" | tee -a "$LOG_FILE"
}

err() { 
    local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    printf "\033[1;31m[ERR  %s]\033[0m %s\n" "$timestamp" "$*" | tee -a "$LOG_FILE"
}

warn() { 
    local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    printf "\033[1;33m[WARN %s]\033[0m %s\n" "$timestamp" "$*" | tee -a "$LOG_FILE"
}

banner() {
    echo | tee -a "$LOG_FILE"
    printf "\033[1;35m==== %s ====\033[0m\n" "$1" | tee -a "$LOG_FILE"
    echo | tee -a "$LOG_FILE"
}

# Cleanup
cleanup() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        err "Script failed at step: ${LAST_STEP} with exit code: $exit_code"
        err "Log file: $LOG_FILE"
    fi
    return $exit_code
}

trap cleanup EXIT

# Simple argument parsing
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --username)
                USERNAME="${2:-dev}"
                shift 2
                ;;
            --help|-h)
                echo "Usage: $0 [--username NAME]"
                exit 0
                ;;
            *)
                warn "Unknown argument: $1"
                shift
                ;;
        esac
    done
}

# Basic system check
check_system() {
    LAST_STEP="System check"
    log "Checking system compatibility..."
    
    # Check OS
    if [[ ! -f /etc/os-release ]]; then
        err "/etc/os-release missing"
        exit 1
    fi
    
    local ID="" PRETTY_NAME=""
    source /etc/os-release 2>/dev/null || {
        err "Cannot read /etc/os-release"
        exit 1
    }
    
    log "Detected: ${PRETTY_NAME:-${ID:-Unknown}}"
    
    # Check if Arch-based
    if [[ "${ID:-}" == "cachyos" ]] || [[ "${ID:-}" == "arch" ]] || [[ -f /etc/arch-release ]]; then
        log "✅ Arch-based system confirmed"
    else
        err "❌ Not an Arch-based system"
        exit 1
    fi
    
    # Check pacman
    if ! command -v pacman >/dev/null 2>&1; then
        err "pacman not found"
        exit 1
    fi
    
    log "✅ System check passed"
}

# Test basic operations
test_operations() {
    LAST_STEP="Test operations"
    
    banner "Testing Basic Operations"
    
    # Test sudo
    log "Testing sudo access..."
    if sudo -v 2>/dev/null; then
        log "✅ Sudo access confirmed"
    else
        err "❌ Sudo access failed"
        exit 1
    fi
    
    # Test pacman update
    log "Testing pacman update..."
    if sudo pacman -Sy --noconfirm >/dev/null 2>&1; then
        log "✅ Pacman update successful"
    else
        warn "⚠️ Pacman update failed"
    fi
    
    # Test user creation (dry run)
    log "Testing user operations..."
    if id "$USERNAME" >/dev/null 2>&1; then
        log "✅ User $USERNAME already exists"
    else
        log "ℹ️  User $USERNAME would be created"
    fi
}

# Main
main() {
    log "Starting CachyOS Bootstrap Test"
    log "User: $(whoami)"
    log "Log: $LOG_FILE"
    
    parse_args "$@"
    check_system
    test_operations
    
    banner "🎉 Test Completed Successfully!"
    log "System is ready for full bootstrap"
    log "Run full script with: ./bootstrap-cachyos.sh --username $USERNAME"
}

# Entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi