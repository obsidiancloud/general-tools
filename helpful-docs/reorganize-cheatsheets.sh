#!/bin/bash

# Script to reorganize cheatsheets into directory structure
# Structure: helpful-docs/obsidian-cheatsheets/<topic>/<cheatsheets>

set -e

BASE_DIR="/home/radicaledward/projects/obsidiancloud/repos/general-tools/helpful-docs"
cd "$BASE_DIR"

echo "Creating directory structure..."

# Create main directory
mkdir -p obsidian-cheatsheets

# Create topic directories
mkdir -p obsidian-cheatsheets/core-infrastructure
mkdir -p obsidian-cheatsheets/observability-monitoring
mkdir -p obsidian-cheatsheets/networking-security
mkdir -p obsidian-cheatsheets/cicd-automation
mkdir -p obsidian-cheatsheets/system-administration
mkdir -p obsidian-cheatsheets/databases-caching
mkdir -p obsidian-cheatsheets/modern-tools
mkdir -p obsidian-cheatsheets/cloud-platform
mkdir -p obsidian-cheatsheets/ai-ml-data-science

echo "Moving cheatsheets to respective directories..."

# Core Infrastructure
mv git-github-cli-cheatsheet.md obsidian-cheatsheets/core-infrastructure/ 2>/dev/null || true
mv kubernetes-kubectl-cheatsheet.md obsidian-cheatsheets/core-infrastructure/ 2>/dev/null || true
mv docker-docker-compose-cheatsheet.md obsidian-cheatsheets/core-infrastructure/ 2>/dev/null || true
mv terraform-cheatsheet.md obsidian-cheatsheets/core-infrastructure/ 2>/dev/null || true
mv aws-cli-cheatsheet.md obsidian-cheatsheets/core-infrastructure/ 2>/dev/null || true
mv ansible-cheatsheet.md obsidian-cheatsheets/core-infrastructure/ 2>/dev/null || true

# Observability & Monitoring
mv prometheus-promql-cheatsheet.md obsidian-cheatsheets/observability-monitoring/ 2>/dev/null || true
mv grafana-cheatsheet.md obsidian-cheatsheets/observability-monitoring/ 2>/dev/null || true
mv elk-stack-cheatsheet.md obsidian-cheatsheets/observability-monitoring/ 2>/dev/null || true

# Networking & Security
mv ssl-tls-openssl-cheatsheet.md obsidian-cheatsheets/networking-security/ 2>/dev/null || true
mv nginx-cheatsheet.md obsidian-cheatsheets/networking-security/ 2>/dev/null || true
mv iptables-firewall-cheatsheet.md obsidian-cheatsheets/networking-security/ 2>/dev/null || true

# CI/CD & Automation
mv jenkins-cheatsheet.md obsidian-cheatsheets/cicd-automation/ 2>/dev/null || true
mv gitlab-ci-github-actions-cheatsheet.md obsidian-cheatsheets/cicd-automation/ 2>/dev/null || true

# System Administration
mv systemd-cheatsheet.md obsidian-cheatsheets/system-administration/ 2>/dev/null || true
mv bash-scripting-cheatsheet.md obsidian-cheatsheets/system-administration/ 2>/dev/null || true
mv linux-commands-cheatsheet.md obsidian-cheatsheets/system-administration/ 2>/dev/null || true

# Databases & Caching
mv postgresql-redis-mysql-cheatsheet.md obsidian-cheatsheets/databases-caching/ 2>/dev/null || true
mv modern-databases-cheatsheet.md obsidian-cheatsheets/databases-caching/ 2>/dev/null || true

# Modern Tools
mv jq-yq-cheatsheet.md obsidian-cheatsheets/modern-tools/ 2>/dev/null || true
mv helm-argocd-cheatsheet.md obsidian-cheatsheets/modern-tools/ 2>/dev/null || true
mv vim-tmux-cheatsheet.md obsidian-cheatsheets/modern-tools/ 2>/dev/null || true

# Cloud & Platform
mv aws-services-cheatsheet.md obsidian-cheatsheets/cloud-platform/ 2>/dev/null || true
mv gcp-azure-cheatsheet.md obsidian-cheatsheets/cloud-platform/ 2>/dev/null || true

# AI/ML & Data Science
mv ai-ml-frameworks-cheatsheet.md obsidian-cheatsheets/ai-ml-data-science/ 2>/dev/null || true

# Move documentation files to main obsidian-cheatsheets directory
mv INDEX.md obsidian-cheatsheets/ 2>/dev/null || true
mv COMPLETION_SUMMARY.md obsidian-cheatsheets/ 2>/dev/null || true

echo "Creating main README in obsidian-cheatsheets directory..."
# README.md and PROGRESS.md stay in helpful-docs root
# CHEATSHEET_GENERATION_PROMPT.md stays in helpful-docs root

echo "✅ Reorganization complete!"
echo ""
echo "New structure:"
echo "helpful-docs/"
echo "├── README.md (main entry point)"
echo "├── PROGRESS.md"
echo "├── CHEATSHEET_GENERATION_PROMPT.md"
echo "└── obsidian-cheatsheets/"
echo "    ├── README.md (will be created)"
echo "    ├── INDEX.md"
echo "    ├── COMPLETION_SUMMARY.md"
echo "    ├── core-infrastructure/"
echo "    ├── observability-monitoring/"
echo "    ├── networking-security/"
echo "    ├── cicd-automation/"
echo "    ├── system-administration/"
echo "    ├── databases-caching/"
echo "    ├── modern-tools/"
echo "    ├── cloud-platform/"
echo "    └── ai-ml-data-science/"
