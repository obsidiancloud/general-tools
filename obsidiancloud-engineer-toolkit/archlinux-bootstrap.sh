#!/usr/bin/bash
# Arch Linux WSL Bootstrap Script (production-grade + improved error handling)
# -----------------------------------------------------------------------------
# Purpose: Idempotent, non-interactive bootstrap for SaaS, DevOps, AI/ML, and 
#          Cloud development on Arch Linux under WSL with robust error handling.
#
# Usage:
#   bash bootstrap-arch-wsl.sh [flags]
#
# Flags (with defaults):
#   --username <name>          Developer username to create/use (default: dev)
#   --password <pass>          Optional password for the user (if omitted, instructions printed to set later)
#   --hostname <name>          Hostname to set (default: arch-wsl)
#   --enable-systemd           Enable systemd in /etc/wsl.conf (default: off)
#   --ai                       Create AI/ML micromamba env 'ai' (CPU) (default: on)
#   --no-ai                    Disable AI/ML environment creation
#   --gpu                      Print CUDA/cuDNN instructions for WSL GPU (notes only) (default: off)
#   --cloud all|aws|gcp|azure|none   Which cloud CLIs to install (default: all)
#   --skip-ohmyzsh             Skip Oh My Zsh & Powerlevel10k setup (default: false)
#   --run-postfix "<cmd>"      Command to run at the end (e.g., "code .")
#   -h|--help                  Show this help
#
# Examples:
#   bash bootstrap-arch-wsl.sh --username julian --enable-systemd --cloud all --ai --gpu
#   bash bootstrap-arch-wsl.sh --username dev --no-ai --cloud aws

set -euo pipefail

########################
# Globals & Defaults
########################
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"

USERNAME="dev"
USERPASSWORD=""
HOSTNAME_SET="arch-wsl"
ENABLE_SYSTEMD="false"
AI_ENV="true"
GPU_NOTES="false"
CLOUD="all"
SKIP_OHMYZSH="false"
RUN_POSTFIX=""

readonly begin_marker="# >>> BOOTSTRAP MANAGED >>>"
readonly end_marker="# <<< BOOTSTRAP MANAGED <<<"

LAST_STEP="<init>"
declare -a FAILED_STEPS=()
readonly LOG_FILE="/tmp/bootstrap-arch-wsl.$(date +%s).log"

# Timeout settings
readonly NETWORK_TIMEOUT=30
readonly INSTALL_TIMEOUT=600

