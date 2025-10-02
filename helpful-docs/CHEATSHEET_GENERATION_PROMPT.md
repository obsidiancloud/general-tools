# 🧘 Cheatsheet Generation Prompt for The Enlightened Engineer Series

This prompt instructs the creation of comprehensive, production-grade cheatsheets for Principal-level SRE and DevOps engineers.

---

## Generation Instructions

Create comprehensive cheatsheets for the following tools, following the exact format and persona established in `git-github-cli-cheatsheet.md`.

### Core Requirements

**PERSONA**: Quirky monk (wise, zen-like, witty, technically precise)
- Use spiritual/monastery metaphors
- Include humor and wisdom
- Maintain technical accuracy for top engineers
- Quote the "Monk of [Tool]" with chapter/verse style citations

**FORMAT REQUIREMENTS**:
1. **Opening quote** from the "Monk of [Tool]" 
2. **Table of contents** with emoji markers
3. **Comprehensive sections** covering:
   - Setup & Configuration
   - Basic Commands
   - Advanced Techniques
   - **Common Patterns** (REQUIRED - production workflows)
   - Troubleshooting
   - Best Practices from the Monastery
   - Quick Reference Card
4. **Code blocks** with real, working examples
5. **Command variations** (old way vs modern way)
6. **Common patterns section** with production-ready workflows
7. **Performance tips**
8. **Security considerations**
9. **Integration examples** with other tools
10. **Closing wisdom section**

**QUALITY STANDARDS**:
- Accurate, tested commands
- Production-ready patterns
- Real-world usage examples
- Common pitfalls and solutions
- Performance optimization tips
- Security best practices
- Integration with other tools in the stack

**TARGET AUDIENCE**: 
Principal-level SRE/DevOps Engineers who need:
- Quick, reliable reference
- Advanced techniques
- Production patterns
- Troubleshooting guides
- Best practices

---

## Tools to Create Cheatsheets For

### Priority 1: Core Infrastructure Tools

#### 1. **Kubernetes (kubectl) Cheatsheet**
`kubernetes-kubectl-cheatsheet.md`

**Sections to include**:
- kubectl configuration and contexts
- Pod management (create, inspect, logs, exec)
- Deployment operations (scale, rollout, rollback)
- Service and networking
- ConfigMaps and Secrets
- Persistent Volumes
- Resource management (limits, quotas)
- Debugging (describe, logs, events, debug containers)
- Advanced: Custom columns, JSONPath, label selectors
- **Common Patterns**: Rolling updates, blue/green deployments, canary releases, troubleshooting workflows
- Kustomize basics
- Helm integration
- **AWS EKS-Specific Section** (REQUIRED - special focus):
  - EKS cluster setup and authentication
  - IAM roles for service accounts (IRSA)
  - EKS-specific node groups and Fargate profiles
  - AWS Load Balancer Controller
  - EBS CSI driver and storage classes
  - EKS add-ons management
  - eksctl commands
  - Integration with AWS services (ALB, NLB, EFS, ECR)
  - EKS best practices and cost optimization
  - EKS-specific troubleshooting
- Troubleshooting (CrashLoopBackOff, ImagePullBackOff, etc.)

#### 2. **Docker & Docker Compose Cheatsheet**
`docker-docker-compose-cheatsheet.md`

**Sections to include**:
- Docker installation and configuration
- Image management (build, tag, push, pull)
- Container lifecycle (run, start, stop, rm)
- Networking (bridge, host, overlay)
- Volumes and storage
- Docker Compose (up, down, logs, scale)
- Multi-stage builds
- BuildKit and build optimization
- **Common Patterns**: Development workflows, CI/CD integration, debugging containers, health checks
- Security scanning
- Registry operations
- Dockerfile best practices
- Resource limits
- Troubleshooting

#### 3. **Terraform Cheatsheet**
`terraform-cheatsheet.md`

