# 🧘 General Tools - The DevOps Monastery

> *"A wise engineer maintains not just the cloud, but the tools that build the cloud. For even the mightiest infrastructure begins with a single script."*
> — **The Monk of Infrastructure**, Chapter 3, Verse 17

Greetings, fellow travelers on the path of cloud enlightenment. This humble monk has gathered sacred tools and wisdom scrolls to ease your journey through the treacherous landscapes of infrastructure, containerization, and systems administration.

Within this repository lies a curated collection of battle-tested utilities, automation scripts, and knowledge artifacts—each forged in the fires of production environments and tempered by the wisdom of countless deployments.

---

## 📿 Table of Sacred Knowledge

- [🛠️ The Sacred Tools](#️-the-sacred-tools)
  - [🏗️ Environment Preparation](#️-environment-preparation)
  - [💾 Storage Enlightenment](#-storage-enlightenment)
  - [🔍 Repository Vigilance](#-repository-vigilance)
  - [⚡ Process Harmony](#-process-harmony)
  - [📜 Knowledge Scrolls](#-knowledge-scrolls)
  - [🔧 Terminal Wisdom](#-terminal-wisdom)
  - [☁️ Cloud Formation](#️-cloud-formation)
- [🙏 Installation Rituals](#-installation-rituals)
- [🔮 When the Path is Obscured](#-when-the-path-is-obscured)
- [📖 License](#-license)
- [🧘 Closing Wisdom](#-closing-wisdom)

---

## 🛠️ The Sacred Tools

Like a monk's toolkit contains many instruments for different meditations, this repository contains specialized utilities for different aspects of the DevOps practice.

### 🏗️ Environment Preparation

**[obsidiancloud-engineer-toolkit](./obsidiancloud-engineer-toolkit/)**

Before the journey begins, one must prepare their temple. This comprehensive bootstrap system transforms barren Arch Linux WSL distributions into fully-equipped development sanctuaries.

**What the ritual provides:**
- Complete development environment (Zsh, Oh My Zsh, Powerlevel10k)
- Runtime management through asdf (Node.js, Python, Go, Java, Rust)
- Container orchestration tools (Docker, Kubernetes, Helm)
- Infrastructure as Code utilities (Terraform, Ansible, Packer)
- AI/ML environment with Micromamba (optional)
- Cloud CLI tools (AWS, GCP, Azure)

*"Like preparing soil before planting seeds, one must prepare the environment before writing code."*

### 💾 Storage Enlightenment

**[obsidiancloud-storage-manager](./obsidiancloud-storage-manager/)**

The path of storage management is fraught with peril. One wrong command can lead to data loss; one hasty expansion can corrupt filesystems. This production-grade utility brings wisdom and safety to disk operations.

**Features of mindful disk management:**
- Comprehensive disk, partition, and LVM overview
- Space usage analysis with top consumers
- Automatic partition table backups before operations
- Multi-level risk warnings (SAFE → CRITICAL)
- Graceful error handling with detailed messages

*"Even the wisest monks encounter full disks. The difference is they have proper backup strategies."*

### 🔍 Repository Vigilance

**[powershell-repo-scanner](./powershell-repo-scanner/)**

In the monastery of modern development, external dependencies are like uninvited guests at meditation—sometimes necessary, but requiring careful oversight. This scanner ensures all GitHub repositories honor your internal Artifactory configuration.

**The scanner's abilities:**
- Interactive prompts for organization and repository targeting
- GitHub CLI integration for authenticated access
- Comprehensive logging with severity levels
- CSV export for compliance reporting
- Graceful error handling and rate limiting

*"Trust, but verify. Even in package repositories."*

### ⚡ Process Harmony

**[priority-manager](./priority-manager/)**

Like a conductor ensuring each instrument plays at the right volume, this system ensures critical applications maintain optimal system priority—preventing the dreaded OOM killer from disrupting your meditation.

**Automatic priority management includes:**
- Real-time process priority monitoring
- Critical application protection
- System resource optimization
- Performance issue prevention

*"In the orchestra of processes, harmony comes from proper prioritization."*

### 📜 Knowledge Scrolls

**[helpful-docs/obsidian-cheatsheets](./helpful-docs/obsidian-cheatsheets/)**

The ancient masters knew that wisdom must be preserved for future generations. Here lie **23 comprehensive cheatsheets** covering the breadth of DevOps, SRE, and Cloud Engineering practice—organized for rapid reference during incidents (or peaceful study during quieter times).

**Categories of knowledge:**
- 🏗️ **Core Infrastructure**: Git, Kubernetes, Docker, Terraform, AWS CLI, Ansible
- 📊 **Observability**: Prometheus, Grafana, ELK Stack
- 🔒 **Networking & Security**: SSL/TLS, Nginx, iptables
- 🚀 **CI/CD**: Jenkins, GitLab CI, GitHub Actions
- 🖥️ **System Administration**: systemd, Bash scripting, Linux commands
- 💾 **Databases**: PostgreSQL, Redis, MySQL, Neo4j, Vector DBs
- ⚡ **Modern Tools**: jq/yq, Helm, ArgoCD, Vim, Tmux
- ☁️ **Cloud Platforms**: AWS, GCP, Azure
- 🤖 **AI/ML**: PyTorch, TensorFlow, scikit-learn, Hugging Face

*"The master who knows where to find knowledge is wiser than the one who memorizes all."*

### 🔧 Terminal Wisdom

**[helpful-aliases](./helpful-aliases/)**

Like a river splitting into streams, so too must your commands flow efficiently. These battle-tested aliases improve terminal efficiency for the tools you use most.

- `k8s-aliases.sh` - Kubernetes kubectl shortcuts
- `terraform-aliases.sh` - Terraform workflow accelerators

**[zsh-config](./zsh-config/)**

The shell is your primary interface with the machine. Make it beautiful, functional, and powerful.

- Plugin installation scripts for Zsh
- Cross-platform support (Linux, macOS)
- Modern CLI tool integration

*"A monk's workspace should bring peace, not frustration."*

### ☁️ Cloud Formation

**[terraform-setup-AWSOrganization-project-structure](./terraform-setup-AWSOrganization-project-structure/)**

The foundation of cloud governance begins with proper AWS Organization structure. This provides the skeleton upon which enterprise infrastructure is built.

**[install-InfracostKubecost](./install-InfracostKubecost/)**

Like a diligent accountant in the monastery, cost management tools help ensure your cloud spending aligns with actual value delivered.

**[solana-development-environment](./solana-development-environment/)**

For those who walk the path of blockchain development, this provides the necessary environment setup for Solana.

*"Infrastructure without cost awareness is like meditation without mindfulness."*

---

## 🙏 Installation Rituals

### Prerequisites

Before beginning your journey, ensure you have:
- Linux environment (native, WSL, or VM)
- Git installed and configured
- Sudo privileges (for most tools)
- Internet connection for package downloads

### Individual Tool Installation

Each tool contains its own sacred scrolls (README.md) with specific installation instructions. Navigate to the tool's directory and consult the documentation:

```bash
# Example: Installing the storage manager
cd obsidiancloud-storage-manager
cat README.md

# Example: Running the engineer toolkit bootstrap
cd obsidiancloud-engineer-toolkit
chmod +x archlinux-bootstrap.sh
./archlinux-bootstrap.sh --help
```

### Cloning the Sacred Repository

```bash
# Bring the entire monastery to your machine
git clone https://github.com/obsidiancloud/general-tools.git
cd general-tools

# Explore the contents
ls -la
```

*"The journey of installation is straightforward when one reads the documentation."*

---

## 🔮 When the Path is Obscured

Even the most experienced monks encounter obstacles. When you face errors, consider these principles:

### First Principles of Debugging

1. **Read the logs** - Truth lies in `/var/log` and stderr
2. **Check permissions** - Many issues stem from insufficient privileges
3. **Verify dependencies** - Missing packages are common culprits
4. **Consult the README** - Each tool has specific requirements
5. **Test in isolation** - Remove variables by testing one component at a time

### Common Challenges

**Permission Denied**
```bash
# Ensure proper sudo access
sudo -v

# Check user group membership
groups $USER
```

**Missing Dependencies**
```bash
# Arch/CachyOS
sudo pacman -Syyu && sudo pacman -S base-devel git

# Debian/Ubuntu
sudo apt update && sudo apt install build-essential git
```

**GitHub CLI Authentication** (for repo-scanner)
```bash
gh auth login
# Follow prompts to authenticate
```

*"When stuck, return to fundamentals. When confused, consult the documentation. When lost, ask the community."*

---

## 📖 License

This project is licensed under the [GPL-3.0 License](./LICENSE).

Like knowledge shared freely among monks, these tools are provided for the benefit of all who walk the DevOps path.

---

## 🧘 Closing Wisdom

> *"The tools we build today become the foundation for tomorrow's innovations. The knowledge we share today enlightens countless engineers we'll never meet. The automation we write today gives us time for deeper contemplation tomorrow."*

### Quick Reference Card

```
🏗️  Bootstrap Environment    → obsidiancloud-engineer-toolkit/
💾  Manage Storage           → obsidiancloud-storage-manager/
🔍  Scan Repositories        → powershell-repo-scanner/
⚡  Manage Priorities        → priority-manager/
📜  Reference Cheatsheets    → helpful-docs/obsidian-cheatsheets/
🔧  Shell Aliases            → helpful-aliases/
☁️  AWS Organization Setup   → terraform-setup-AWSOrganization-project-structure/
```

### Support & Community

For questions, issues, or contributions:
- **GitHub Issues**: https://github.com/obsidiancloud/general-tools/issues
- **Documentation**: Each tool's README.md
- **Cheatsheets**: [helpful-docs/obsidian-cheatsheets/INDEX.md](./helpful-docs/obsidian-cheatsheets/INDEX.md)

*May your builds be green, your deployments smooth, and your infrastructure resilient.*

---

**🧘 From the DevOps Monastery**
*Where infrastructure meets enlightenment*

**Namaste** 🙏