########################
# Input Validation
########################
validate_inputs() {
    # Username validation
    if [[ ! "$USERNAME" =~ ^[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}\$)$ ]]; then
        err "Invalid username format: $USERNAME"
        exit 1
    fi
    
    # Hostname validation
    if [[ ! "$HOSTNAME_SET" =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?$ ]]; then
        err "Invalid hostname format: $HOSTNAME_SET"
        exit 1
    fi
    
    # Cloud validation
    if [[ ! "$CLOUD" =~ ^(all|aws|gcp|azure|none)$ ]]; then
        err "Invalid cloud option: $CLOUD"
        exit 1
    fi
    
    # Password validation (if provided)
    if [[ -n "$USERPASSWORD" && ${#USERPASSWORD} -lt 8 ]]; then
        warn "Password is less than 8 characters - consider using a stronger password"
    fi
}

########################
# Logging & Error Handling
########################
log() { 
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    printf "\033[1;34m[INFO %s]\033[0m %s\n" "$timestamp" "$*" | tee -a "$LOG_FILE"
}

warn() { 
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    printf "\033[1;33m[WARN %s]\033[0m %s\n" "$timestamp" "$*" | tee -a "$LOG_FILE"
}

err() { 
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    printf "\033[1;31m[ERR  %s]\033[0m %s\n" "$timestamp" "$*" | tee -a "$LOG_FILE"
}

banner() {
    echo | tee -a "$LOG_FILE"
    printf "\033[1;35m==== %s ====\033[0m\n" "$1" | tee -a "$LOG_FILE"
    echo | tee -a "$LOG_FILE"
}

cleanup() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        err "Script failed at step: ${LAST_STEP} with exit code: $exit_code"
        err "Log file available at: $LOG_FILE"
        
        # Attempt to clean up any partial installations
        if [[ -n "${USERNAME:-}" && "$USERNAME" != "root" ]]; then
            log "Attempting cleanup of partial user setup..."
            # Only cleanup if user was being created in this session
            if id "$USERNAME" &>/dev/null && [[ ! -f "/home/$USERNAME/.bootstrap_complete" ]]; then
                run_root "userdel -r '$USERNAME' 2>/dev/null || true"
            fi
        fi
    fi
    
    # Restore terminal settings
    stty sane 2>/dev/null || true
    exit $exit_code
}

on_int() {
    warn "Interrupted at step: ${LAST_STEP}"
    cleanup
}

# Improved trap handling
trap cleanup EXIT
trap on_int INT TERM

########################
# System & Network Checks
########################
check_prerequisites() {
    LAST_STEP="Prerequisites check"
    
    # Check if we have network connectivity
    if ! timeout "$NETWORK_TIMEOUT" ping -c 1 8.8.8.8 &>/dev/null; then
        err "No network connectivity detected"
        exit 1
    fi
    
    # Check available disk space (require at least 2GB)
    local available_space
    available_space=$(df / | awk 'NR==2 {print $4}')
    if [[ "$available_space" -lt 2097152 ]]; then  # 2GB in KB
        err "Insufficient disk space. At least 2GB required, found $((available_space/1024))MB"
        exit 1
    fi
    
    # Check if we're actually on Arch Linux
    if [[ ! -f /etc/os-release ]] || ! grep -q "^ID=arch$" /etc/os-release; then
        err "This script requires Arch Linux"
        exit 1
    fi
    
    # Verify WSL environment
    if ! grep -qiE "microsoft|wsl" /proc/version 2>/dev/null && 
       ! grep -qiE "microsoft|wsl" /proc/sys/kernel/osrelease 2>/dev/null; then
        err "This script is designed for WSL environments only"
        exit 1
    fi
}

########################
# Improved Execution Helpers
########################
need_sudo() { 
    [[ "${EUID}" -ne 0 ]]
}

# Enhanced run_root with better error handling and timeout
run_root() {
    local cmd="$*"
    local max_attempts=3
    local attempt=1
    
    while [[ $attempt -le $max_attempts ]]; do
        if need_sudo; then
            if sudo -n true 2>/dev/null; then
                if timeout "$INSTALL_TIMEOUT" sudo -E bash -c "$cmd" >>"$LOG_FILE" 2>&1; then
                    return 0
                fi
            else
                if timeout "$INSTALL_TIMEOUT" sudo -E bash -c "$cmd" >>"$LOG_FILE" 2>&1; then
                    return 0
                fi
            fi
        else
            if timeout "$INSTALL_TIMEOUT" bash -c "$cmd" >>"$LOG_FILE" 2>&1; then
                return 0
            fi
        fi
        
        ((attempt++))
        if [[ $attempt -le $max_attempts ]]; then
            warn "Command failed (attempt $((attempt-1))/$max_attempts), retrying in 2s..."
            sleep 2
        fi
    done
    
    return 1
}

try_step() {
    local desc="$1"
    shift
    LAST_STEP="$desc"
    log "$desc ..."
    
    if "$@" >>"$LOG_FILE" 2>&1; then
        log "OK: $desc"
        return 0
    else
        FAILED_STEPS+=("$desc")
        err "FAILED: $desc (continuing)"
        return 1
    fi
}

try_root() {
    local desc="$1"
    shift
    LAST_STEP="$desc"
    log "$desc ..."
    
    if run_root "$*"; then
        log "OK: $desc"
        return 0
    else
        FAILED_STEPS+=("$desc")
        err "FAILED: $desc (continuing)"
        return 1
    fi
}

########################
# Utility Functions
########################
cmd_exists() { 
    command -v "$1" >/dev/null 2>&1
}

file_has_block() {
    local file="$1"
    [[ -f "$file" ]] && grep -qF "$begin_marker" "$file" && grep -qF "$end_marker" "$file"
}

# Improved block insertion with atomic operations
insert_or_replace_block() {
    local file="$1" 
    local content="$2"
    local temp_file
    
    temp_file=$(mktemp) || {
        err "Failed to create temporary file"
        return 1
    }
    
    run_root "mkdir -p \"$(dirname "$file")\""
    
    if file_has_block "$file"; then
        # Replace existing block atomically
        if run_root "awk -v b='$begin_marker' -v e='$end_marker' -v repl='$content' '
            \$0 ~ b {print; print repl; skip=1; next}
            \$0 ~ e {print; skip=0; next}
            skip!=1 {print}
        ' '$file' > '$temp_file' && mv '$temp_file' '$file'"; then
            log "Updated managed block in $file"
        else
            err "Failed to update managed block in $file"
            rm -f "$temp_file" 2>/dev/null || true
            return 1
        fi
    else
        # Append new block
        if run_root "bash -c '{
            if [[ -f \"$file\" ]]; then cat \"$file\"; fi
            echo \"$begin_marker\"
            echo \"$content\"
            echo \"$end_marker\"
        } > \"$temp_file\" && mv \"$temp_file\" \"$file\"'"; then
            log "Added managed block to $file"
        else
            err "Failed to add managed block to $file"
            rm -f "$temp_file" 2>/dev/null || true
            return 1
        fi
    fi
    
    rm -f "$temp_file" 2>/dev/null || true
}

append_line_once() {
    local file="$1" 
    local line="$2"
    
    run_root "mkdir -p \"$(dirname "$file")\""
    run_root "touch \"$file\""
    
    if ! run_root "grep -qxF \"$line\" \"$file\""; then
        run_root "echo \"$line\" >> \"$file\""
    fi
}

ensure_owner() {
    local user="$1" 
    local path="$2"
    
    if [[ -e "$path" ]]; then
        run_root "chown -R \"$user:$user\" \"$path\" 2>/dev/null || true"
    fi
}

########################
# Package Management
########################
pacman_refresh() {
    local max_attempts=3
    local attempt=1
    
    while [[ $attempt -le $max_attempts ]]; do
        if try_root "Pacman refresh (attempt $attempt/$max_attempts)" "pacman -Syyu --noconfirm"; then
            return 0
        fi
        
        ((attempt++))
        if [[ $attempt -le $max_attempts ]]; then
            warn "Pacman refresh failed, retrying in 5s..."
            sleep 5
        fi
    done
    
    err "Pacman refresh failed after $max_attempts attempts"
    return 1
}

ensure_keyring() {
    if [[ ! -f /etc/pacman.d/gnupg/pubring.gpg ]]; then
        try_root "pacman-key --init" "pacman-key --init"
        try_root "pacman-key --populate archlinux" "pacman-key --populate archlinux"
    else
        log "Pacman keyring already initialized."
    fi
}

enable_parallel_downloads() {
    local conf="/etc/pacman.conf"
    
    if run_root "grep -qE '^\s*ParallelDownloads' '$conf'"; then
        try_root "Set ParallelDownloads=10" "sed -i -E 's/^\s*#?\s*ParallelDownloads\s*=.*/ParallelDownloads = 10/' '$conf'"
    else
        try_root "Append ParallelDownloads=10" "bash -c 'echo \"ParallelDownloads = 10\" >> \"$conf\"'"
    fi
}

# Improved package installation with dependency resolution
pacman_install_list() {
    local pkgs=("$@")
    local failed_pkgs=()
    local installed_pkgs=()
    
    # Check which packages are already installed
    local available_pkgs=()
    for pkg in "${pkgs[@]}"; do
        if ! run_root "pacman -Q '$pkg' >/dev/null 2>&1"; then
            available_pkgs+=("$pkg")
        else
            log "Package already installed: $pkg"
            installed_pkgs+=("$pkg")
        fi
    done
    
    if [[ ${#available_pkgs[@]} -eq 0 ]]; then
        log "All requested packages already installed"
        return 0
    fi
    
    # Try to install all packages at once first
    LAST_STEP="Install packages: ${available_pkgs[*]}"
    log "Installing packages: ${available_pkgs[*]}"
    
    if run_root "pacman -S --noconfirm --needed ${available_pkgs[*]}"; then
        log "Successfully installed all packages"
        return 0
    fi
    
    # If batch install fails, try individual packages
    warn "Batch install failed, trying individual packages..."
    for pkg in "${available_pkgs[@]}"; do
        LAST_STEP="Install $pkg"
        log "Installing (pacman): $pkg"
        
        if run_root "pacman -S --noconfirm --needed '$pkg'"; then
            log "OK: $pkg"
            installed_pkgs+=("$pkg")
        else
            FAILED_STEPS+=("pacman:$pkg")
            failed_pkgs+=("$pkg")
            err "FAILED (pacman): $pkg (continuing)"
        fi
    done
    
    if [[ ${#failed_pkgs[@]} -gt 0 ]]; then
        warn "Failed to install packages: ${failed_pkgs[*]}"
        return 1
    fi
    
    return 0
}

ensure_yay() {
    if cmd_exists yay; then
        log "yay already installed."
        return 0
    fi
    
    # Install dependencies first
    pacman_install_list base-devel git
    
    local builddir="/opt/yay"
    
    if [[ ! -d "$builddir" ]]; then
        try_root "Clone yay AUR" "git clone https://aur.archlinux.org/yay.git '$builddir'"
        try_root "Chown yay dir" "chown -R '${USERNAME}:${USERNAME}' '$builddir'"
    fi
    
    LAST_STEP="Build and install yay"
    if run_root "su - '${USERNAME}' -c 'cd $builddir && makepkg -si --noconfirm --needed'"; then
        log "yay installed successfully"
        try_root "Clean yay builddir" "rm -rf '$builddir'"
        return 0
    else
        FAILED_STEPS+=("yay:install")
        err "FAILED: yay install (continuing; AUR installs will likely fail)"
        return 1
    fi
}

aur_install_list() {
    if ! ensure_yay; then
        err "Cannot install AUR packages without yay"
        return 1
    fi
    
    local pkgs=("$@")
    local failed_pkgs=()
    
    for pkg in "${pkgs[@]}"; do
        LAST_STEP="AUR install $pkg"
        log "Installing (AUR): $pkg"
        
        # Check if already installed
        if run_root "su - '${USERNAME}' -c 'yay -Q $pkg >/dev/null 2>&1'"; then
            log "AUR package already installed: $pkg"
            continue
        fi
        
        if run_root "su - '${USERNAME}' -c 'yay -S --noconfirm --needed --batchinstall --removemake $pkg'"; then
            log "OK: $pkg"
        else
            FAILED_STEPS+=("aur:$pkg")
            failed_pkgs+=("$pkg")
            err "FAILED (AUR): $pkg (continuing)"
        fi
    done
    
    if [[ ${#failed_pkgs[@]} -gt 0 ]]; then
        warn "Failed to install AUR packages: ${failed_pkgs[*]}"
        return 1
    fi
    
    return 0
}

########################
# System Configuration
########################
set_hostname() {
    try_root "Set /etc/hostname" "bash -c 'echo \"$HOSTNAME_SET\" > /etc/hostname'"
    try_step "Set runtime hostname" hostname "$HOSTNAME_SET"
    
    # Ensure proper /etc/hosts entries
    append_line_once "/etc/hosts" "127.0.0.1 localhost"
    append_line_once "/etc/hosts" "127.0.1.1 ${HOSTNAME_SET}"
    append_line_once "/etc/hosts" "::1 localhost"
}

configure_wsl_systemd() {
    if [[ "${ENABLE_SYSTEMD}" == "true" ]]; then
        local content="[boot]
systemd=true

[automount]
options = \"metadata,umask=22,fmask=11\"

[interop]
appendWindowsPath = false"
        
        insert_or_replace_block "/etc/wsl.conf" "$content"
        log "Systemd enabled in /etc/wsl.conf (run 'wsl.exe --shutdown' in Windows to apply)"
    fi
}

########################
# User Management
########################
ensure_user() {
    if id -u "${USERNAME}" >/dev/null 2>&1; then
        log "User ${USERNAME} already exists."
    else
        # Install zsh first if not already installed
        pacman_install_list zsh
        
        try_root "Create user ${USERNAME}" "useradd -m -s /bin/zsh -G wheel '${USERNAME}'"
        
        if [[ -n "${USERPASSWORD}" ]]; then
            try_root "Set password for ${USERNAME}" "bash -c 'echo \"${USERNAME}:${USERPASSWORD}\" | chpasswd'"
        else
            warn "No --password provided. Set later with: sudo passwd ${USERNAME}"
        fi
    fi
    
    # Ensure correct shell
    try_root "Ensure ${USERNAME} shell is zsh" "chsh -s /bin/zsh '${USERNAME}'"
    
    # Ensure home directory ownership
    ensure_owner "${USERNAME}" "/home/${USERNAME}"
    
    # Create marker file to indicate this user was set up by bootstrap
    try_root "Create bootstrap marker" "touch /home/${USERNAME}/.bootstrap_setup"
    ensure_owner "${USERNAME}" "/home/${USERNAME}/.bootstrap_setup"
}

configure_sudo() {
    pacman_install_list sudo
    
    # More secure sudo configuration
    local sudoers_content="%wheel ALL=(ALL:ALL) ALL
Defaults passwd_tries=3
Defaults badpass_message=\"Sorry, try again.\"
Defaults lecture=once
Defaults requiretty"
    
    try_root "Configure wheel sudo" "bash -c 'echo \"$sudoers_content\" > /etc/sudoers.d/10-wheel && chmod 0440 /etc/sudoers.d/10-wheel'"
}

########################
# Shell Configuration
########################
setup_ohmyzsh() {
    [[ "${SKIP_OHMYZSH}" == "true" ]] && { warn "Skipping Oh My Zsh"; return 0; }
    
    local home="/home/${USERNAME}"
    local omz="${home}/.oh-my-zsh"
    
    # Install Oh My Zsh
    if [[ ! -d "$omz" ]]; then
        try_root "Install Oh My Zsh" "su - '${USERNAME}' -c 'curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh | bash -s -- --unattended'"
    else
        log "Oh My Zsh already installed."
    fi
    
    local custom="${omz}/custom"
    try_root "Create OMZ custom dirs" "mkdir -p '${custom}/themes' '${custom}/plugins'"
    
    # Install plugins and themes
    local plugins=(
        "powerlevel10k:themes:https://github.com/romkatv/powerlevel10k.git"
        "zsh-autosuggestions:plugins:https://github.com/zsh-users/zsh-autosuggestions"
        "zsh-syntax-highlighting:plugins:https://github.com/zsh-users/zsh-syntax-highlighting.git"
        "zsh-completions:plugins:https://github.com/zsh-users/zsh-completions"
    )
    
    for plugin_info in "${plugins[@]}"; do
        IFS=':' read -r name type url <<< "$plugin_info"
        local plugin_dir="${custom}/${type}/${name}"
        
        if [[ ! -d "$plugin_dir" ]]; then
            try_root "Install $name" "su - '${USERNAME}' -c 'git clone --depth=1 $url $plugin_dir'"
        else
            log "$name already installed"
        fi
    done
    
    # Configure .zshrc with improved settings
    local zshrc="${home}/.zshrc"
    local zsh_block='export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugin configuration
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
    command-not-found
    history-substring-search
)

# History configuration
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_BEEP

# Completion system
autoload -Uz compinit
[[ -z "$ZSH_COMPDUMP" ]] && ZSH_COMPDUMP="$HOME/.zcompdump-$HOST"
compinit -u

# Enhanced aliases
alias ls="eza -la --group-directories-first --git" 2>/dev/null || alias ls="ls -la --color=auto"
alias cat="bat" 2>/dev/null || alias cat="cat"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias grep="grep --color=auto"
alias ll="ls -alF"
alias la="ls -A"
alias l="ls -CF"

# System information
command -v fastfetch >/dev/null 2>&1 && alias neofetch="fastfetch"

# Development tools
alias g="git"
alias dc="docker-compose"
alias k="kubectl"
alias tf="terraform"
alias tg="terragrunt"

# Navigation and file management
eval "$(zoxide init zsh)" 2>/dev/null || true
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"

# Docker service integration
export DOCKER_HOST="unix:///var/run/docker.sock"

# asdf version manager
if [[ -f "$HOME/.asdf/asdf.sh" ]]; then
    . "$HOME/.asdf/asdf.sh"
    fpath=(${ASDF_DIR}/completions $fpath)
fi

# Tool completions (load conditionally)
command -v kubectl >/dev/null 2>&1 && source <(kubectl completion zsh) 2>/dev/null
command -v helm >/dev/null 2>&1 && source <(helm completion zsh) 2>/dev/null
command -v aws >/dev/null 2>&1 && complete -C "/usr/bin/aws_completer" aws 2>/dev/null

# AI/ML environment shortcuts
alias jl="micromamba run -n ai jupyter lab --no-browser --ip=0.0.0.0 --allow-root"
alias ai-env="micromamba activate ai"

# GPU shortcuts (if available)
command -v nvidia-smi >/dev/null 2>&1 && alias gpu="nvidia-smi"
command -v nvtop >/dev/null 2>&1 && alias gputop="nvtop"
    fpath=(${ASDF_DIR}/completions $fpath)
fi

# Tool completions (load conditionally)
command -v kubectl >/dev/null 2>&1 && source <(kubectl completion zsh) 2>/dev/null
command -v helm >/dev/null 2>&1 && source <(helm completion zsh) 2>/dev/null
command -v aws >/dev/null 2>&1 && complete -C "/usr/bin/aws_completer" aws 2>/dev/null

# AI/ML environment shortcuts
alias jl="micromamba run -n ai jupyter lab --no-browser --ip=0.0.0.0 --allow-root"
alias ai-env="micromamba activate ai"

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Custom functions
mkcd() { mkdir -p "$1" && cd "$1"; }
extract() {
    if [[ -f $1 ]]; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar x $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)           echo "Cannot extract $1" ;;
        esac
    else
        echo "$1 is not a valid file"
    fi
}'
    
    insert_or_replace_block "$zshrc" "$zsh_block"
    ensure_owner "${USERNAME}" "$zshrc"
    
    # Create a comprehensive .p10k.zsh configuration
    local p10k="${home}/.p10k.zsh"
    if [[ ! -f "$p10k" ]]; then
        local p10k_config='# Powerlevel10k configuration
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    os_icon
    dir
    vcs
    newline
    prompt_char
)

typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    status
    command_execution_time
    background_jobs
    context
    time
)

# Directory
typeset -g POWERLEVEL9K_DIR_FOREGROUND=31
typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
typeset -g POWERLEVEL9K_SHORTEN_DELIMITER=

# Git
typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=76
typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=178
typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=76

# Time
typeset -g POWERLEVEL9K_TIME_FORMAT="%D{%H:%M:%S}"
typeset -g POWERLEVEL9K_TIME_FOREGROUND=66

# Command execution time
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=0

# Prompt character
typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=76
typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=196'
        
        try_root "Write .p10k.zsh" "bash -c 'cat > \"$p10k\" <<< \"$p10k_config\"'"
        ensure_owner "${USERNAME}" "$p10k"
    fi
}

########################
# Development Tools
########################
install_core_packages() {
    enable_parallel_downloads
    
    local packages=(
        # Base development
        base-devel git curl wget gnupg sudo zsh unzip zip tar gzip xz p7zip openssh
        gawk sed coreutils findutils which
        
        # Modern CLI tools
        jq yq ripgrep fd fzf bat eza zoxide tree htop ncdu fastfetch
        
        # Documentation
        man-db man-pages
        
        # Compilers and build tools
        gcc clang llvm lldb gdb cmake make ninja pkgconf
        
        # Development utilities
        pre-commit shellcheck shfmt neovim rsync rlwrap tmux git-delta
        
        # Additional useful tools
        strace ltrace lsof net-tools bind-tools
    )
    
    pacman_install_list "${packages[@]}"
}

configure_tmux() {
    local tmux_conf="/home/${USERNAME}/.tmux.conf"
    local tmux_block='# Mouse support
set -g mouse on

# Vi mode
setw -g mode-keys vi
bind-key -T copy-mode-vi v send-keys -X begin-selection
bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

# History
set -g history-limit 100000

# Status bar
set -g status-interval 5
set -g status-bg colour234
set -g status-fg colour137
set -g status-left ""
set -g status-right "#[fg=colour233,bg=colour241,bold] %d/%m #[fg=colour233,bg=colour245,bold] %H:%M:%S "

# Pane borders
set -g pane-border-fg colour238
set -g pane-active-border-fg colour51

# Window status
setw -g window-status-current-fg colour81
setw -g window-status-current-bg colour238
setw -g window-status-current-attr bold

# Reload config
bind r source-file ~/.tmux.conf \; display-message "Config reloaded!"

# Better pane splitting
bind | split-window -h
bind - split-window -v
unbind '"'
unbind %

# Switch panes using Alt-arrow without prefix
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D'

    insert_or_replace_block "$tmux_conf" "$tmux_block"
    ensure_owner "${USERNAME}" "$tmux_conf"
}

setup_git() {
    # Global git configuration
    local git_configs=(
        "init.defaultBranch main"
        "core.editor nvim"
        "core.autocrlf input"
        "pull.rebase false"
        "push.default simple"
        "color.ui auto"
    )
    
    for config in "${git_configs[@]}"; do
        try_root "git config $config" "su - '${USERNAME}' -c 'git config --global $config'"
    done
    
    # Configure delta if available
    if cmd_exists delta; then
        try_root "git delta pager" "su - '${USERNAME}' -c 'git config --global core.pager delta'"
        try_root "git delta diff filter" "su - '${USERNAME}' -c 'git config --global interactive.diffFilter \"delta --color-only\"'"
        try_root "git delta features" "su - '${USERNAME}' -c 'git config --global delta.features \"side-by-side line-numbers decorations\"'"
        try_root "git delta syntax theme" "su - '${USERNAME}' -c 'git config --global delta.syntax-theme \"Dracula\"'"
    fi
    
    # Global gitignore
    local gitignore="/home/${USERNAME}/.gitignore_global"
    if [[ ! -f "$gitignore" ]]; then
        local gitignore_content='# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Editor directories and files
.vscode/
.idea/
*.swp
*.swo
*~

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
env.bak/
venv.bak/
*.egg-info/
.eggs/
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/

# Node.js
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.npm
.node_repl_history
*.tgz
.yarn-integrity

# Terraform
.terraform/
*.tfstate
*.tfstate.*
*.tfvars
.terraform.lock.hcl

# Go
*.exe
*.exe~
*.dll
*.so
*.dylib
*.test
*.out
vendor/

# Rust
target/
Cargo.lock

# Java
*.class
*.jar
*.war
*.ear
*.zip
*.tar.gz
*.rar
hs_err_pid*

# Logs
*.log
logs/

# Environment variables
.env
.env.*
!.env.example

# IDE
.vscode/
.idea/
*.iml

# Temporary files
*.tmp
*.temp
*.bak
*.backup'
        
        try_root "Write .gitignore_global" "bash -c 'cat > \"$gitignore\" <<< \"$gitignore_content\"'"
        ensure_owner "${USERNAME}" "$gitignore"
        try_root "git excludesfile" "su - '${USERNAME}' -c 'git config --global core.excludesfile ~/.gitignore_global'"
    fi
}

install_code_editor() {
    ensure_yay
    aur_install_list visual-studio-code-bin
    
    # Install useful VS Code extensions via CLI (if code is available)
    local extensions=(
        "ms-python.python"
        "ms-python.black-formatter"
        "ms-python.isort"
        "hashicorp.terraform"
        "ms-kubernetes-tools.vscode-kubernetes-tools"
        "ms-vscode.docker"
        "redhat.vscode-yaml"
        "github.copilot"
        "github.vscode-pull-request-github"
        "eamodio.gitlens"
        "esbenp.prettier-vscode"
        "bradlc.vscode-tailwindcss"
        "rust-lang.rust-analyzer"
        "golang.go"
        "ms-vscode.cmake-tools"
    )
    
    for ext in "${extensions[@]}"; do
        try_root "Install VS Code extension $ext" "su - '${USERNAME}' -c 'code --install-extension $ext --force'" || true
    done
}

########################
# Runtime Management
########################
install_asdf_and_plugins() {
    local home="/home/${USERNAME}"
    local asdf_dir="${home}/.asdf"
    
    # Install asdf
    if [[ ! -d "$asdf_dir" ]]; then
        try_root "Clone asdf" "su - '${USERNAME}' -c 'git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.1'"
    else
        try_root "Update asdf" "su - '${USERNAME}' -c 'cd ~/.asdf && git pull origin main'"
    fi
    
    # Install plugins with error handling
    local plugins=(
        "nodejs:https://github.com/asdf-vm/asdf-nodejs.git"
        "python:https://github.com/danhper/asdf-python.git"
        "golang:https://github.com/asdf-community/asdf-golang.git"
        "java:https://github.com/halcyon/asdf-java.git"
        "rust:https://github.com/code-lever/asdf-rust.git"
        "terraform:https://github.com/asdf-community/asdf-terraform.git"
        "kubectl:https://github.com/asdf-community/asdf-kubectl.git"
        "helm:https://github.com/Antiarchitect/asdf-helm.git"
    )
    
    for plugin_info in "${plugins[@]}"; do
        IFS=':' read -r plugin_name plugin_url <<< "$plugin_info"
        try_root "asdf plugin $plugin_name" "su - '${USERNAME}' -c '~/.asdf/bin/asdf plugin add $plugin_name $plugin_url || ~/.asdf/bin/asdf plugin update $plugin_name || true'"
    done
    
    # Import Node.js release team keyring
    try_root "Import nodejs keys" "su - '${USERNAME}' -c '~/.asdf/plugins/nodejs/bin/import-release-team-keyring || true'"
    
    # Install latest stable versions
    local version_installs=(
        "nodejs:lts"
        "python:3.12.0"
        "golang:latest"
        "java:temurin-21.0.1+12.0.LTS"
        "terraform:latest"
        "kubectl:latest"
        "helm:latest"
    )
    
    for version_info in "${version_installs[@]}"; do
        IFS=':' read -r tool version <<< "$version_info"
        
        if [[ "$version" == "lts" ]]; then
            try_root "Install $tool $version" "su - '${USERNAME}' -c 'LTS=\"\$(~/.asdf/bin/asdf latest $tool lts 2>/dev/null || echo)\"; [ -n \"$LTS\" ] && ~/.asdf/bin/asdf install $tool \"$LTS\" && ~/.asdf/bin/asdf global $tool \"$LTS\"'"
        elif [[ "$version" == "latest" ]]; then
            try_root "Install $tool $version" "su - '${USERNAME}' -c 'LATEST=\"\$(~/.asdf/bin/asdf latest $tool 2>/dev/null || echo)\"; [ -n \"$LATEST\" ] && ~/.asdf/bin/asdf install $tool \"$LATEST\" && ~/.asdf/bin/asdf global $tool \"$LATEST\"'"
        else
            try_root "Install $tool $version" "su - '${USERNAME}' -c '~/.asdf/bin/asdf install $tool $version && ~/.asdf/bin/asdf global $tool $version'"
        fi
    done
    
    try_root "asdf reshim all" "su - '${USERNAME}' -c '~/.asdf/bin/asdf reshim'"
}

language_tooling() {
    # Node.js global packages
    local npm_packages=(
        "yarn"
        "pnpm"
        "aws-cdk"
        "@aws-cdk/aws-lambda"
        "typescript"
        "@types/node"
        "eslint"
        "prettier"
        "serverless"
        "netlify-cli"
        "vercel"
    )
    
    for package in "${npm_packages[@]}"; do
        try_root "npm install $package" "su - '${USERNAME}' -c 'command -v npm >/dev/null 2>&1 && (npm list -g $package >/dev/null 2>&1 || npm install -g $package)'"
    done
    
    # Python tooling with pipx
    pacman_install_list python-pipx python-pip
    
    try_root "pipx ensurepath" "su - '${USERNAME}' -c 'pipx ensurepath'"
    
    local pipx_tools=(
        "poetry"
        "pre-commit"
        "pipenv"
        "black"
        "isort"
        "flake8"
        "mypy"
        "pytest"
        "cookiecutter"
        "httpie"
        "awscli"
    )
    
    for tool in "${pipx_tools[@]}"; do
        try_root "pipx install $tool" "su - '${USERNAME}' -c 'pipx install $tool || pipx upgrade $tool || true'"
    done
    
    # Rust toolchain
    if ! run_root "su - '${USERNAME}' -c 'command -v rustup >/dev/null 2>&1'"; then
        try_root "Install rustup" "su - '${USERNAME}' -c 'curl --proto \"=https\" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --profile default'"
    fi
    
    # Rust components and tools
    local rust_components=(
        "rust-analyzer"
        "rustfmt"
        "clippy"
    )
    
    for component in "${rust_components[@]}"; do
        try_root "rustup component $component" "su - '${USERNAME}' -c '~/.cargo/bin/rustup component add $component'"
    done
    
    # Useful Rust CLI tools
    local cargo_tools=(
        "cargo-edit"
        "cargo-watch"
        "cargo-audit"
        "cargo-outdated"
    )
    
    for tool in "${cargo_tools[@]}"; do
        try_root "cargo install $tool" "su - '${USERNAME}' -c '~/.cargo/bin/cargo install $tool'"
    done
}

########################
# Infrastructure & Cloud Tools
########################
install_containers_k8s_iac_cloud() {
    # Container runtime and tools
    local container_packages=(
        docker docker-compose docker-buildx
        podman buildah skopeo
    )
    pacman_install_list "${container_packages[@]}"
    
    # Kubernetes tools
    local k8s_packages=(
        kubectl helm kustomize kind k9s stern
    )
    pacman_install_list "${k8s_packages[@]}"
    
    # Additional K8s tools from AUR
    ensure_yay
    local k8s_aur_packages=(
        kubectx
        kubens
        kubeseal
        flux-cli
        argocd-cli
    )
    aur_install_list "${k8s_aur_packages[@]}"
    
    # Infrastructure as Code tools
    local iac_packages=(
        terraform tflint
        ansible
        packer
        vagrant
    )
    pacman_install_list "${iac_packages[@]}"
    
    # Security and compliance tools
    local security_packages=(
        checkov trivy sops age
        gnupg pass
    )
    pacman_install_list "${security_packages[@]}"
    
    # Development workflow tools
    local workflow_packages=(
        direnv gh pre-commit
        jq yq
    )
    pacman_install_list "${workflow_packages[@]}"
    
    # AUR infrastructure tools
    local iac_aur_packages=(
        terragrunt
        terraformer
        terraform-ls
        packer-plugin-ansible
    )
    aur_install_list "${iac_aur_packages[@]}"
    
    # Cloud CLI tools based on selection
    case "${CLOUD}" in
        all)
            pacman_install_list aws-cli-v2
            aur_install_list session-manager-plugin google-cloud-cli azure-cli
            try_root "Install AWS SAM CLI" "su - '${USERNAME}' -c 'pipx install aws-sam-cli'"
            ;;
        aws)
            pacman_install_list aws-cli-v2
            aur_install_list session-manager-plugin
            try_root "Install AWS SAM CLI" "su - '${USERNAME}' -c 'pipx install aws-sam-cli'"
            ;;
        gcp)
            aur_install_list google-cloud-cli
            ;;
        azure)
            aur_install_list azure-cli
            ;;
        none)
            log "Skipping cloud CLIs as requested."
            ;;
        *)
            warn "Unknown cloud option '${CLOUD}', skipping cloud CLIs."
            ;;
    esac
}

configure_docker() {
    # Add user to docker group
    try_root "Add user to docker group" "usermod -aG docker '${USERNAME}'"
    
    # Configure Docker daemon
    local docker_daemon_config='{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2",
  "features": {
    "buildkit": true
  }
}'
    
    try_root "Configure Docker daemon" "mkdir -p /etc/docker && echo '$docker_daemon_config' > /etc/docker/daemon.json"
    
    # Docker socket detection and hints
    local docker_sockets=(
        "/mnt/wsl/shared-docker/docker.sock"
        "/var/run/docker.sock"
    )
    
    local socket_found=false
    for socket in "${docker_sockets[@]}"; do
        if [[ -S "$socket" ]]; then
            log "Docker socket detected at: $socket"
            socket_found=true
            break
        fi
    done
    
    if [[ "$socket_found" == false ]]; then
        warn "Docker socket not detected. If using Docker Desktop, enable WSL integration for this distro."
        warn "Alternatively, you can start Docker daemon manually or use Podman as an alternative."
    fi
}