**Sections to include**:
- Terraform installation and setup
- Configuration (providers, backend, variables)
- Core workflow (init, plan, apply, destroy)
- State management (remote state, state commands)
- Workspaces
- Modules (creating, using, publishing)
- Data sources
- **Common Patterns**: Infrastructure workflows, CI/CD integration, multi-environment management, refactoring
- Provisioners
- Import existing resources
- Terraform Cloud/Enterprise
- Best practices (structure, naming, versioning)
- Advanced: for_each, dynamic blocks, functions
- Troubleshooting (state lock, drift detection)

#### 4. **AWS CLI Cheatsheet**
`aws-cli-cheatsheet.md`

**Sections to include**:
- AWS CLI installation and configuration
- Profile management
- Common EC2 operations
- S3 operations (sync, cp, presigned URLs)
- IAM management
- VPC and networking
- ECS/EKS operations
- Lambda functions
- **Common Patterns**: Instance management workflows, S3 automation, log analysis, cross-account operations
- CloudWatch logs and metrics
- Systems Manager (SSM)
- Secrets Manager / Parameter Store
- CloudFormation
- Query and filtering (--query, --filter)
- Output formats and JMESPath
- Troubleshooting

#### 5. **Ansible Cheatsheet**
`ansible-cheatsheet.md`

**Sections to include**:
- Ansible installation and setup
- Inventory management (static, dynamic)
- Ad-hoc commands
- Playbook structure
- Modules (common ones: command, shell, copy, template, package, service)
- Variables and facts
- Conditionals and loops
- **Common Patterns**: Server provisioning, application deployment, rolling updates, zero-downtime deployments
- Handlers and notifications
- Roles and collections
- Ansible Vault (secrets management)
- Tags and limits
- Ansible Galaxy
- Best practices (idempotency, structure)
- Troubleshooting

### Priority 2: Observability & Monitoring

#### 6. **Prometheus & PromQL Cheatsheet**
`prometheus-promql-cheatsheet.md`

**Sections to include**:
- Prometheus architecture
- Configuration basics
- PromQL query language
- Metric types (counter, gauge, histogram, summary)
- Selectors and matchers
- Operators and functions
- Aggregation
- Recording rules and alerting rules
- **Common Patterns**: SLI/SLO queries, capacity planning, anomaly detection, troubleshooting queries
- Common queries for SRE metrics
- Integration with Grafana
- Exporters
- Best practices
- Troubleshooting

#### 7. **Grafana Cheatsheet**
`grafana-cheatsheet.md`

**Sections to include**:
- Dashboard creation and management
- Panel types and visualizations
- Query editors (Prometheus, Loki, etc.)
- Variables and templating
- Annotations
- Alerts
- Data sources
- Provisioning (as code)
- API usage
- Common dashboard patterns
- Best practices
- Troubleshooting

#### 8. **ELK Stack (Elasticsearch, Logstash, Kibana) Cheatsheet**
`elk-stack-cheatsheet.md`

**Sections to include**:
- Elasticsearch: queries, indices, mappings
- Logstash: pipelines, filters, patterns
- Kibana: visualizations, dashboards, discover
- Index lifecycle management
- Common log parsing patterns
- Search queries and aggregations
- Performance tuning
- Best practices
- Troubleshooting

### Priority 3: Networking & Security

#### 9. **SSL/TLS & OpenSSL Cheatsheet**
`ssl-tls-openssl-cheatsheet.md`

**Sections to include**:
- Certificate concepts
- OpenSSL commands
- Generate CSR, private keys
- Self-signed certificates
- Verify certificates and chains
- Convert formats (PEM, DER, PKCS12)
- Test SSL connections
- Certificate inspection
- Let's Encrypt / certbot
- Best practices
- Troubleshooting

#### 10. **iptables & firewalld Cheatsheet**
`iptables-firewalld-cheatsheet.md`

