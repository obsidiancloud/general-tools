# Obsidian Cloud Engineering Toolkit (Python)

A friendly, production-ready bootstrap for engineers at Obsidian Cloud. This Python program turns a fresh Arch-based workstation (including CachyOS/Manjaro/Arch on WSL) into a cohesive, modern development environment—on your terms. It’s modular, idempotent, and calm under pressure.

You can install everything, or pick and choose from thoughtful categories like DevOps Tools, Cloud CLIs, AI/ML Tools, and System Tools via an interactive menu.

---

## ✨ Highlights

- **Beautiful startup banner** with a moody blue → near‑black → purple truecolor gradient.
- **Interactive menu** with clear categories and submenus (run with `--menu`).
- **Robust installs** using pacman, AUR (yay), pipx, and micromamba where appropriate.
- **Idempotent**: safe to re-run—skips already installed pieces whenever possible.
- **Detailed logs** to help you understand what happened (`/tmp/obsidian-bootstrap.<timestamp>.log`).
- **Graceful handling** of interruptions and transient errors with retries.

---

## 🧭 What this installs (by category)

### 🔧 DevOps Tools
- **Kubernetes**: `kubectl`, `helm`, `kustomize`, `kind`, `k9s`, `minikube`, `k3s`, `kubectx`, `kubens`, `stern`, `flux-cli`, `argocd-cli`, `istioctl`
- **Containers**: `docker`, `docker-compose`, `docker-buildx`, `podman`, `buildah`, `skopeo`, `dive`, `ctop`, `lazydocker`, `hadolint`
- **Infrastructure as Code**: `terraform`, `tflint`, `ansible`, `packer`, `vagrant`, `terragrunt`, `pulumi`, `crossplane-cli`, `terraform-ls`, `ansible-lint`
- **Monitoring**: `prometheus`, `grafana`, `node-exporter`, `alertmanager`, `blackbox-exporter`
- **Security**: `trivy`, `checkov`, `sops`, `age`, `vault`, `cosign`
- **Load Testing**: `k6`, `artillery`, `wrk`, `hey`

### ☁️ Cloud CLIs
- **AWS**: `aws-cli-v2`, `session-manager-plugin`, `eksctl`, `aws-vault`, plus `aws-sam-cli`, `aws-cdk-lib`, `copilot-cli` (via pipx)
- **GCP**: `google-cloud-cli`, `skaffold`
- **Azure**: `azure-cli`, `bicep`
- **Multi-cloud**: `pulumi`, `crossplane-cli`

### 🤖 AI/ML Tools
- **Python env**: `python`, `pip`, `pipx`, `virtualenv`, `micromamba`, `poetry`, `pipenv`
- **ML frameworks** (micromamba env `ai`): PyTorch (CPU), scikit-learn, XGBoost, LightGBM, CatBoost
- **Data & Viz**: JupyterLab, ipywidgets, matplotlib, seaborn, plotly, bokeh, streamlit, dash
- **MLOps**: MLflow, Weights & Biases, DVC, Great Expectations, Kedro, Optuna, Ray, Prefect
- **AI APIs**: OpenAI, Anthropic, LangChain, Transformers, Datasets, Hugging Face Hub, tiktoken

### 💻 System Tools
- **Shell**: `zsh`, `fish`, bash-completion; Oh My Zsh; Powerlevel10k; `starship`
- **Terminal**: `tmux`, `screen`, `zellij`
- **Files & Search**: `fzf`, `fd`, `ripgrep`, `bat`, `eza`, `tree`, `zoxide`, `rsync`, `rclone`, `ranger`, `nnn`, `lf`, `broot`
- **System Monitoring**: `htop`, `iotop`, `nethogs`, `iftop`, `btop`, `glances`, `bandwhich`
- **Network**: `nmap`, `wireshark-cli`, `tcpdump`, `netcat`, `curl`, `wget`, `httpie`, `bind-tools`
- **Editors**: `neovim`, `vim`, `emacs`, `visual-studio-code-bin`
- **Fonts**: Noto fonts, JetBrains Mono, Fira Code, Meslo Nerd Font for Powerlevel10k, Nerd Symbols

> Install sources: official Arch repos (pacman), AUR (yay), Python CLIs (pipx), micromamba (conda-like).

---

## 🖥️ Requirements

- Arch-based distro: Arch Linux, CachyOS, Manjaro, or Arch on WSL
- Internet connectivity
- `sudo` available (interactive prompts are fine)
- Disk space: **≥ 10GB** recommended if installing multiple categories
- Truecolor-capable terminal for the gradient banner (optional but delightful)