########################
# AI/ML Environment
########################
install_ai_env() {
    [[ "${AI_ENV}" != "true" ]] && { log "AI/ML env disabled (--no-ai)"; return 0; }
    
    # Install micromamba
    ensure_yay
    aur_install_list micromamba-bin
    
    # Initialize micromamba
    try_root "Initialize micromamba" "su - '${USERNAME}' -c 'micromamba shell init --shell=zsh --prefix=~/.micromamba'"
    
    local envname="ai"
    
    # Check if environment already exists
    if run_root "su - '${USERNAME}' -c 'micromamba env list | grep -qE \"^${envname}\\s\"'"; then
        log "Micromamba environment '${envname}' already exists"
        return 0
    fi
    
    # Create comprehensive AI/ML environment
    local ai_packages=(
        # Core Python and scientific computing
        "python>=3.11"
        "numpy"
        "pandas"
        "scipy"
        "scikit-learn"
        
        # Data visualization
        "matplotlib"
        "seaborn"
        "plotly"
        "bokeh"
        
        # Jupyter ecosystem
        "jupyterlab"
        "ipykernel"
        "ipywidgets"
        "jupyter_contrib_nbextensions"
        
        # Machine Learning
        "xgboost"
        "lightgbm"
        "catboost"
        
        # Deep Learning (CPU versions)
        "pytorch"
        "torchvision"
        "torchaudio"
        "cpuonly"
        
        # Data processing
        "pydantic"
        "sqlalchemy"
        "pymongo"
        "redis-py"
        
        # Development tools
        "black"
        "isort"
        "flake8"
        "mypy"
        "pytest"
        "poetry"
        
        # Additional utilities
        "requests"
        "httpx"
        "fastapi"
        "uvicorn"
        "streamlit"
        "dash"
    )
    
    # Create environment with retry logic
    local create_cmd="micromamba create -y -n ${envname} -c conda-forge -c pytorch --strict-channel-priority ${ai_packages[*]}"
    
    try_root "Create micromamba AI environment" "su - '${USERNAME}' -c '$create_cmd'"
    
    # Install additional packages with pip in the environment
    local pip_packages=(
        "openai"
        "anthropic"
        "langchain"
        "transformers"
        "datasets"
        "huggingface-hub"
        "wandb"
        "mlflow"
        "dvc"
        "great-expectations"
    )
    
    for package in "${pip_packages[@]}"; do
        try_root "Install $package via pip" "su - '${USERNAME}' -c 'micromamba run -n ${envname} pip install $package'"
    done
    
    # Register Jupyter kernel
    try_root "Register Jupyter kernel" "su - '${USERNAME}' -c 'micromamba run -n ${envname} python -m ipykernel install --user --name ${envname} --display-name \"Python (${envname})\"'"
    
    # Create sample notebook
    local notebook_dir="/home/${USERNAME}/notebooks"
    try_root "Create notebooks directory" "mkdir -p '$notebook_dir'"
    ensure_owner "${USERNAME}" "$notebook_dir"
    
    local sample_notebook='{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# AI/ML Development Environment\\n",
    "\\n",
    "This notebook is running in the `ai` micromamba environment with:\\n",
    "- Python 3.11+\\n",
    "- PyTorch (CPU)\\n",
    "- Scikit-learn\\n",
    "- Pandas, NumPy, Matplotlib\\n",
    "- Jupyter Lab\\n",
    "\\n",
    "Run the cells below to verify your environment:"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "source": [
    "import sys\\n",
    "import torch\\n",
    "import pandas as pd\\n",
    "import numpy as np\\n",
    "import matplotlib.pyplot as plt\\n",
    "\\n",
    "print(f\"Python version: {sys.version}\")\\n",
    "print(f\"PyTorch version: {torch.__version__}\")\\n",
    "print(f\"Pandas version: {pd.__version__}\")\\n",
    "print(f\"NumPy version: {np.__version__}\")"
   ]
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python (ai)",
   "language": "python",
   "name": "ai"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 4
}'
    
    try_root "Create sample notebook" "bash -c 'echo \"$sample_notebook\" > \"$notebook_dir/welcome.ipynb\"'"
    ensure_owner "${USERNAME}" "$notebook_dir/welcome.ipynb"
}

