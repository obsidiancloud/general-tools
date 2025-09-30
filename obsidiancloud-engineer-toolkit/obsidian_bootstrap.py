#!/usr/bin/env python3
"""
Obsidian Cloud Engineer Toolkit - Python Bootstrap

Goals:
- Replace large bash scripts with a robust, idempotent Python bootstrap
- Provide clear logging, retries, and safe execution flows
- Install core development tooling on Arch-based systems (including WSL)

This script focuses on a solid foundation; it's modular so we can expand
roles (DevOps/AI/Frontend) incrementally.
"""
from __future__ import annotations

import argparse
import logging
import os
import shutil
import signal
import subprocess
import sys
import time
from dataclasses import dataclass
from pathlib import Path
from typing import List, Optional

LOG = logging.getLogger("obsidian.bootstrap")


# -----------------------------
# UI: Colors, Banner, Menu
# -----------------------------

# ANSI helpers (truecolor)
def rgb_fg(r: int, g: int, b: int) -> str:
    return f"\x1b[38;2;{r};{g};{b}m"


def rgb_bg(r: int, g: int, b: int) -> str:
    return f"\x1b[48;2;{r};{g};{b}m"


RESET = "\x1b[0m"


def lerp(a: float, b: float, t: float) -> float:
    return a + (b - a) * t


def lerp_rgb(c1: tuple[int, int, int], c2: tuple[int, int, int], t: float) -> tuple[int, int, int]:
    return (
        int(lerp(c1[0], c2[0], t)),
        int(lerp(c1[1], c2[1], t)),
        int(lerp(c1[2], c2[2], t)),
    )


def gradient_colors(steps: int, palette: list[tuple[int, int, int]]) -> list[tuple[int, int, int]]:
    if steps <= 1:
        return [palette[0]]
    segments = len(palette) - 1
    colors: list[tuple[int, int, int]] = []
    for i in range(steps):
        pos = i / max(steps - 1, 1)
        seg = min(int(pos * segments), segments - 1)
        local_t = (pos - seg / segments) * segments
        colors.append(lerp_rgb(palette[seg], palette[seg + 1], max(0.0, min(1.0, local_t))))
    return colors