Optional (for the extra-large banner):
- `pyfiglet`
  - Pacman: `sudo pacman -S python-pyfiglet`
  - Pipx: `pipx install pyfiglet`

---

## 🚀 Quick Start

```bash
# From repo root of the toolkit directory
cd obsidiancloud-engineer-toolkit

# See the interactive menu
python3 obsidian_bootstrap.py --menu

# Or run full bootstrap (all categories)
python3 obsidian_bootstrap.py --username dev --cloud all

# More verbose logging
python3 obsidian_bootstrap.py --menu --log-level DEBUG
```

Common flags:

- `--username <name>` sets the engineer account (default: `dev`)
- `--password <pass>` sets a password for that user (optional)
- `--hostname <name>` sets `/etc/hostname`
- `--cloud all|aws|gcp|azure|none` filters Cloud CLIs
- `--menu` enables the interactive category menus
- `--run-postfix "<cmd>"` runs a command at the end as the target user
- `--log-level DEBUG|INFO|WARNING|ERROR`

Logs are written to `/tmp/obsidian-bootstrap.<timestamp>.log`.

---

## 🧩 Menu Map

Run with `--menu` to explore:

- **🔧 DevOps Tools**
  - Kubernetes Tools
  - Container Tools
  - Infrastructure as Code
  - Monitoring Tools
  - Security Tools
  - Load Testing
  - All DevOps Tools

- **☁️ Cloud CLIs**
  - AWS Tools
  - GCP Tools
  - Azure Tools
  - Multi‑Cloud Tools
  - All Cloud Tools

- **🤖 AI/ML Tools**
  - Python Environment
  - ML Frameworks
  - Data Tools
  - MLOps Tools
  - AI APIs
  - All AI/ML Tools

- **💻 System Tools**
  - Shell Tools
  - Terminal Tools
  - File Management
  - System Monitoring
  - Network Tools
  - Editors
  - Fonts
  - All System Tools

- **System Setup Only**
- **Full Bootstrap (All Categories)**

---

## 🛠️ How installs work

- **Pacman**: used for official Arch packages.
- **AUR (yay)**: auto-installed if missing; AUR packages are built as the target `--username` under `/opt/yay` (cleaned afterwards).
- **Pipx**: used for Python CLIs (isolated, not polluting system site-packages).
- **Micromamba**: used for AI/ML environment (`ai`).
- **Manual**: Oh My Zsh and Powerlevel10k are installed via git/curl scripts.

Installs are idempotent where practical—if something is already present, we skip it.

---

## 🔐 Sudo model

The script runs commands with `sudo` per operation. Passwordless sudo is **not** required; you’ll be prompted when needed. If the initial `sudo -n true` check fails, it simply means authentication will be interactive (that’s okay).

---

## 🧯 Troubleshooting

- **Pacman database lock**
  - Error: `failed to synchronize all databases (unable to lock database)`
  - Cause: Another pacman process is running (e.g., auto-update service) or a stale lock file.
  - Fix (careful):
    ```bash
    # If no pacman process is running:
    sudo rm -f /var/lib/pacman/db.lck
    # then retry
    ```

- **AUR build failures**
  - AUR packages are built as the target user. If a package fails, it won’t block the entire flow—check the log and retry that category.

- **Network hiccups**
  - The script retries key operations. If mirrors are slow, consider updating your mirrorlist, then re-run.

- **Docker socket not found**
  - On WSL with Docker Desktop, enable WSL integration for this distro. Or run a local Docker daemon / use Podman.

- **Truecolor not showing**
  - Check your terminal supports 24-bit color. If not, banner still renders; it just won’t glow.

---

## 🧱 Design notes

- **Modular architecture**: `DevOpsTools`, `CloudTools`, `AIMLTools`, `SystemTools` classes each handle their domain.
- **Menu-first UX**: explore and install incrementally, not all-at-once.
- **Calm defaults**: sensible, widely-used tools—curated for real-world engineering.

Key file:
- `obsidian_bootstrap.py` — the program entry point and orchestrator.

---

## 🗺️ Roadmap

- Add role-based profiles (e.g., `--profile devops|ai|frontend`).
- Add macOS/Homebrew variant (stretch goal).
- Integrate VS Code extension packs per role.
- Fine-grained logging flags per category.

---

## 🤝 Contributing

We welcome improvements! Please open an issue or PR with a short description and steps to test. If adding tools, note their install source (pacman/AUR/pipx/micromamba) and why they belong.

---

## 📜 License

This toolkit is part of the Obsidian Cloud engineering ecosystem. If you need explicit licensing terms for distribution beyond internal use, please contact the maintainers.