gpu_instructions_note() {
    [[ "${GPU_NOTES}" != "true" ]] && return 0
    
    banner "GPU / CUDA Setup Instructions"
    cat <<'GPU_INSTRUCTIONS' | tee -a "$LOG_FILE"

To enable GPU support in WSL:

1. Prerequisites:
   - Latest NVIDIA Windows driver with WSL support
   - Windows 11 or Windows 10 version 21H2 or higher

2. Update WSL:
   From Windows PowerShell (as Administrator):
   wsl --update
   wsl --shutdown

3. Install CUDA toolkit in Arch Linux:
   sudo pacman -S cuda cudnn
   
   # Or for specific versions:
   yay -S cuda-11.8 cudnn

4. Update AI environment with GPU support:
   micromamba activate ai
   micromamba install pytorch torchvision torchaudio pytorch-cuda=11.8 -c pytorch -c nvidia
   
   # For TensorFlow:
   pip install tensorflow-gpu

5. Verify GPU access:
   python -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}'); print(f'GPU count: {torch.cuda.device_count()}')"

6. Additional GPU tools:
   nvidia-smi  # Should work from WSL
   nvtop       # Install with: yay -S nvtop

Note: GPU passthrough in WSL requires Windows Insider builds for some features.
GPU_INSTRUCTIONS
}