**Sections to include**:
- iptables: tables, chains, rules
- Common firewall rules
- NAT and port forwarding
- firewalld: zones, services, rich rules
- Persistent rules
- Logging
- Security best practices
- Troubleshooting

#### 11. **tcpdump & Wireshark Cheatsheet**
`tcpdump-wireshark-cheatsheet.md`

**Sections to include**:
- tcpdump: capture filters, display filters
- Common capture scenarios
- Wireshark: GUI operations, filters
- Protocol analysis
- Save and read captures
- Network troubleshooting patterns
- Performance analysis
- Best practices

### Priority 4: CI/CD & Automation

#### 12. **GitHub Actions Cheatsheet**
`github-actions-cheatsheet.md`

**Sections to include**:
- Workflow syntax
- Triggers (push, pull_request, schedule, etc.)
- Jobs and steps
- Actions marketplace
- Secrets management
- Matrix builds
- Caching
- Artifacts
- Environments and deployments
- Self-hosted runners
- Best practices
- Troubleshooting

#### 13. **Jenkins Pipeline Cheatsheet**
`jenkins-pipeline-cheatsheet.md`

**Sections to include**:
- Declarative vs Scripted pipelines
- Pipeline syntax
- Stages and steps
- Agent configuration
- Environment variables
- Credentials
- Parallel execution
- Post actions
- Shared libraries
- Blue Ocean
- Best practices
- Troubleshooting

#### 14. **GitLab CI/CD Cheatsheet**
`gitlab-ci-cd-cheatsheet.md`

**Sections to include**:
- .gitlab-ci.yml syntax
- Stages and jobs
- Runners
- Variables and secrets
- Artifacts and cache
- Docker integration
- Environments and deployments
- Include and extends
- Rules and conditions
- Best practices
- Troubleshooting

### Priority 5: System Administration

#### 15. **systemd Cheatsheet**
`systemd-cheatsheet.md`

**Sections to include**:
- systemctl commands
- Unit files (service, timer, socket)
- Managing services
- Logs (journalctl)
- Targets and runlevels
- Timers (cron replacement)
- Resource control
- Dependencies
- Best practices
- Troubleshooting

#### 16. **Linux Performance Tools Cheatsheet**
`linux-performance-cheatsheet.md`

**Sections to include**:
- top, htop, atop
- iostat, vmstat, mpstat
- netstat, ss
- sar (System Activity Reporter)
- perf, strace, ltrace
- iotop, iftop
- dmesg, lsof
- Performance analysis methodology
- Common bottlenecks
- Troubleshooting

#### 17. **Bash Scripting Cheatsheet**
`bash-scripting-cheatsheet.md`

**Sections to include**:
- Shebang and execution
- Variables and parameters
- Conditionals (if, case)
- Loops (for, while, until)
- Functions
- Arrays
- String manipulation
- File operations
- Process management
- Error handling
- Best practices (set -euo pipefail, etc.)
- Common patterns
- Debugging

### Priority 6: Databases & Caching

#### 18. **PostgreSQL Administration Cheatsheet**
`postgresql-admin-cheatsheet.md`

**Sections to include**:
- psql commands
- Database and user management
- Backup and restore (pg_dump, pg_restore)
- Performance tuning
- Query optimization (EXPLAIN)
- Replication
- Connection pooling
- Monitoring
- Common queries for DBA tasks
- Best practices
- Troubleshooting

#### 19. **Redis Cheatsheet**
`redis-cheatsheet.md`

**Sections to include**:
- redis-cli commands
- Data types (strings, lists, sets, hashes, sorted sets)
- Common operations
- Pub/Sub
- Persistence (RDB, AOF)
- Replication and clustering
- Performance tuning
- Monitoring
- Security
- Best practices
- Troubleshooting

#### 20. **MySQL/MariaDB Administration Cheatsheet**
`mysql-mariadb-admin-cheatsheet.md`