def render_banner() -> str:
    # Title and subtitle (centered later inside a bordered box)
    raw_title = "OBSIDIAN CLOUD"
    subtitle_text = "ENGINEERING TOOLKIT"

    # Try to render a large ASCII banner via pyfiglet (3x visual impact)
    title_lines: list[str]
    subtitle_lines: list[str]
    try:
        from pyfiglet import Figlet  # type: ignore

        # Larger font for title; slightly smaller for subtitle
        title_fig = Figlet(font="big")
        sub_fig = Figlet(font="standard")
        title_lines = title_fig.renderText(raw_title).rstrip("\n").splitlines()
        subtitle_lines = sub_fig.renderText(subtitle_text).rstrip("\n").splitlines()
    except Exception:
        # Fallback: spaced, bold title on a single line; plain subtitle
        spaced_title = " ".join(list(raw_title))
        title_bold = "\x1b[1m" + spaced_title + RESET
        title_lines = [title_bold]
        subtitle_lines = [subtitle_text]

    # Compute box width from widest rendered line
    content_width = 0
    for line in title_lines + subtitle_lines:
        content_width = max(content_width, len(line))
    padding = 4
    box_width = content_width + padding * 2

    # Moody blue -> black -> purple gradient
    palette = [
        (40, 55, 90),   # deep moody blue
        (8, 8, 12),     # near black
        (70, 35, 110),  # moody purple
    ]
    colors = gradient_colors(box_width, palette)

    # Build border lines
    def top_bottom() -> str:
        parts = []
        for i in range(box_width):
            r, g, b = colors[i]
            parts.append(f"{rgb_fg(r, g, b)}█{RESET}")
        return "".join(parts)

    # Compose boxed content
    lines: list[str] = []
    lines.append(top_bottom())

    # Empty spacer line inside with gradient corners
    def empty_line() -> str:
        left = f"{rgb_fg(*colors[0])}█{RESET}"
        right = f"{rgb_fg(*colors[-1])}█{RESET}"
        return f"{left}{' ' * (box_width - 2)}{right}"

    lines.append(empty_line())

    # Title lines centered
    for t in title_lines:
        pad_total = box_width - 2 - len(t)
        left_pad = max(0, pad_total // 2)
        right_pad = max(0, pad_total - left_pad)
        left = f"{rgb_fg(*colors[0])}█{RESET}"
        right = f"{rgb_fg(*colors[-1])}█{RESET}"
        lines.append(f"{left}{' ' * left_pad}{t}{' ' * right_pad}{right}")

    # Spacer
    lines.append(empty_line())

    # Subtitle (may be multi-line from figlet) centered
    for s in subtitle_lines:
        pad_total = box_width - 2 - len(s)
        left_pad = max(0, pad_total // 2)
        right_pad = max(0, pad_total - left_pad)
        left = f"{rgb_fg(*colors[0])}█{RESET}"
        right = f"{rgb_fg(*colors[-1])}█{RESET}"
        lines.append(f"{left}{' ' * left_pad}{s}{' ' * right_pad}{right}")

    # Bottom spacer and border
    lines.append(empty_line())
    lines.append(top_bottom())

    # Center overall banner horizontally if terminal width known
    try:
        cols = shutil.get_terminal_size().columns
    except Exception:
        cols = box_width
    centered = []
    for ln in lines:
        if cols > box_width:
            margin = (cols - box_width) // 2
            centered.append(" " * margin + ln)
        else:
            centered.append(ln)
    return "\n".join(centered)


def show_banner():
    banner = render_banner()
    print(banner)
    print()


def show_main_menu() -> Optional[str]:
    print("\n" + "="*60)
    print("🚀 OBSIDIAN CLOUD ENGINEERING TOOLKIT")
    print("="*60)
    print("Select a category:")
    print("  1) 🔧 DevOps Tools")
    print("  2) ☁️  Cloud CLIs") 
    print("  3) 🤖 AI/ML Tools")
    print("  4) 💻 System Tools")
    print("  5) 🎯 Full Bootstrap (All Categories)")
    print("  6) ⚙️  System Setup Only")
    print("  7) 🚪 Exit")
    print("="*60)
    try:
        choice = input("Enter choice [1-7]: ").strip()
    except (EOFError, KeyboardInterrupt):
        return None
    return choice

def show_devops_menu() -> Optional[str]:
    print("\n" + "="*50)
    print("🔧 DEVOPS TOOLS")
    print("="*50)
    print("  1) ☸️  Kubernetes Tools (kubectl, helm, k9s, minikube)")
    print("  2) 🐳 Container Tools (docker, podman, dive, ctop)")
    print("  3) 🏗️  Infrastructure as Code (terraform, ansible, pulumi)")
    print("  4) 📊 Monitoring Tools (prometheus, grafana)")
    print("  5) 🔒 Security Tools (trivy, checkov, sops, vault)")
    print("  6) ⚡ Load Testing (k6, artillery, wrk)")
    print("  7) 🎯 All DevOps Tools")
    print("  8) ⬅️  Back to Main Menu")
    print("="*50)
    try:
        choice = input("Enter choice [1-8]: ").strip()
    except (EOFError, KeyboardInterrupt):
        return None
    return choice

def show_cloud_menu() -> Optional[str]:
    print("\n" + "="*50)
    print("☁️ CLOUD CLIS")
    print("="*50)
    print("  1) 🟠 AWS Tools (aws-cli, sam-cli, eksctl)")
    print("  2) 🔵 GCP Tools (gcloud, skaffold)")
    print("  3) 🟦 Azure Tools (az, bicep)")
    print("  4) 🌐 Multi-Cloud Tools (pulumi, crossplane)")
    print("  5) 🎯 All Cloud Tools")
    print("  6) ⬅️  Back to Main Menu")
    print("="*50)
    try:
        choice = input("Enter choice [1-6]: ").strip()
    except (EOFError, KeyboardInterrupt):
        return None
    return choice

def show_aiml_menu() -> Optional[str]:
    print("\n" + "="*50)
    print("🤖 AI/ML TOOLS")
    print("="*50)
    print("  1) 🐍 Python Environment (micromamba, poetry, pipx)")
    print("  2) 🧠 ML Frameworks (pytorch, tensorflow, scikit-learn)")
    print("  3) 📊 Data Tools (jupyter, pandas, matplotlib)")
    print("  4) 🔬 MLOps Tools (mlflow, wandb, dvc)")
    print("  5) 🤖 AI APIs (openai, langchain, transformers)")
    print("  6) 🎯 All AI/ML Tools")
    print("  7) ⬅️  Back to Main Menu")
    print("="*50)
    try:
        choice = input("Enter choice [1-7]: ").strip()
    except (EOFError, KeyboardInterrupt):
        return None
    return choice

def show_system_menu() -> Optional[str]:
    print("\n" + "="*50)
    print("💻 SYSTEM TOOLS")
    print("="*50)
    print("  1) 🐚 Shell Tools (zsh, oh-my-zsh, powerlevel10k)")
    print("  2) 📟 Terminal Tools (tmux, screen, zellij)")
    print("  3) 📁 File Management (ranger, fzf, ripgrep, bat)")
    print("  4) 📈 System Monitoring (htop, btop, glances)")
    print("  5) 🌐 Network Tools (nmap, wireshark, httpie)")
    print("  6) ✏️  Editors (neovim, vim, vscode)")
    print("  7) 🔤 Fonts (nerd-fonts, jetbrains-mono)")
    print("  8) 🎯 All System Tools")
    print("  9) ⬅️  Back to Main Menu")
    print("="*50)
    try:
        choice = input("Enter choice [1-9]: ").strip()
    except (EOFError, KeyboardInterrupt):
        return None
    return choice


# -----------------------------
# Dataclasses & Config
# -----------------------------
@dataclass
class Config:
    username: str = "dev"
    password: Optional[str] = None
    hostname: str = "arch-wsl"
    enable_systemd: bool = False
    ai_env: bool = True
    gpu_notes: bool = False
    cloud: str = "all"  # all|aws|gcp|azure|none
    skip_ohmyzsh: bool = False
    run_postfix: Optional[str] = None
    log_level: str = "INFO"


# -----------------------------
# Utilities
# -----------------------------
class CmdError(Exception):
    pass


def run(cmd: List[str], *, check: bool = True, timeout: int = 900, env: Optional[dict] = None,
        capture: bool = True) -> subprocess.CompletedProcess:
    LOG.debug("RUN: %s", " ".join(cmd))
    try:
        proc = subprocess.run(
            cmd,
            text=True,
            capture_output=capture,
            timeout=timeout,
            env=env,
            check=check,
        )
        if proc.stdout:
            LOG.debug("STDOUT: %s", proc.stdout.strip())
        if proc.stderr:
            LOG.debug("STDERR: %s", proc.stderr.strip())
        return proc
    except subprocess.CalledProcessError as e:
        LOG.error("Command failed (%s): %s", e.returncode, " ".join(cmd))
        if e.stdout:
            LOG.error("STDOUT: %s", e.stdout.strip())
        if e.stderr:
            LOG.error("STDERR: %s", e.stderr.strip())
        raise CmdError(str(e)) from e
    except subprocess.TimeoutExpired as e:
        LOG.error("Command timeout after %ss: %s", timeout, " ".join(cmd))
        raise CmdError(str(e)) from e


def run_as_user(user: str, cmd: List[str], **kwargs) -> subprocess.CompletedProcess:
    return run(["sudo", "-u", user] + cmd, **kwargs)


def ensure_root():
    if os.geteuid() != 0:
        # We use sudo per command; not requiring root here keeps flexibility.
        return False
    return True


# -----------------------------
# Preconditions
# -----------------------------
class Preconditions:
    @staticmethod
    def arch_like() -> bool:
        if not Path("/etc/os-release").exists():
            LOG.error("/etc/os-release not found; not a Linux system")
            return False
        data = {}
        for line in Path("/etc/os-release").read_text().splitlines():
            if "=" in line:
                k, v = line.split("=", 1)
                data[k] = v.strip('"')
        id_ = data.get("ID", "").lower()
        id_like = data.get("ID_LIKE", "").lower()
        if id_ in ("arch", "cachyos", "manjaro") or "arch" in id_like or Path("/etc/arch-release").exists():
            LOG.info("✅ Arch-based system detected: %s", data.get("PRETTY_NAME", id_))
            return True
        LOG.error("❌ Not an Arch-based system: %s", data.get("PRETTY_NAME", "unknown"))
        return False

    @staticmethod
    def network_ok() -> bool:
        try:
            run(["ping", "-c", "1", "8.8.8.8"], timeout=30)
            LOG.info("✅ Network connectivity OK")
            return True
        except CmdError:
            LOG.error("❌ Network connectivity failed")
            return False

    @staticmethod
    def pacman_ok() -> bool:
        if shutil.which("pacman"):
            LOG.info("✅ pacman available")
            return True
        LOG.error("❌ pacman not found")
        return False

    @staticmethod
    def sudo_ok() -> bool:
        try:
            run(["sudo", "-n", "true"], timeout=10)
            LOG.info("✅ sudo access OK")
            return True
        except CmdError:
            LOG.error("❌ sudo access failed (require passwordless or cached auth)")
            return False

    @staticmethod
    def disk_ok(min_gb: int = 2) -> bool:
        proc = run(["df", "/"], capture=True)
        lines = proc.stdout.strip().splitlines()
        if len(lines) >= 2:
            avail_kb = int(lines[1].split()[3])
            avail_gb = avail_kb // (1024 * 1024)
            if avail_kb >= min_gb * 1024 * 1024:
                LOG.info("✅ Disk space OK (%dGB available)", avail_gb)
                return True
            LOG.error("❌ Insufficient disk space (%dGB available, need %dGB+)", avail_gb, min_gb)
        return False


# -----------------------------
# Package Management
# -----------------------------
class Packages:
    @staticmethod
    def ensure_keyring():
        if not Path("/etc/pacman.d/gnupg/pubring.gpg").exists():
            LOG.info("Initializing pacman keyring...")
            run(["sudo", "pacman-key", "--init"])
            run(["sudo", "pacman-key", "--populate", "archlinux"]) 
        else:
            LOG.info("Pacman keyring already initialized")

    @staticmethod
    def pacman_refresh():
        LOG.info("Refreshing packages (pacman -Syyu)...")
        attempts = 3
        for i in range(1, attempts + 1):
            try:
                run(["sudo", "pacman", "-Syyu", "--noconfirm"], timeout=1800)
                LOG.info("✅ Pacman refresh successful")
                return
            except CmdError:
                if i < attempts:
                    LOG.warning("Pacman refresh failed (attempt %d/%d). Retrying...", i, attempts)
                    time.sleep(5)
                else:
                    raise

    @staticmethod
    def install_pacman(pkgs: List[str]):
        if not pkgs:
            return
        LOG.info("Installing with pacman: %s", ", ".join(pkgs))
        run(["sudo", "pacman", "-S", "--noconfirm", "--needed", *pkgs])

    @staticmethod
    def ensure_yay(username: str):
        if shutil.which("yay"):
            LOG.info("yay already installed")
            return
        LOG.info("Installing yay (AUR helper)...")
        # Dependencies
        Packages.install_pacman(["base-devel", "git"]) 
        builddir = Path("/opt/yay")
        if not builddir.exists():
            run(["sudo", "git", "clone", "https://aur.archlinux.org/yay.git", str(builddir)])
            run(["sudo", "chown", "-R", f"{username}:{username}", str(builddir)])
        run_as_user(username, ["bash", "-lc", f"cd {builddir} && makepkg -si --noconfirm --needed"]) 
        run(["sudo", "rm", "-rf", str(builddir)], check=False)

    @staticmethod
    def install_aur(username: str, pkgs: List[str]):
        if not pkgs:
            return
        Packages.ensure_yay(username)
        LOG.info("Installing from AUR: %s", ", ".join(pkgs))
        for pkg in pkgs:
            run_as_user(username, ["bash", "-lc", f"yay -S --noconfirm --needed --batchinstall --removemake {pkg}"])


# -----------------------------
# System Configuration
# -----------------------------
class System:
    @staticmethod
    def set_hostname(hostname: str):
        LOG.info("Setting hostname: %s", hostname)
        run(["sudo", "bash", "-lc", f"echo '{hostname}' > /etc/hostname"]) 
        run(["sudo", "hostname", hostname])
        # hosts entries
        def append_once(path: str, line: str):
            run(["sudo", "bash", "-lc", f"grep -qxF '{line}' {path} || echo '{line}' | tee -a {path}"])
        append_once("/etc/hosts", "127.0.0.1 localhost")
        append_once("/etc/hosts", f"127.0.1.1 {hostname}")
        append_once("/etc/hosts", "::1 localhost")

    @staticmethod
    def ensure_user(username: str, password: Optional[str]):
        try:
            run(["id", "-u", username])
            LOG.info("User %s already exists", username)
        except CmdError:
            LOG.info("Creating user %s (shell=zsh, group=wheel)", username)
            Packages.install_pacman(["zsh"]) 
            run(["sudo", "useradd", "-m", "-s", "/bin/zsh", "-G", "wheel", username])
            if password:
                run(["sudo", "bash", "-lc", f"echo '{username}:{password}' | chpasswd"]) 
            else:
                LOG.warning("No password provided. You can set later with: sudo passwd %s", username)
        # Ensure shell and home ownership
        run(["sudo", "chsh", "-s", "/bin/zsh", username], check=False)
        run(["sudo", "chown", "-R", f"{username}:{username}", f"/home/{username}"], check=False)

    @staticmethod
    def configure_sudo():
        LOG.info("Configuring sudo/wheel policy")
        Packages.install_pacman(["sudo"]) 
        content = (
            "%wheel ALL=(ALL:ALL) ALL\n"
            "Defaults passwd_tries=3\n"
            "Defaults badpass_message=\"Sorry, try again.\"\n"
            "Defaults lecture=once\n"
            "Defaults requiretty\n"
        )
        run(["sudo", "bash", "-lc", f"echo \"{content}\" > /etc/sudoers.d/10-wheel && chmod 0440 /etc/sudoers.d/10-wheel"]) 


# -----------------------------
# Specialized Tooling Classes
# -----------------------------

class DevOpsTools:
    """DevOps and Infrastructure tooling installation."""
    
    def __init__(self, username: str):
        self.username = username
    
    def install_kubernetes_tools(self):
        """Install Kubernetes ecosystem tools."""
        LOG.info("Installing Kubernetes tools...")
        
        # Core K8s tools (pacman)
        k8s_pacman = [
            "kubectl", "helm", "kustomize", "kind"
        ]
        Packages.install_pacman(k8s_pacman)
        
        # Advanced K8s tools (AUR)
        k8s_aur = [
            "k9s", "minikube", "k3s-bin", "kubectx", "kubens", 
            "stern", "flux-cli", "argocd-cli", "istioctl-bin"
        ]
        Packages.install_aur(self.username, k8s_aur)
    
    def install_container_tools(self):
        """Install container runtime and management tools."""
        LOG.info("Installing container tools...")
        
        # Core container tools (pacman)
        container_pacman = [
            "docker", "docker-compose", "docker-buildx", 
            "podman", "buildah", "skopeo"
        ]
        Packages.install_pacman(container_pacman)
        
        # Advanced container tools (AUR)
        container_aur = [
            "dive", "ctop", "lazydocker", "hadolint-bin"
        ]
        Packages.install_aur(self.username, container_aur)
    
    def install_iac_tools(self):
        """Install Infrastructure as Code tools."""
        LOG.info("Installing Infrastructure as Code tools...")
        
        # Core IaC tools (pacman)
        iac_pacman = [
            "terraform", "tflint", "ansible", "packer", "vagrant"
        ]
        Packages.install_pacman(iac_pacman)
        
        # Advanced IaC tools (AUR)
        iac_aur = [
            "terragrunt", "pulumi-bin", "crossplane-cli", 
            "terraform-ls", "ansible-lint"
        ]
        Packages.install_aur(self.username, iac_aur)
    
    def install_monitoring_tools(self):
        """Install monitoring and observability tools."""
        LOG.info("Installing monitoring tools...")
        
        # Monitoring tools (pacman)
        monitoring_pacman = [
            "prometheus", "grafana", "node-exporter"
        ]
        Packages.install_pacman(monitoring_pacman)
        
        # Additional monitoring (AUR)
        monitoring_aur = [
            "alertmanager", "blackbox-exporter"
        ]
        Packages.install_aur(self.username, monitoring_aur)
    
    def install_security_tools(self):
        """Install security and compliance tools."""
        LOG.info("Installing security tools...")
        
        # Security tools (pacman)
        security_pacman = [
            "gnupg", "pass", "age"
        ]
        Packages.install_pacman(security_pacman)
        
        # Advanced security tools (AUR)
        security_aur = [
            "trivy", "checkov", "sops", "vault", "cosign"
        ]
        Packages.install_aur(self.username, security_aur)
    
    def install_load_testing_tools(self):
        """Install load testing and performance tools."""
        LOG.info("Installing load testing tools...")
        
        # Load testing tools (AUR)
        load_test_aur = [
            "k6-bin", "artillery", "wrk", "hey"
        ]
        Packages.install_aur(self.username, load_test_aur)
    
    def install_all(self):
        """Install all DevOps tools."""
        LOG.info("Installing all DevOps tools...")
        self.install_kubernetes_tools()
        self.install_container_tools()
        self.install_iac_tools()
        self.install_monitoring_tools()
        self.install_security_tools()
        self.install_load_testing_tools()


class CloudTools:
    """Cloud provider CLI tools and utilities."""
    
    def __init__(self, username: str):
        self.username = username
    
    def install_aws_tools(self):
        """Install AWS CLI tools and utilities."""
        LOG.info("Installing AWS tools...")
        
        # Core AWS tools (pacman)
        aws_pacman = ["aws-cli-v2"]
        Packages.install_pacman(aws_pacman)
        
        # Advanced AWS tools (AUR)
        aws_aur = [
            "session-manager-plugin", "eksctl-bin", "aws-vault"
        ]
        Packages.install_aur(self.username, aws_aur)
        
        # AWS tools via pipx
        aws_pipx = [
            "aws-sam-cli", "aws-cdk-lib", "copilot-cli"
        ]
        for tool in aws_pipx:
            try:
                run_as_user(self.username, ["pipx", "install", tool])
                LOG.info(f"✅ Installed {tool} via pipx")
            except CmdError:
                LOG.warning(f"Failed to install {tool} via pipx")
    
    def install_gcp_tools(self):
        """Install Google Cloud Platform tools."""
        LOG.info("Installing GCP tools...")
        
        # GCP tools (AUR)
        gcp_aur = ["google-cloud-cli", "skaffold"]
        Packages.install_aur(self.username, gcp_aur)
    
    def install_azure_tools(self):
        """Install Microsoft Azure tools."""
        LOG.info("Installing Azure tools...")
        
        # Azure tools (AUR)
        azure_aur = ["azure-cli", "bicep"]
        Packages.install_aur(self.username, azure_aur)
    
    def install_multicloud_tools(self):
        """Install multi-cloud and cloud-agnostic tools."""
        LOG.info("Installing multi-cloud tools...")
        
        # Multi-cloud tools (AUR)
        multicloud_aur = ["pulumi-bin", "crossplane-cli"]
        Packages.install_aur(self.username, multicloud_aur)
    
    def install_all(self):
        """Install all cloud tools."""
        LOG.info("Installing all cloud tools...")
        self.install_aws_tools()
        self.install_gcp_tools()
        self.install_azure_tools()
        self.install_multicloud_tools()


class AIMLTools:
    """AI/ML development tools and frameworks."""
    
    def __init__(self, username: str):
        self.username = username
    
    def install_python_env(self):
        """Install Python environment management tools."""
        LOG.info("Installing Python environment tools...")
        
        # Python tools (pacman)
        python_pacman = [
            "python", "python-pip", "python-pipx", "python-virtualenv"
        ]
        Packages.install_pacman(python_pacman)
        
        # Install micromamba
        self._install_micromamba()
        
        # Python env tools via pipx
        python_pipx = ["poetry", "pipenv", "conda-lock"]
        for tool in python_pipx:
            try:
                run_as_user(self.username, ["pipx", "install", tool])
                LOG.info(f"✅ Installed {tool} via pipx")
            except CmdError:
                LOG.warning(f"Failed to install {tool} via pipx")
    
    def _install_micromamba(self):
        """Install micromamba for conda environment management."""
        try:
            # Check if already installed
            run_as_user(self.username, ["micromamba", "--version"])
            LOG.info("micromamba already installed")
            return
        except CmdError:
            pass
        
        LOG.info("Installing micromamba...")
        install_script = """
        curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest | tar -xvj bin/micromamba
        mkdir -p ~/.local/bin
        mv bin/micromamba ~/.local/bin/
        """
        try:
            run_as_user(self.username, ["bash", "-c", install_script])
            LOG.info("✅ Installed micromamba")
        except CmdError:
            LOG.warning("Failed to install micromamba")
    
    def install_ml_frameworks(self):
        """Install core ML frameworks via micromamba."""
        LOG.info("Installing ML frameworks...")
        
        # Create AI environment with core ML packages
        ai_packages = [
            "python>=3.11", "numpy", "pandas", "scipy", "scikit-learn",
            "pytorch", "torchvision", "torchaudio", "cpuonly",
            "xgboost", "lightgbm", "catboost"
        ]
        
        create_cmd = f"micromamba create -y -n ai -c conda-forge -c pytorch --strict-channel-priority {' '.join(ai_packages)}"
        try:
            run_as_user(self.username, ["bash", "-c", create_cmd])
            LOG.info("✅ Created AI environment with ML frameworks")
        except CmdError:
            LOG.warning("Failed to create AI environment")
    
    def install_data_tools(self):
        """Install data science and visualization tools."""
        LOG.info("Installing data science tools...")
        
        # Jupyter and data viz tools
        data_packages = [
            "jupyterlab", "ipykernel", "ipywidgets",
            "matplotlib", "seaborn", "plotly", "bokeh",
            "streamlit", "dash"
        ]
        
        for pkg in data_packages:
            try:
                run_as_user(self.username, ["micromamba", "run", "-n", "ai", "pip", "install", pkg])
                LOG.info(f"✅ Installed {pkg}")
            except CmdError:
                LOG.warning(f"Failed to install {pkg}")
    
    def install_mlops_tools(self):
        """Install MLOps and experiment tracking tools."""
        LOG.info("Installing MLOps tools...")
        
        mlops_packages = [
            "mlflow", "wandb", "dvc", "great-expectations", "kedro",
            "optuna", "ray", "prefect"
        ]
        
        for pkg in mlops_packages:
            try:
                run_as_user(self.username, ["micromamba", "run", "-n", "ai", "pip", "install", pkg])
                LOG.info(f"✅ Installed {pkg}")
            except CmdError:
                LOG.warning(f"Failed to install {pkg}")
    
    def install_ai_apis(self):
        """Install AI API libraries and tools."""
        LOG.info("Installing AI API libraries...")
        
        ai_packages = [
            "openai", "anthropic", "langchain", "transformers", 
            "datasets", "huggingface-hub", "tiktoken"
        ]
        
        for pkg in ai_packages:
            try:
                run_as_user(self.username, ["micromamba", "run", "-n", "ai", "pip", "install", pkg])
                LOG.info(f"✅ Installed {pkg}")
            except CmdError:
                LOG.warning(f"Failed to install {pkg}")
    
    def install_all(self):
        """Install all AI/ML tools."""
        LOG.info("Installing all AI/ML tools...")
        self.install_python_env()
        self.install_ml_frameworks()
        self.install_data_tools()
        self.install_mlops_tools()
        self.install_ai_apis()


class SystemTools:
    """System utilities, shell tools, and productivity enhancers."""
    
    def __init__(self, username: str):
        self.username = username
    
    def install_shell_tools(self):
        """Install advanced shell and prompt tools."""
        LOG.info("Installing shell tools...")
        
        # Shell tools (pacman)
        shell_pacman = ["zsh", "fish", "bash-completion"]
        Packages.install_pacman(shell_pacman)
        
        # Advanced shell tools (AUR)
        shell_aur = ["starship", "oh-my-zsh-git"]
        Packages.install_aur(self.username, shell_aur)
        
        # Install Oh My Zsh and Powerlevel10k manually
        self._install_ohmyzsh()
        self._install_powerlevel10k()
    
    def _install_ohmyzsh(self):
        """Install Oh My Zsh shell framework."""
        omz_dir = f"/home/{self.username}/.oh-my-zsh"
        if Path(omz_dir).exists():
            LOG.info("Oh My Zsh already installed")
            return
        
        LOG.info("Installing Oh My Zsh...")
        install_cmd = "curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh | bash -s -- --unattended"
        try:
            run_as_user(self.username, ["bash", "-c", install_cmd])
            LOG.info("✅ Installed Oh My Zsh")
        except CmdError:
            LOG.warning("Failed to install Oh My Zsh")
    
    def _install_powerlevel10k(self):
        """Install Powerlevel10k theme for Oh My Zsh."""
        p10k_dir = f"/home/{self.username}/.oh-my-zsh/custom/themes/powerlevel10k"
        if Path(p10k_dir).exists():
            LOG.info("Powerlevel10k already installed")
            return
        
        LOG.info("Installing Powerlevel10k...")
        try:
            run_as_user(self.username, [
                "git", "clone", "--depth=1", 
                "https://github.com/romkatv/powerlevel10k.git",
                p10k_dir
            ])
            LOG.info("✅ Installed Powerlevel10k")
        except CmdError:
            LOG.warning("Failed to install Powerlevel10k")
    
    def install_terminal_tools(self):
        """Install terminal multiplexers and utilities."""
        LOG.info("Installing terminal tools...")
        
        # Terminal tools (pacman)
        terminal_pacman = ["tmux", "screen"]
        Packages.install_pacman(terminal_pacman)
        
        # Advanced terminal tools (AUR)
        terminal_aur = ["zellij"]
        Packages.install_aur(self.username, terminal_aur)
    
    def install_file_tools(self):
        """Install file management and search tools."""
        LOG.info("Installing file management tools...")
        
        # File tools (pacman)
        file_pacman = [
            "fd", "ripgrep", "fzf", "bat", "eza", "tree", "zoxide",
            "rsync", "rclone"
        ]
        Packages.install_pacman(file_pacman)
        
        # Advanced file tools (AUR)
        file_aur = ["ranger", "nnn", "lf", "broot"]
        Packages.install_aur(self.username, file_aur)
    
    def install_system_monitoring(self):
        """Install system monitoring and performance tools."""
        LOG.info("Installing system monitoring tools...")
        
        # Monitoring tools (pacman)
        monitor_pacman = ["htop", "iotop", "nethogs", "iftop"]
        Packages.install_pacman(monitor_pacman)
        
        # Advanced monitoring (AUR)
        monitor_aur = ["btop", "glances", "bandwhich"]
        Packages.install_aur(self.username, monitor_aur)
    
    def install_network_tools(self):
        """Install network analysis and debugging tools."""
        LOG.info("Installing network tools...")
        
        # Network tools (pacman)
        network_pacman = [
            "nmap", "wireshark-cli", "tcpdump", "netcat", 
            "curl", "wget", "httpie", "bind-tools"
        ]
        Packages.install_pacman(network_pacman)
    
    def install_editors(self):
        """Install text editors and IDEs."""
        LOG.info("Installing editors...")
        
        # Editors (pacman)
        editor_pacman = ["neovim", "vim", "emacs"]
        Packages.install_pacman(editor_pacman)
        
        # VS Code (AUR)
        editor_aur = ["visual-studio-code-bin"]
        Packages.install_aur(self.username, editor_aur)
    
    def install_fonts(self):
        """Install development and terminal fonts."""
        LOG.info("Installing fonts...")
        
        # Fonts (pacman)
        font_pacman = [
            "noto-fonts", "noto-fonts-emoji", "ttf-liberation", 
            "ttf-dejavu", "adobe-source-code-pro-fonts"
        ]
        Packages.install_pacman(font_pacman)
        
        # Nerd fonts (AUR)
        font_aur = [
            "ttf-meslo-nerd-font-powerlevel10k", "ttf-fira-code",
            "ttf-jetbrains-mono", "ttf-nerd-fonts-symbols"
        ]
        Packages.install_aur(self.username, font_aur)
        
        # Update font cache
        try:
            run(["sudo", "fc-cache", "-fv"])
            LOG.info("✅ Updated font cache")
        except CmdError:
            LOG.warning("Failed to update font cache")
    
    def install_all(self):
        """Install all system tools."""
        LOG.info("Installing all system tools...")
        self.install_shell_tools()
        self.install_terminal_tools()
        self.install_file_tools()
        self.install_system_monitoring()
        self.install_network_tools()
        self.install_editors()
        self.install_fonts()


# -----------------------------
# Legacy Core Tooling (for compatibility)
# -----------------------------
class Tooling:
    @staticmethod
    def core_packages():
        return [
            # base
            "base-devel", "git", "curl", "wget", "gnupg", "sudo", "zsh",
            "unzip", "zip", "tar", "gzip", "xz", "p7zip", "openssh",
            "gawk", "sed", "coreutils", "findutils", "which",
            # modern cli
            "jq", "yq", "ripgrep", "fd", "fzf", "bat", "eza", "zoxide", "tree",
            "htop", "ncdu", "fastfetch",
            # docs
            "man-db", "man-pages",
            # compilers
            "gcc", "clang", "llvm", "lldb", "gdb", "cmake", "make", "ninja", "pkgconf",
            # dev utils
            "pre-commit", "shellcheck", "shfmt", "neovim", "rsync", "rlwrap", "tmux", "git-delta",
            # networking
            "net-tools", "bind-tools",
        ]

    @staticmethod
    def install_core():
        Packages.install_pacman(Tooling.core_packages())

    @staticmethod
    def containers_k8s_iac(username: str, cloud: str):
        # Containers
        Packages.install_pacman(["docker", "docker-compose", "docker-buildx", "podman", "buildah", "skopeo"]) 
        # Kubernetes
        Packages.install_pacman(["kubectl", "helm", "kustomize", "kind", "k9s", "stern"]) 
        Packages.install_aur(username, ["kubectx", "kubens", "kubeseal", "flux-cli", "argocd-cli"]) 
        # IaC
        Packages.install_pacman(["terraform", "tflint", "ansible", "packer", "vagrant"]) 
        Packages.install_pacman(["direnv", "gh"]) 
        Packages.install_pacman(["jq", "yq"])  # ensure available
        # Cloud CLIs
        if cloud in ("all", "aws"):
            Packages.install_pacman(["aws-cli-v2"]) 
            Packages.install_aur(username, ["session-manager-plugin"]) 
        if cloud in ("all", "gcp"):
            Packages.install_aur(username, ["google-cloud-cli"]) 
        if cloud in ("all", "azure"):
            Packages.install_aur(username, ["azure-cli"]) 

    @staticmethod
    def configure_docker(username: str):
        # Add user to docker group and drop a sane daemon.json
        run(["sudo", "usermod", "-aG", "docker", username], check=False)
        daemon = (
            '{\n'
            '  "log-driver": "json-file",\n'
            '  "log-opts": {"max-size": "10m", "max-file": "3"},\n'
            '  "storage-driver": "overlay2",\n'
            '  "features": {"buildkit": true}\n'
            '}\n'
        )
        run(["sudo", "bash", "-lc", f"mkdir -p /etc/docker && cat > /etc/docker/daemon.json <<'JSON'\n{daemon}JSON\n"]) 


# -----------------------------
# Main Orchestrator
# -----------------------------
class Bootstrap:
    def __init__(self, cfg: Config):
        self.cfg = cfg
        self.failed: List[str] = []
        self.log_path = Path(f"/tmp/obsidian-bootstrap.{int(time.time())}.log")

    def setup_logging(self):
        level = getattr(logging, self.cfg.log_level.upper(), logging.INFO)
        logging.basicConfig(
            level=level,
            format="%(asctime)s [%(levelname)s] %(message)s",
            handlers=[
                logging.FileHandler(self.log_path),
                logging.StreamHandler(sys.stdout),
            ],
        )
        LOG.info("Log file: %s", self.log_path)

    def handle_signals(self):
        def _handler(signum, frame):
            LOG.warning("Interrupted (signal %s). Exiting.", signum)
            sys.exit(1)
        signal.signal(signal.SIGINT, _handler)
        signal.signal(signal.SIGTERM, _handler)

    def prerequisites(self):
        ok = (
            Preconditions.arch_like()
            and Preconditions.network_ok()
            and Preconditions.pacman_ok()
            and Preconditions.sudo_ok()
            and Preconditions.disk_ok(2)
        )
        if not ok:
            raise SystemExit(1)

    def system_setup(self):
        Packages.ensure_keyring()
        Packages.pacman_refresh()
        System.set_hostname(self.cfg.hostname)
        System.configure_sudo()
        System.ensure_user(self.cfg.username, self.cfg.password)

    def core_setup(self):
        Tooling.install_core()

    def infra_setup(self):
        Tooling.containers_k8s_iac(self.cfg.username, self.cfg.cloud)
        Tooling.configure_docker(self.cfg.username)

    def run_postfix(self):
        if self.cfg.run_postfix:
            LOG.info("Running postfix command as %s: %s", self.cfg.username, self.cfg.run_postfix)
            try:
                run_as_user(self.cfg.username, ["bash", "-lc", f"cd /home/{self.cfg.username} && {self.cfg.run_postfix}"])
            except CmdError:
                LOG.warning("Postfix command failed (non-critical)")

    def _run_interactive_menu(self):
        """Run the interactive hierarchical menu system."""
        while True:
            choice = show_main_menu()
            if choice == "1":  # DevOps Tools
                self._handle_devops_menu()
            elif choice == "2":  # Cloud CLIs
                self._handle_cloud_menu()
            elif choice == "3":  # AI/ML Tools
                self._handle_aiml_menu()
            elif choice == "4":  # System Tools
                self._handle_system_menu()
            elif choice == "5":  # Full Bootstrap
                LOG.info("Running full bootstrap...")
                return  # Exit menu and run full bootstrap
            elif choice == "6":  # System Setup Only
                self.prerequisites()
                self.system_setup()
                LOG.info("System setup complete.")
            elif choice == "7" or choice is None:  # Exit
                LOG.info("Exiting per user request.")
                sys.exit(0)
            else:
                print("Invalid choice. Please select 1-7.")
    
    def _handle_devops_menu(self):
        """Handle DevOps tools submenu."""
        devops = DevOpsTools(self.cfg.username)
        while True:
            choice = show_devops_menu()
            if choice == "1":
                self.prerequisites()
                self.system_setup()
                devops.install_kubernetes_tools()
            elif choice == "2":
                self.prerequisites()
                self.system_setup()
                devops.install_container_tools()
            elif choice == "3":
                self.prerequisites()
                self.system_setup()
                devops.install_iac_tools()
            elif choice == "4":
                self.prerequisites()
                self.system_setup()
                devops.install_monitoring_tools()
            elif choice == "5":
                self.prerequisites()
                self.system_setup()
                devops.install_security_tools()
            elif choice == "6":
                self.prerequisites()
                self.system_setup()
                devops.install_load_testing_tools()
            elif choice == "7":
                self.prerequisites()
                self.system_setup()
                devops.install_all()
            elif choice == "8" or choice is None:
                break
            else:
                print("Invalid choice. Please select 1-8.")
    
    def _handle_cloud_menu(self):
        """Handle Cloud CLIs submenu."""
        cloud = CloudTools(self.cfg.username)
        while True:
            choice = show_cloud_menu()
            if choice == "1":
                self.prerequisites()
                self.system_setup()
                cloud.install_aws_tools()
            elif choice == "2":
                self.prerequisites()
                self.system_setup()
                cloud.install_gcp_tools()
            elif choice == "3":
                self.prerequisites()
                self.system_setup()
                cloud.install_azure_tools()
            elif choice == "4":
                self.prerequisites()
                self.system_setup()
                cloud.install_multicloud_tools()
            elif choice == "5":
                self.prerequisites()
                self.system_setup()
                cloud.install_all()
            elif choice == "6" or choice is None:
                break
            else:
                print("Invalid choice. Please select 1-6.")
    
    def _handle_aiml_menu(self):
        """Handle AI/ML tools submenu."""
        aiml = AIMLTools(self.cfg.username)
        while True:
            choice = show_aiml_menu()
            if choice == "1":
                self.prerequisites()
                self.system_setup()
                aiml.install_python_env()
            elif choice == "2":
                self.prerequisites()
                self.system_setup()
                aiml.install_ml_frameworks()
            elif choice == "3":
                self.prerequisites()
                self.system_setup()
                aiml.install_data_tools()
            elif choice == "4":
                self.prerequisites()
                self.system_setup()
                aiml.install_mlops_tools()
            elif choice == "5":
                self.prerequisites()
                self.system_setup()
                aiml.install_ai_apis()
            elif choice == "6":
                self.prerequisites()
                self.system_setup()
                aiml.install_all()
            elif choice == "7" or choice is None:
                break
            else:
                print("Invalid choice. Please select 1-7.")
    
    def _handle_system_menu(self):
        """Handle System tools submenu."""
        system = SystemTools(self.cfg.username)
        while True:
            choice = show_system_menu()
            if choice == "1":
                self.prerequisites()
                self.system_setup()
                system.install_shell_tools()
            elif choice == "2":
                self.prerequisites()
                self.system_setup()
                system.install_terminal_tools()
            elif choice == "3":
                self.prerequisites()
                self.system_setup()
                system.install_file_tools()
            elif choice == "4":
                self.prerequisites()
                self.system_setup()
                system.install_system_monitoring()
            elif choice == "5":
                self.prerequisites()
                self.system_setup()
                system.install_network_tools()
            elif choice == "6":
                self.prerequisites()
                self.system_setup()
                system.install_editors()
            elif choice == "7":
                self.prerequisites()
                self.system_setup()
                system.install_fonts()
            elif choice == "8":
                self.prerequisites()
                self.system_setup()
                system.install_all()
            elif choice == "9" or choice is None:
                break
            else:
                print("Invalid choice. Please select 1-9.")

    def summary(self):
        LOG.info("Bootstrap complete for user: %s", self.cfg.username)
        LOG.info("Hostname: %s", self.cfg.hostname)
        LOG.info("Cloud CLIs: %s", self.cfg.cloud)
        LOG.info("AI env (not yet implemented here): %s", self.cfg.ai_env)
        LOG.info("Log file: %s", self.log_path)

    def run(self):
        self.setup_logging()
        # Always show banner at startup
        try:
            show_banner()
        except Exception:
            # Non-fatal if terminal doesn't handle colors
            pass
        self.handle_signals()
        LOG.info("Starting Obsidian Cloud Python Bootstrap")
        # Optional interactive menu gate
        if getattr(self.cfg, "menu", False):
            self._run_interactive_menu()
        self.prerequisites()
        self.system_setup()
        self.core_setup()
        self.infra_setup()
        self.run_postfix()
        self.summary()


# -----------------------------
# CLI
# -----------------------------

def parse_args(argv: List[str]) -> Config:
    p = argparse.ArgumentParser(description="Obsidian Cloud Engineer Toolkit Bootstrap (Python)")
    p.add_argument("--username", default="dev")
    p.add_argument("--password", default=None)
    p.add_argument("--hostname", default="arch-wsl")
    p.add_argument("--enable-systemd", action="store_true")
    p.add_argument("--ai", dest="ai_env", action="store_true", default=True)
    p.add_argument("--no-ai", dest="ai_env", action="store_false")
    p.add_argument("--gpu", dest="gpu_notes", action="store_true")
    p.add_argument("--cloud", choices=["all", "aws", "gcp", "azure", "none"], default="all")
    p.add_argument("--skip-ohmyzsh", action="store_true")
    p.add_argument("--run-postfix", dest="run_postfix", default=None)
    p.add_argument("--log-level", default="INFO", choices=["DEBUG", "INFO", "WARNING", "ERROR"]) 
    p.add_argument("--menu", action="store_true", help="Show interactive menu before running")
    args = p.parse_args(argv)
    return Config(
        username=args.username,
        password=args.password,
        hostname=args.hostname,
        enable_systemd=args.enable_systemd,
        ai_env=args.ai_env,
        gpu_notes=args.gpu_notes,
        cloud=args.cloud,
        skip_ohmyzsh=args.skip_ohmyzsh,
        run_postfix=args.run_postfix,
        log_level=args.log_level,
    )


def main(argv: List[str] | None = None) -> int:
    cfg = parse_args(argv or sys.argv[1:])
    try:
        Bootstrap(cfg).run()
        return 0
    except CmdError as e:
        LOG.error("Bootstrap failed: %s", e)
        return 2
    except SystemExit as e:
        return int(e.code) if isinstance(e.code, int) else 1
    except Exception as e:  # noqa: BLE001
        LOG.exception("Unexpected error: %s", e)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
