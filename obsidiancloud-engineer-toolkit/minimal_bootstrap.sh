#!/usr/bin/env bash
# Minimal bootstrap script for debugging

set -euo pipefail

# Basic logging
LOG_FILE="/tmp/bootstrap-minimal.$(date +%s).log"
log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"; }
err() { echo "[ERROR] $*" | tee -a "$LOG_FILE" >&2; }

# Trap for cleanup
cleanup() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        err "Script failed with exit code: $exit_code"
        err "Check log: $LOG_FILE"
    fi
    exit $exit_code
}
trap cleanup EXIT

log "Starting minimal bootstrap test"

# Basic system check
log "Checking system..."
if [[ ! -f /etc/os-release ]]; then
    err "/etc/os-release not found"
    exit 1
fi

# Safe sourcing
ID=""
ID_LIKE=""
PRETTY_NAME=""

# Try to source safely
if source /etc/os-release 2>/dev/null; then
    log "Sourced /etc/os-release successfully"
else
    err "Failed to source /etc/os-release"
    exit 1
fi

log "Distribution: ${PRETTY_NAME:-${ID:-Unknown}}"

# Check for Arch-based system
if [[ "${ID:-}" == "arch" ]] || \
   [[ "${ID:-}" == "cachyos" ]] || \
   [[ "${ID:-}" == "manjaro" ]] || \
   [[ "${ID_LIKE:-}" == *"arch"* ]] || \
   [[ -f /etc/arch-release ]]; then
    log "✅ Arch-based system detected"
else
    err "❌ Not an Arch-based system (ID: ${ID:-unknown}, ID_LIKE: ${ID_LIKE:-unknown})"
    exit 1
fi

# Check network
log "Testing network connectivity..."
if timeout 10 ping -c 1 8.8.8.8 >/dev/null 2>&1; then
    log "✅ Network connectivity OK"
else
    err "❌ Network connectivity failed"
    exit 1
fi

# Check pacman
log "Checking package manager..."
if command -v pacman >/dev/null 2>&1; then
    log "✅ pacman available"
else
    err "❌ pacman not found"
    exit 1
fi

# Check sudo
log "Checking sudo access..."
if sudo -n true 2>/dev/null || sudo -v 2>/dev/null; then
    log "✅ sudo access OK"
else
    err "❌ sudo access failed"
    exit 1
fi

# Check disk space (need at least 2GB)
log "Checking disk space..."
available_kb=$(df / | awk 'NR==2 {print $4}')
available_gb=$((available_kb / 1024 / 1024))
if [[ $available_kb -gt 2097152 ]]; then  # 2GB in KB
    log "✅ Disk space OK (${available_gb}GB available)"
else
    err "❌ Insufficient disk space (${available_gb}GB available, need 2GB+)"
    exit 1
fi

log "🎉 All basic checks passed!"
log "System is ready for full bootstrap"
log "Log saved to: $LOG_FILE"

# Test a basic pacman operation
log "Testing pacman update (this may take a moment)..."
if sudo pacman -Sy --noconfirm >/dev/null 2>&1; then
    log "✅ pacman update successful"
else
    err "⚠️  pacman update failed (may need manual intervention)"
fi

log "Minimal bootstrap test completed successfully"