**Sections to include**:
- mysql client commands
- Database and user management
- Backup and restore (mysqldump, mysqlpump)
- Performance tuning
- Query optimization (EXPLAIN)
- Replication
- Monitoring
- Common DBA queries
- Best practices
- Troubleshooting

### Priority 7: Modern Tools

#### 21. **jq (JSON Processor) Cheatsheet**
`jq-cheatsheet.md`

**Sections to include**:
- Basic filters
- Object and array manipulation
- Conditionals
- Functions
- Complex transformations
- Common patterns for API responses
- Integration with CLI tools
- Best practices
- Examples

#### 22. **tmux Cheatsheet**
`tmux-cheatsheet.md`

**Sections to include**:
- Session management
- Window management
- Pane management
- Key bindings
- Configuration (.tmux.conf)
- Copy mode
- Scripts and automation
- Integration with tools
- Best practices
- Tips and tricks

#### 23. **vim/neovim Cheatsheet**
`vim-neovim-cheatsheet.md`

**Sections to include**:
- Modes
- Navigation
- Editing commands
- Visual mode
- Search and replace
- Buffers, windows, tabs
- Macros
- Configuration (.vimrc)
- Plugins
- Best practices
- Tips for developers

#### 24. **sed & awk Cheatsheet**
`sed-awk-cheatsheet.md`

**Sections to include**:
- sed: substitution, deletion, insertion
- sed: addressing and ranges
- awk: field processing, patterns
- awk: built-in variables and functions
- Common text processing patterns
- One-liners for SRE tasks
- Best practices
- Examples

### Priority 8: Cloud & Platform Tools

#### 25. **Azure CLI Cheatsheet**
`azure-cli-cheatsheet.md`

**Sections to include**:
- Installation and authentication
- Resource management
- VM operations
- Storage accounts
- Azure Kubernetes Service (AKS)
- Networking
- Query and filtering (JMESPath)
- Common operations
- Best practices
- Troubleshooting

#### 26. **Google Cloud (gcloud) Cheatsheet**
`gcloud-cheatsheet.md`

**Sections to include**:
- Installation and authentication
- Project and configuration
- Compute Engine
- Google Kubernetes Engine (GKE)
- Cloud Storage
- IAM
- Networking
- Common operations
- Best practices
- Troubleshooting

#### 27. **Pulumi Cheatsheet**
`pulumi-cheatsheet.md`

**Sections to include**:
- Installation and setup
- Projects and stacks
- Core commands
- State management
- Secrets
- CI/CD integration
- Multi-language support
- Best practices
- Terraform comparison
- Troubleshooting

---

## Template Structure

Use this structure for each cheatsheet:

```markdown
# 🧘 The Enlightened Engineer's [TOOL] Scripture

> *"[Witty spiritual quote about the tool]"*  
> — **The Monk of [Tool]**, *Book of [Aspect], Chapter X:Y*

[Opening paragraph in monk persona explaining the tool's essence]

---

## 📿 Table of Sacred Knowledge

- [Section 1]
- [Section 2]
- [Common Patterns: The Sacred Workflows]
- [etc.]

---

## 🛠 [Section Name]

*[Spiritual metaphor for this section]*

### [Subsection]

```bash
# [Category of commands]
command example  # Explanation

# [Another category]
command example
```

[Continue pattern...]

---

## 🔮 Common Patterns: The Sacred Workflows

*These are the rituals performed by monks in production temples daily.*

### [Pattern Name]

```bash
# [Step-by-step workflow]
command 1
command 2
command 3
```

**Use case**: [When to use this pattern]  
**Best for**: [Scenarios where this excels]

[Include 3-5 common production patterns]

---

## 🔧 Troubleshooting: When the Path is Obscured

*Even the wisest monks encounter obstacles.*

### Common Issues

#### [Issue Name]
```bash
# [Solution commands]
```

---

## 🙏 Closing Wisdom

*[Final spiritual wisdom about mastering the tool]*

### Essential Daily Commands
```bash
# [Most common commands]
```

### Best Practices from the Monastery

1. **[Practice]**: [Explanation]
2. [etc.]

### Quick Reference Card

| Command | What It Does |
|---------|-------------|
| `cmd` | Description |

---

*May your [tool-specific wish], your [another wish], and your [final wish].*

**— The Monk of [Tool]**  
*Monastery of [Domain]*  
*Temple of [Tool]*

🧘 **Namaste, `[tool]`**

---

## 📚 Additional Resources

- [Official docs]
- [Other resources]

---

*Last Updated: [Date]*  
*Version: 1.0.0 - The First Enlightenment*
```