########################
# System Fonts & Appearance
########################
install_fonts_and_qol() {
    ensure_yay
    
    # Essential fonts for development
    local fonts=(
        ttf-meslo-nerd-font-powerlevel10k
        ttf-fira-code
        ttf-jetbrains-mono
        noto-fonts
        noto-fonts-emoji
        ttf-liberation
        ttf-dejavu
        adobe-source-code-pro-fonts
    )
    
    aur_install_list "${fonts[@]}"
    
    # Update font cache
    try_root "Update font cache" "fc-cache -fv"
}

########################
# System Validation
########################
validate_installation() {
    banner "Installation Validation"
    
    local validation_results=()
    
    # Check critical commands
    local critical_commands=(
        "zsh"
        "git"
        "curl"
        "wget"
        "docker"
        "kubectl"
        "terraform"
        "python3"
        "node"
        "npm"
    )
    
    for cmd in "${critical_commands[@]}"; do
        if run_root "su - '${USERNAME}' -c 'command -v $cmd >/dev/null 2>&1'"; then
            validation_results+=("✓ $cmd: available")
        else
            validation_results+=("✗ $cmd: missing")
        fi
    done
    
    # Check user setup
    if id "$USERNAME" &>/dev/null; then
        validation_results+=("✓ User $USERNAME: exists")
        
        if run_root "groups '$USERNAME' | grep -q wheel"; then
            validation_results+=("✓ User $USERNAME: in wheel group")
        else
            validation_results+=("✗ User $USERNAME: not in wheel group")
        fi
        
        if [[ -d "/home/$USERNAME" ]]; then
            validation_results+=("✓ Home directory: exists")
        else
            validation_results+=("✗ Home directory: missing")
        fi
    else
        validation_results+=("✗ User $USERNAME: does not exist")
    fi
    
    # Check shell setup
    if [[ -f "/home/$USERNAME/.zshrc" ]] && file_has_block "/home/$USERNAME/.zshrc"; then
        validation_results+=("✓ Zsh configuration: managed block present")
    else
        validation_results+=("✗ Zsh configuration: managed block missing")
    fi
    
    # Display results
    log "Validation Results:"
    for result in "${validation_results[@]}"; do
        echo "  $result" | tee -a "$LOG_FILE"
    done
    
    # Check if any critical failures
    local failures=0
    for result in "${validation_results[@]}"; do
        if [[ "$result" == *"✗"* ]]; then
            ((failures++))
        fi
    done
    
    if [[ $failures -eq 0 ]]; then
        log "✅ All validation checks passed!"
        return 0
    else
        warn "⚠️  $failures validation check(s) failed"
        return 1
    fi
}

