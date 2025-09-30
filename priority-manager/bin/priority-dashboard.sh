#!/usr/bin/env bash
#
# Priority Dashboard - Visual status display
#
# License: GPL-3.0
# Repository: https://github.com/obsidiancloud/general-tools
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

clear

echo -e "${BOLD}${CYAN}"
echo "╔════════════════════════════════════════════════════════════════════╗"
echo "║              PRIORITY MANAGER DASHBOARD                           ║"
echo "╚════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check service status
echo -e "${BOLD}${BLUE}📊 Service Status${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if systemctl --user is-active priority-manager.service &>/dev/null; then
    echo -e "${GREEN}✓${NC} Priority Manager Service: ${GREEN}RUNNING${NC}"
    
    # Get service uptime
    UPTIME=$(systemctl --user show priority-manager.service --property=ActiveEnterTimestamp --value)
    echo -e "  Started: ${CYAN}$UPTIME${NC}"
else
    echo -e "${RED}✗${NC} Priority Manager Service: ${RED}NOT RUNNING${NC}"
    echo -e "  ${YELLOW}Run: systemctl --user start priority-manager${NC}"
fi

echo ""

# Check sudoers
echo -e "${BOLD}${BLUE}🔐 Privilege Level${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [[ -f "/etc/sudoers.d/priority-manager" ]]; then
    echo -e "${GREEN}✓${NC} Sudoers Rule: ${GREEN}INSTALLED${NC} (Maximum priority control)"
else
    echo -e "${YELLOW}⚠${NC} Sudoers Rule: ${YELLOW}NOT INSTALLED${NC} (Limited priority control)"
    echo -e "  ${CYAN}Install: sudo cp ~/priority-manager-sudoers.conf /etc/sudoers.d/priority-manager${NC}"
fi

echo ""

# Function to show process info
show_process_info() {
    local app_name="$1"
    local priority_type="$2"  # critical or deprioritized
    
    local pids=$(pgrep -i "$app_name" 2>/dev/null || true)
    
    if [[ -z "$pids" ]]; then
        if [[ "$priority_type" == "critical" ]]; then
            echo -e "${YELLOW}⚠${NC} ${BOLD}$app_name${NC}: ${YELLOW}NOT RUNNING${NC}"
        fi
        return
    fi
    
    local pid_count=$(echo "$pids" | wc -w)
    
    if [[ "$priority_type" == "critical" ]]; then
        echo -e "${GREEN}✓${NC} ${BOLD}$app_name${NC}: ${GREEN}RUNNING${NC} (${pid_count} process(es))"
    else
        echo -e "${BLUE}↓${NC} ${BOLD}$app_name${NC}: Running (${pid_count} process(es))"
    fi
    
    for pid in $pids; do
        if [[ ! -d "/proc/$pid" ]]; then
            continue
        fi
        
        local nice_val=$(ps -o ni= -p "$pid" 2>/dev/null | tr -d ' ' || echo "N/A")
        local oom_score=$(cat "/proc/$pid/oom_score_adj" 2>/dev/null || echo "N/A")
        local cpu_percent=$(ps -o %cpu= -p "$pid" 2>/dev/null | tr -d ' ' || echo "0")
        local mem_percent=$(ps -o %mem= -p "$pid" 2>/dev/null | tr -d ' ' || echo "0")
        
        # Color code nice value
        local nice_color="${NC}"
        if [[ "$nice_val" =~ ^-?[0-9]+$ ]]; then
            if [[ $nice_val -lt 0 ]]; then
                nice_color="${GREEN}"
            elif [[ $nice_val -gt 10 ]]; then
                nice_color="${RED}"
            else
                nice_color="${YELLOW}"
            fi
        fi
        
        echo -e "  ${CYAN}PID${NC} $pid │ ${CYAN}Nice${NC} ${nice_color}$nice_val${NC} │ ${CYAN}OOM${NC} $oom_score │ ${CYAN}CPU${NC} ${cpu_percent}% │ ${CYAN}MEM${NC} ${mem_percent}%"
        
        # Show I/O priority if ionice is available
        if command -v ionice &>/dev/null; then
            local io_info=$(ionice -p "$pid" 2>/dev/null || echo "N/A")
            echo -e "         ${CYAN}I/O${NC} $io_info"
        fi
    done
    echo ""
}

# Critical Applications
echo -e "${BOLD}${GREEN}🎯 Critical Applications (Highest Priority)${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
# CUSTOMIZE: Add your critical applications here
show_process_info "your-critical-app" "critical"
show_process_info "another-app" "critical"

# Deprioritized Applications
echo -e "${BOLD}${MAGENTA}📉 Deprioritized Applications${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
# CUSTOMIZE: Add applications to deprioritize here
show_process_info "browser" "deprioritized"
show_process_info "email-client" "deprioritized"
show_process_info "chat-app" "deprioritized"

# System Resources
echo -e "${BOLD}${BLUE}💻 System Resources${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Memory
MEM_INFO=$(free -h | grep "Mem:")
MEM_TOTAL=$(echo $MEM_INFO | awk '{print $2}')
MEM_USED=$(echo $MEM_INFO | awk '{print $3}')
MEM_FREE=$(echo $MEM_INFO | awk '{print $4}')
MEM_PERCENT=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')

echo -e "${CYAN}Memory${NC}: $MEM_USED / $MEM_TOTAL used (${MEM_PERCENT}% used, $MEM_FREE free)"

# CPU Load
LOAD_AVG=$(uptime | awk -F'load average:' '{print $2}' | xargs)
echo -e "${CYAN}Load Average${NC}: $LOAD_AVG"

# Swap
SWAP_INFO=$(free -h | grep "Swap:")
if [[ -n "$SWAP_INFO" ]]; then
    SWAP_TOTAL=$(echo $SWAP_INFO | awk '{print $2}')
    SWAP_USED=$(echo $SWAP_INFO | awk '{print $3}')
    echo -e "${CYAN}Swap${NC}: $SWAP_USED / $SWAP_TOTAL used"
fi

echo ""

# Recent Log Entries
echo -e "${BOLD}${BLUE}📝 Recent Activity (Last 5 entries)${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [[ -f "$HOME/.local/var/log/priority-manager.log" ]]; then
    tail -n 5 "$HOME/.local/var/log/priority-manager.log" | while read -r line; do
        echo -e "${CYAN}│${NC} $line"
    done
else
    echo -e "${YELLOW}No log file found${NC}"
fi

echo ""

# Quick Actions
echo -e "${BOLD}${CYAN}⚡ Quick Actions${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${CYAN}1.${NC} Emergency boost:     ${YELLOW}sudo ~/.local/bin/boost-now.sh${NC}"
echo -e "${CYAN}2.${NC} Restart service:     ${YELLOW}systemctl --user restart priority-manager${NC}"
echo -e "${CYAN}3.${NC} View live logs:      ${YELLOW}journalctl --user -u priority-manager -f${NC}"
echo -e "${CYAN}4.${NC} Install sudoers:     ${YELLOW}sudo cp ~/priority-manager-sudoers.conf /etc/sudoers.d/priority-manager${NC}"
echo ""

echo -e "${BOLD}${GREEN}Dashboard updated at: $(date '+%Y-%m-%d %H:%M:%S')${NC}"
echo -e "${CYAN}Run 'watch -c -n 5 ~/.local/bin/priority-dashboard.sh' for live updates${NC}"