---

## Example Prompt for Each Tool

**Usage**: Copy this prompt and replace `[TOOL]` with the specific tool:

```
Create a comprehensive [TOOL] cheatsheet in markdown format using the quirky monk persona (wise, zen-like, witty). 

This will go in: /home/radicaledward/projects/obsidiancloud/repos/general-tools/helpful-docs/[tool]-cheatsheet.md

Requirements:
1. Follow the EXACT format of git-github-cli-cheatsheet.md
2. Quirky monk persona throughout with spiritual metaphors
3. Opening quote from "The Monk of [Tool]"
4. Comprehensive sections covering: setup, basics, advanced techniques, troubleshooting, best practices
5. MUST include a "Common Patterns" section with 3-5 production workflows (step-by-step)
6. All commands must be accurate and production-ready
7. Include real-world usage examples for Principal-level SRE/DevOps engineers
8. Quick reference card at the end
9. Common pitfalls and solutions
10. Performance and security tips
11. Integration with other tools in the stack

Target audience: Top-tier SRE/DevOps engineers who need reliable, accurate references.

Make it comprehensive, technically accurate, and entertaining.
```

---

## Batch Creation Command

To create all cheatsheets systematically:

```bash
# Create a tracking file
cat > /home/radicaledward/projects/obsidiancloud/repos/general-tools/helpful-docs/PROGRESS.md << 'EOF'
# Cheatsheet Creation Progress

- [x] Git & GitHub CLI
- [ ] Kubernetes (kubectl)
- [ ] Docker & Docker Compose
- [ ] Terraform
- [ ] AWS CLI
- [ ] Ansible
- [ ] Prometheus & PromQL
- [ ] Grafana
- [ ] ELK Stack
- [ ] SSL/TLS & OpenSSL
- [ ] iptables & firewalld
- [ ] tcpdump & Wireshark
- [ ] GitHub Actions
- [ ] Jenkins Pipeline
- [ ] GitLab CI/CD
- [ ] systemd
- [ ] Linux Performance Tools
- [ ] Bash Scripting
- [ ] PostgreSQL Administration
- [ ] Redis
- [ ] MySQL/MariaDB Administration
- [ ] jq
- [ ] tmux
- [ ] vim/neovim
- [ ] sed & awk
- [ ] Azure CLI
- [ ] gcloud
- [ ] Pulumi
EOF
```

---

## Quality Checklist

Before marking a cheatsheet as complete, verify:

- [ ] Quirky monk persona maintained throughout
- [ ] All commands are accurate and tested
- [ ] Includes setup/installation instructions
- [ ] Basic and advanced sections present
- [ ] **Common Patterns section with 3-5 production workflows**
- [ ] Troubleshooting section included
- [ ] Best practices from the monastery
- [ ] Quick reference card present
- [ ] Real-world production examples
- [ ] Integration with other tools shown
- [ ] Security considerations addressed
- [ ] Performance tips included
- [ ] Common pitfalls documented
- [ ] Closing wisdom section
- [ ] Links to additional resources
- [ ] Proper markdown formatting
- [ ] Code blocks are properly formatted
- [ ] Table of contents with working links

---

*May your cheatsheets be comprehensive, your commands accurate, and your engineers enlightened.*

🧘‍♂️ **The Monastery of Documentation Awaits**