########################
# Summary & Next Steps
########################
print_summary() {
    banner "Bootstrap Summary"
    
    local completion_time
    completion_time=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "Bootstrap completed at: $completion_time"
    echo "User:                  ${USERNAME}"
    echo "Home:                  /home/${USERNAME}"
    echo "Hostname:              ${HOSTNAME_SET}"
    echo "Systemd enabled:       ${ENABLE_SYSTEMD}"
    echo "AI environment:        ${AI_ENV}"
    echo "GPU notes shown:       ${GPU_NOTES}"
    echo "Cloud CLIs:           ${CLOUD}"
    echo "Oh My Zsh:            $( [[ "${SKIP_OHMYZSH}" == "true" ]] && echo "skipped" || echo "installed" )"
    echo "Log file:             ${LOG_FILE}"
    echo
    
    # Show installed tool versions
    echo "Installed Tool Versions:"
    local version_checks=(
        "zsh --version"
        "git --version" 
        "gh --version | head -n1"
        "docker --version"
        "kubectl version --client --short"
        "terraform --version | head -n1"
        "python3 --version"
        "node --version"
        "go version"
        "rustc --version"
    )
    
    for check in "${version_checks[@]}"; do
        local tool_name
        tool_name=$(echo "$check" | cut -d' ' -f1)
        printf "  %-12s " "$tool_name:"
        
        if run_root "su - '${USERNAME}' -c '$check'" 2>/dev/null; then
            run_root "su - '${USERNAME}' -c '$check' 2>/dev/null | head -n1" | sed 's/^//'
        else
            echo "not available"
        fi
    done | tee -a "$LOG_FILE"
    
    echo
    
    # Show failed steps if any
    if ((${#FAILED_STEPS[@]})); then
        echo "⚠️  Failed Steps (non-critical):"
        for step in "${FAILED_STEPS[@]}"; do 
            echo "  - $step"
        done
        echo
    fi
    
    # Configuration files created/modified
    echo "Configuration Files:"
    local config_files=(
        "/etc/hostname"
        "/etc/hosts" 
        "/etc/wsl.conf"
        "/home/${USERNAME}/.zshrc"
        "/home/${USERNAME}/.p10k.zsh"
        "/home/${USERNAME}/.gitignore_global"
        "/home/${USERNAME}/.tmux.conf"
    )
    
    for file in "${config_files[@]}"; do
        if [[ -f "$file" ]]; then
            echo "  ✓ $file"
        else
            echo "  ✗ $file (missing)"
        fi
    done | tee -a "$LOG_FILE"
    
    echo
    echo "🚀 Next Steps:"
    
    if [[ -z "${USERPASSWORD}" ]]; then
        echo "  1. Set password for ${USERNAME}: sudo passwd ${USERNAME}"
    fi
    
    if [[ "${ENABLE_SYSTEMD}" == "true" ]]; then
        echo "  2. Restart WSL from Windows PowerShell: wsl --shutdown"
        echo "     Then relaunch this distribution"
    fi
    
    cat <<'NEXT_STEPS'
  3. Configure terminal to use a Nerd Font (MesloLGS NF recommended)
  4. Start new shell session or run: source ~/.zshrc
  5. Configure git identity:
     git config --global user.name "Your Name"
     git config --global user.email "you@example.com"
  6. For Docker: Enable WSL integration in Docker Desktop settings
  7. For AI/ML: Start Jupyter Lab with: jl
  8. Test installations:
     - Run: fastfetch
     - Test Docker: docker run hello-world
     - Test Kubernetes: kubectl version --client
NEXT_STEPS
    
    if [[ "${AI_ENV}" == "true" ]]; then
        echo "  9. AI Environment:"
        echo "     - Activate: micromamba activate ai"
        echo "     - Jupyter Lab: jl"
        echo "     - Sample notebook: ~/notebooks/welcome.ipynb"
    fi
    
    echo
    echo "📝 Troubleshooting:"
    echo "  - Full log: $LOG_FILE"
    echo "  - Re-run script safely (idempotent)"
    echo "  - Check failed steps above for non-critical issues"
    
    # Create completion marker
    try_root "Create completion marker" "touch /home/${USERNAME}/.bootstrap_complete && echo '$completion_time' > /home/${USERNAME}/.bootstrap_complete"
    ensure_owner "${USERNAME}" "/home/${USERNAME}/.bootstrap_complete"
}

########################
# Argument Parsing
########################
show_help() {
    sed -n '2,40p' "$0"
    exit 0
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --username)
                USERNAME="${2:-}"
                if [[ -z "$USERNAME" ]]; then
                    err "--username requires a value"
                    exit 1
                fi
                shift 2
                ;;
            --password)
                USERPASSWORD="${2:-}"
                shift 2
                ;;
            --hostname)
                HOSTNAME_SET="${2:-}"
                if [[ -z "$HOSTNAME_SET" ]]; then
                    err "--hostname requires a value"
                    exit 1
                fi
                shift 2
                ;;
            --enable-systemd)
                ENABLE_SYSTEMD="true"
                shift
                ;;
            --ai)
                AI_ENV="true"
                shift
                ;;
            --no-ai)
                AI_ENV="false"
                shift
                ;;
            --gpu)
                GPU_NOTES="true"
                shift
                ;;
            --cloud)
                CLOUD="${2:-all}"
                if [[ ! "$CLOUD" =~ ^(all|aws|gcp|azure|none)$ ]]; then
                    err "Invalid cloud option: $CLOUD. Must be one of: all, aws, gcp, azure, none"
                    exit 1
                fi
                shift 2
                ;;
            --skip-ohmyzsh)
                SKIP_OHMYZSH="true"
                shift
                ;;
            --run-postfix)
                RUN_POSTFIX="${2:-}"
                shift 2
                ;;
            -h|--help)
                show_help
                ;;
            -*)
                err "Unknown flag: $1"
                show_help
                ;;
            *)
                err "Unexpected argument: $1"
                show_help
                ;;
        esac
    done
}

########################
# Main Execution
########################
main() {
    # Initialize logging
    log "Starting Arch Linux WSL Bootstrap"
    log "Script: $SCRIPT_NAME"
    log "PID: $"
    log "User: $(whoami)"
    log "PWD: $PWD"
    
    # Parse and validate arguments
    parse_args "$@"
    validate_inputs
    
    # System checks
    check_prerequisites
    
    banner "System Configuration"
    ensure_keyring
    pacman_refresh
    set_hostname
    configure_sudo
    ensure_user
    configure_wsl_systemd
    
    banner "Core Development Environment"
    install_core_packages
    configure_tmux
    setup_git
    install_code_editor
    
    banner "Shell Environment"
    setup_ohmyzsh
    
    banner "Runtime Management"
    install_asdf_and_plugins
    language_tooling
    
    banner "Infrastructure & Cloud Tools"
    install_containers_k8s_iac_cloud
    configure_docker
    
    banner "AI/ML Environment"
    install_ai_env
    gpu_instructions_note
    
    banner "Fonts & Quality of Life"
    install_fonts_and_qol
    
    banner "Validation"
    validate_installation
    
    # Execute post-installation command if provided
    if [[ -n "${RUN_POSTFIX}" ]]; then
        banner "Post-installation Command"
        LAST_STEP="Execute postfix command"
        log "Executing: $RUN_POSTFIX"
        
        if run_root "su - '${USERNAME}' -c 'cd /home/${USERNAME} && ${RUN_POSTFIX}'"; then
            log "✅ Postfix command completed successfully"
        else
            warn "⚠️  Postfix command failed (non-critical)"
            FAILED_STEPS+=("postfix-command")
        fi
    fi
    
    # Final summary
    print_summary
    
    # Success message
    banner "🎉 Bootstrap Complete!"
    log "Arch Linux WSL environment successfully configured for user: ${USERNAME}"
    log "Reboot or start a new shell session to use the new environment"
    
    # Set final exit code based on critical failures
    if ((${#FAILED_STEPS[@]} > 10)); then
        warn "Many steps failed - environment may not be fully functional"
        exit 2
    elif ((${#FAILED_STEPS[@]} > 0)); then
        warn "Some optional components failed to install"
        exit 1
    else
        log "All components installed successfully!"
        exit 0
    fi
}

# Script entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi