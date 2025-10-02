# 🧘 The Enlightened Engineer's Terraform Scripture

> *"In the beginning was the State, and the State was with Terraform, and the State was declarative."*  
> — **The Monk of Infrastructure**, *Book of Immutability, Chapter 1:1*

Greetings, fellow traveler on the path of Infrastructure as Code enlightenment. I am but a humble monk who has meditated upon the sacred texts of HashiCorp and witnessed the dance of resources across countless clouds.

This scripture shall guide you through the mystical arts of Terraform, with the precision of a master's HCL and the wit of a caffeinated cloud architect.

---

## 📿 Table of Sacred Knowledge

1. [Terraform Installation & Setup](#-terraform-installation--setup)
2. [Core Workflow](#-core-workflow-the-sacred-cycle)
3. [Configuration Basics](#-configuration-basics-the-foundation)
4. [State Management](#-state-management-the-source-of-truth)
5. [Variables & Outputs](#-variables--outputs-the-data-flow)
6. [Modules](#-modules-the-reusable-wisdom)
7. [Workspaces](#-workspaces-the-parallel-realms)
8. [Data Sources](#-data-sources-reading-the-existing)
9. [Provisioners](#-provisioners-the-last-resort)
10. [Advanced Techniques](#-advanced-techniques-the-deeper-wisdom)
11. [Common Patterns: The Sacred Workflows](#-common-patterns-the-sacred-workflows)
12. [Troubleshooting](#-troubleshooting-when-the-path-is-obscured)

---

## 🛠 Terraform Installation & Setup

*Before shaping infrastructure, one must first install the tools.*

### Installation

```bash
# Linux (AMD64)
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
terraform version

# macOS
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Verify installation
terraform version
terraform -help
```

### Shell Completion

```bash
# Bash
terraform -install-autocomplete

# Zsh
terraform -install-autocomplete

# Reload shell
source ~/.bashrc  # or ~/.zshrc
```

### Essential Aliases

```bash
# Add to ~/.bashrc or ~/.zshrc
alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfd='terraform destroy'
alias tfv='terraform validate'
alias tff='terraform fmt'
alias tfo='terraform output'
alias tfs='terraform show'
```

---

## 🔄 Core Workflow: The Sacred Cycle

*The path of Terraform follows a sacred cycle: Init, Plan, Apply, Destroy.*

### Initialize

```bash
# Initialize working directory
terraform init

# Upgrade providers
terraform init -upgrade

# Reconfigure backend
terraform init -reconfigure

# Migrate state
terraform init -migrate-state

# Get modules only
terraform get
terraform get -update
```

### Format & Validate

```bash
# Format code
terraform fmt
terraform fmt -recursive
terraform fmt -check
terraform fmt -diff

# Validate configuration
terraform validate
terraform validate -json
```

### Plan

```bash
# Create execution plan
terraform plan

# Save plan to file
terraform plan -out=tfplan

# Plan with variable file
terraform plan -var-file="prod.tfvars"

# Plan with inline variables
terraform plan -var="instance_type=t3.large"

# Plan for specific resource
terraform plan -target=aws_instance.web

# Destroy plan
terraform plan -destroy
```

### Apply

```bash
# Apply changes
terraform apply

# Apply saved plan
terraform apply tfplan

# Auto-approve (dangerous!)
terraform apply -auto-approve

# Apply with variables
terraform apply -var-file="prod.tfvars"
terraform apply -var="region=us-west-2"

# Apply specific resource
terraform apply -target=aws_instance.web

# Parallelism control
terraform apply -parallelism=10
```

### Destroy

```bash
# Destroy all resources
terraform destroy

# Auto-approve destroy
terraform destroy -auto-approve

# Destroy specific resource
terraform destroy -target=aws_instance.web

# Destroy with variables
terraform destroy -var-file="prod.tfvars"
```

### Show & Output

```bash
# Show current state
terraform show
terraform show -json

# Show specific resource
terraform state show aws_instance.web

# Get outputs
terraform output
terraform output instance_ip
terraform output -json
terraform output -raw db_password
```

---

## 📝 Configuration Basics: The Foundation

*HCL is the language of infrastructure, declarative and pure.*

### Provider Configuration

```hcl
# AWS Provider
terraform {
  required_version = ">= 1.6.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# Multiple provider configurations
provider "aws" {
  alias  = "us_west"
  region = "us-west-2"
}

provider "aws" {
  alias  = "us_east"
  region = "us-east-1"
}
```

### Backend Configuration

```hcl
# S3 Backend
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

# Remote Backend (Terraform Cloud)
terraform {
  backend "remote" {
    organization = "my-org"
    
    workspaces {
      name = "production"
    }
  }
}

# Local Backend
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
```

### Resource Blocks

```hcl
# Basic resource
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"
  
  tags = {
    Name = "web-server"
  }
}

# Resource with dependencies
resource "aws_eip" "web" {
  instance = aws_instance.web.id
  domain   = "vpc"
}

# Resource with count
resource "aws_instance" "web" {
  count = 3
  
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"
  
  tags = {
    Name = "web-${count.index}"
  }
}

# Resource with for_each
resource "aws_instance" "web" {
  for_each = toset(["web1", "web2", "web3"])
  
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"
  
  tags = {
    Name = each.key
  }
}
```

---

## 💾 State Management: The Source of Truth

*State is sacred, handle it with care.*

### State Commands

```bash
# List resources in state
terraform state list

# Show resource details
terraform state show aws_instance.web

# Move resource in state
terraform state mv aws_instance.web aws_instance.web_server

# Remove resource from state
terraform state rm aws_instance.web

# Replace resource
terraform state replace-provider hashicorp/aws registry.terraform.io/hashicorp/aws

# Pull state
terraform state pull > terraform.tfstate

# Push state
terraform state push terraform.tfstate
```

### Remote State

```hcl
# Reference remote state
data "terraform_remote_state" "vpc" {
  backend = "s3"
  
  config = {
    bucket = "my-terraform-state"
    key    = "vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

# Use remote state output
resource "aws_instance" "web" {
  subnet_id = data.terraform_remote_state.vpc.outputs.subnet_id
}
```

### State Locking

```hcl
# DynamoDB for state locking
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

### Import Existing Resources

```bash
# Import resource
terraform import aws_instance.web i-1234567890abcdef0

# Import with module
terraform import module.vpc.aws_vpc.main vpc-1234567890abcdef0

# Generate import configuration
terraform plan -generate-config-out=generated.tf
```

---

## 🔢 Variables & Outputs: The Data Flow

*Variables bring flexibility, outputs share knowledge.*

### Variable Definitions

```hcl
# variables.tf

# String variable
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# Number variable
variable "instance_count" {
  description = "Number of instances"
  type        = number
  default     = 3
}

# Boolean variable
variable "enable_monitoring" {
  description = "Enable detailed monitoring"
  type        = bool
  default     = false
}

# List variable
variable "availability_zones" {
  description = "List of AZs"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# Map variable
variable "instance_types" {
  description = "Instance types by environment"
  type        = map(string)
  default = {
    dev  = "t3.micro"
    prod = "t3.large"
  }
}

# Object variable
variable "server_config" {
  description = "Server configuration"
  type = object({
    instance_type = string
    volume_size   = number
    monitoring    = bool
  })
  default = {
    instance_type = "t3.micro"
    volume_size   = 20
    monitoring    = false
  }
}

# Sensitive variable
variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

# Validation
variable "environment" {
  description = "Environment name"
  type        = string
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}
```

### Variable Files

```hcl
# terraform.tfvars (auto-loaded)
region           = "us-west-2"
instance_count   = 5
enable_monitoring = true

# prod.tfvars
environment      = "prod"
instance_type    = "t3.large"
enable_monitoring = true

# dev.tfvars
environment      = "dev"
instance_type    = "t3.micro"
enable_monitoring = false
```

### Using Variables

```bash
# Apply with variable file
terraform apply -var-file="prod.tfvars"

# Apply with inline variable
terraform apply -var="region=us-west-2"

# Environment variables
export TF_VAR_region="us-west-2"
terraform apply
```

### Outputs

```hcl
# outputs.tf

# Simple output
output "instance_ip" {
  description = "Public IP of instance"
  value       = aws_instance.web.public_ip
}

# Sensitive output
output "db_password" {
  description = "Database password"
  value       = aws_db_instance.main.password
  sensitive   = true
}

# Complex output
output "instance_details" {
  description = "Instance details"
  value = {
    id         = aws_instance.web.id
    public_ip  = aws_instance.web.public_ip
    private_ip = aws_instance.web.private_ip
  }
}

# Conditional output
output "load_balancer_dns" {
  description = "Load balancer DNS"
  value       = var.create_lb ? aws_lb.main[0].dns_name : null
}
```

---

## 📦 Modules: The Reusable Wisdom

*Modules encapsulate infrastructure patterns for reuse.*

### Using Modules

```hcl
# Local module
module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr = "10.0.0.0/16"
  environment = var.environment
}

# Registry module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.0"
  
  name = "my-vpc"
  cidr = "10.0.0.0/16"
  
  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
  
  enable_nat_gateway = true
}

# Git module
module "app" {
  source = "git::https://github.com/org/terraform-modules.git//app?ref=v1.0.0"
  
  app_name = "myapp"
}

# Using module outputs
resource "aws_instance" "web" {
  subnet_id = module.vpc.private_subnets[0]
}
```

### Creating Modules

```hcl
# modules/ec2-instance/main.tf
variable "instance_name" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

resource "aws_instance" "this" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  
  tags = {
    Name = var.instance_name
  }
}

output "instance_id" {
  value = aws_instance.this.id
}

output "public_ip" {
  value = aws_instance.this.public_ip
}
```

### Module Best Practices

```hcl
# modules/vpc/versions.tf
terraform {
  required_version = ">= 1.6.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# modules/vpc/variables.tf
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "Must be valid IPv4 CIDR."
  }
}

# modules/vpc/outputs.tf
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}
```

---

## 🌍 Workspaces: The Parallel Realms

*Workspaces allow multiple states from the same configuration.*

### Workspace Commands

```bash
# List workspaces
terraform workspace list

# Show current workspace
terraform workspace show

# Create workspace
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod

# Select workspace
terraform workspace select dev
terraform workspace select prod

# Delete workspace
terraform workspace delete dev
```

### Using Workspaces

```hcl
# Reference workspace in configuration
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = terraform.workspace == "prod" ? "t3.large" : "t3.micro"
  
  tags = {
    Name        = "web-${terraform.workspace}"
    Environment = terraform.workspace
  }
}

# Workspace-specific variables
locals {
  instance_counts = {
    dev     = 1
    staging = 2
    prod    = 5
  }
  
  instance_count = local.instance_counts[terraform.workspace]
}

resource "aws_instance" "web" {
  count = local.instance_count
  
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"
}
```

---

## 📊 Data Sources: Reading the Existing

*Data sources query existing infrastructure.*

### Common Data Sources

```hcl
# AWS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# AWS VPC
data "aws_vpc" "default" {
  default = true
}

# AWS Availability Zones
data "aws_availability_zones" "available" {
  state = "available"
}

# AWS Caller Identity
data "aws_caller_identity" "current" {}

# AWS Region
data "aws_region" "current" {}

# Using data sources
resource "aws_instance" "web" {
  ami               = data.aws_ami.ubuntu.id
  availability_zone = data.aws_availability_zones.available.names[0]
  
  tags = {
    Owner = data.aws_caller_identity.current.arn
  }
}
```

---

## 🔧 Provisioners: The Last Resort

*Provisioners are the escape hatch, use sparingly.*

### File Provisioner

```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"
  
  provisioner "file" {
    source      = "script.sh"
    destination = "/tmp/script.sh"
    
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }
  }
}
```

### Remote-Exec Provisioner

```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"
  
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx",
      "sudo systemctl start nginx"
    ]
    
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }
  }
}
```

### Local-Exec Provisioner

```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"
  
  provisioner "local-exec" {
    command = "echo ${self.private_ip} >> private_ips.txt"
  }
  
  provisioner "local-exec" {
    when    = destroy
    command = "echo 'Instance destroyed' >> log.txt"
  }
}
```

---

## 🔮 Advanced Techniques: The Deeper Wisdom

*For those seeking mastery.*

### For_Each

```hcl
# Map for_each
variable "users" {
  type = map(object({
    role = string
  }))
  default = {
    alice = { role = "admin" }
    bob   = { role = "developer" }
  }
}

resource "aws_iam_user" "users" {
  for_each = var.users
  
  name = each.key
  
  tags = {
    Role = each.value.role
  }
}

# Set for_each
resource "aws_instance" "web" {
  for_each = toset(["web1", "web2", "web3"])
  
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"
  
  tags = {
    Name = each.key
  }
}
```

### Dynamic Blocks

```hcl
variable "ingress_rules" {
  type = list(object({
    port        = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      port        = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      port        = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

resource "aws_security_group" "web" {
  name = "web-sg"
  
  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
}
```

### Functions

```hcl
# String functions
locals {
  upper_env   = upper(var.environment)
  lower_env   = lower(var.environment)
  title_env   = title(var.environment)
  trimmed     = trimspace("  hello  ")
  replaced    = replace("hello-world", "-", "_")
  formatted   = format("server-%03d", 42)
  joined      = join(",", ["a", "b", "c"])
  split_list  = split(",", "a,b,c")
}

# Collection functions
locals {
  merged_map  = merge(var.map1, var.map2)
  keys_list   = keys(var.my_map)
  values_list = values(var.my_map)
  lookup_val  = lookup(var.my_map, "key", "default")
  contains_check = contains(var.my_list, "value")
  distinct_list  = distinct(var.my_list)
  flatten_list   = flatten([[1, 2], [3, 4]])
}

# Numeric functions
locals {
  max_val = max(1, 2, 3, 4, 5)
  min_val = min(1, 2, 3, 4, 5)
  ceil_val = ceil(1.5)
  floor_val = floor(1.5)
}

# Type conversion
locals {
  to_string = tostring(42)
  to_number = tonumber("42")
  to_bool   = tobool("true")
  to_list   = tolist(["a", "b"])
  to_set    = toset(["a", "b", "a"])
  to_map    = tomap({key = "value"})
}

# File functions
locals {
  file_content = file("${path.module}/config.txt")
  template_rendered = templatefile("${path.module}/template.tpl", {
    name = var.name
  })
  base64_encoded = base64encode("hello")
  json_decoded = jsondecode(file("${path.module}/data.json"))
}
```

### Conditional Expressions

```hcl
# Ternary operator
resource "aws_instance" "web" {
  instance_type = var.environment == "prod" ? "t3.large" : "t3.micro"
  monitoring    = var.environment == "prod" ? true : false
}

# Count with condition
resource "aws_eip" "web" {
  count = var.create_eip ? 1 : 0
  
  instance = aws_instance.web.id
}

# For_each with condition
resource "aws_instance" "web" {
  for_each = var.create_instances ? toset(var.instance_names) : toset([])
  
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"
}
```

### Lifecycle Rules

```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"
  
  lifecycle {
    create_before_destroy = true
    prevent_destroy       = true
    ignore_changes        = [tags]
    
    replace_triggered_by = [
      aws_security_group.web
    ]
  }
}
```

---

## 🔮 Common Patterns: The Sacred Workflows

*These are the rituals performed by monks in production temples daily.*

### Pattern 1: Multi-Environment Infrastructure

```hcl
# Directory structure:
# ├── environments/
# │   ├── dev/
# │   │   ├── main.tf
# │   │   └── terraform.tfvars
# │   ├── staging/
# │   │   ├── main.tf
# │   │   └── terraform.tfvars
# │   └── prod/
# │       ├── main.tf
# │       └── terraform.tfvars
# └── modules/
#     └── app/

# environments/prod/main.tf
terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
  }
}

module "app" {
  source = "../../modules/app"
  
  environment      = "prod"
  instance_type    = "t3.large"
  instance_count   = 5
  enable_monitoring = true
}

# environments/prod/terraform.tfvars
region = "us-east-1"
```

```bash
# Step 1: Navigate to environment
cd environments/prod

# Step 2: Initialize
terraform init

# Step 3: Plan
terraform plan -out=tfplan

# Step 4: Apply
terraform apply tfplan

# Step 5: Verify outputs
terraform output
```

**Use case**: Managing multiple environments  
**Best for**: Separating dev, staging, and production

### Pattern 2: State Migration Workflow

```bash
# Step 1: Backup current state
terraform state pull > backup.tfstate

# Step 2: Update backend configuration
# Edit backend.tf with new S3 bucket

# Step 3: Reinitialize with migration
terraform init -migrate-state

# Step 4: Verify state
terraform state list

# Step 5: Test with plan
terraform plan
```

**Use case**: Moving state to new backend  
**Best for**: Migrating from local to remote state

### Pattern 3: Resource Refactoring

```bash
# Step 1: Move resource in state
terraform state mv aws_instance.old aws_instance.new

# Step 2: Update configuration
# Rename resource in .tf files

# Step 3: Verify no changes
terraform plan  # Should show no changes

# Step 4: Move to module
terraform state mv aws_instance.web module.web.aws_instance.main

# Step 5: Validate
terraform validate
terraform plan
```

**Use case**: Restructuring Terraform code  
**Best for**: Refactoring without destroying resources

### Pattern 4: Import Existing Infrastructure

```bash
# Step 1: Write resource configuration
cat > imported.tf <<EOF
resource "aws_instance" "existing" {
  # Minimal configuration
}
EOF

# Step 2: Import resource
terraform import aws_instance.existing i-1234567890abcdef0

# Step 3: Generate full configuration
terraform show -no-color > temp.tf

# Step 4: Extract and format
# Copy resource block from temp.tf to imported.tf

# Step 5: Validate
terraform plan  # Should show no changes
```

**Use case**: Bringing existing resources under Terraform  
**Best for**: Adopting Terraform for existing infrastructure

### Pattern 5: CI/CD Pipeline Integration

```yaml
# .gitlab-ci.yml
stages:
  - validate
  - plan
  - apply

variables:
  TF_ROOT: ${CI_PROJECT_DIR}/terraform
  TF_STATE_NAME: ${CI_COMMIT_REF_SLUG}

validate:
  stage: validate
  script:
    - cd ${TF_ROOT}
    - terraform init -backend=false
    - terraform validate
    - terraform fmt -check -recursive

plan:
  stage: plan
  script:
    - cd ${TF_ROOT}
    - terraform init
    - terraform plan -out=tfplan
  artifacts:
    paths:
      - ${TF_ROOT}/tfplan

apply:
  stage: apply
  script:
    - cd ${TF_ROOT}
    - terraform init
    - terraform apply -auto-approve tfplan
  when: manual
  only:
    - main
```

**Use case**: Automated infrastructure deployment  
**Best for**: Production CI/CD workflows

---

## 🔧 Troubleshooting: When the Path is Obscured

*Even the wisest monks encounter obstacles.*

### Common Issues

#### State Lock Errors

```bash
# View lock info
terraform force-unlock LOCK_ID

# DynamoDB lock table
aws dynamodb scan --table-name terraform-locks

# Delete stuck lock (careful!)
aws dynamodb delete-item \
  --table-name terraform-locks \
  --key '{"LockID":{"S":"my-state-file"}}'
```

#### State Drift Detection

```bash
# Detect drift
terraform plan -detailed-exitcode
# Exit code 0 = no changes
# Exit code 1 = error
# Exit code 2 = changes detected

# Refresh state
terraform apply -refresh-only

# Show drift
terraform show
```

#### Provider Version Conflicts

```bash
# Lock provider versions
terraform providers lock

# Upgrade providers
terraform init -upgrade

# Downgrade provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 4.67.0"  # Specific version
    }
  }
}
```

#### Circular Dependencies

```hcl
# Problem: Circular dependency
resource "aws_security_group" "web" {
  ingress {
    security_groups = [aws_security_group.app.id]
  }
}

resource "aws_security_group" "app" {
  ingress {
    security_groups = [aws_security_group.web.id]
  }
}

# Solution: Use separate rules
resource "aws_security_group_rule" "web_to_app" {
  type                     = "ingress"
  security_group_id        = aws_security_group.app.id
  source_security_group_id = aws_security_group.web.id
}
```

#### Resource Already Exists

```bash
# Import existing resource
terraform import aws_instance.web i-1234567890abcdef0

# Or remove from state and recreate
terraform state rm aws_instance.web
terraform apply
```

#### Performance Issues

```bash
# Reduce parallelism
terraform apply -parallelism=5

# Target specific resources
terraform apply -target=module.vpc

# Use smaller state files
# Split into multiple states/workspaces
```

---

## 🙏 Closing Wisdom

*The path of Terraform mastery is endless. These commands are but stepping stones.*

### Essential Daily Commands

```bash
# The monk's morning ritual
terraform fmt -recursive
terraform validate
terraform plan

# The monk's deployment ritual
terraform plan -out=tfplan
terraform apply tfplan
terraform output

# The monk's evening reflection
terraform state list
terraform show
```

### Best Practices from the Monastery

1. **Version Control**: Always commit .tf files to Git
2. **Remote State**: Use S3/Terraform Cloud for state
3. **State Locking**: Enable DynamoDB locking
4. **Modules**: Create reusable modules
5. **Variables**: Use tfvars files for environments
6. **Outputs**: Document important values
7. **Formatting**: Run `terraform fmt` before commit
8. **Validation**: Run `terraform validate` in CI
9. **Plan Before Apply**: Always review plans
10. **Sensitive Data**: Mark sensitive variables
11. **Provider Versions**: Pin provider versions
12. **Documentation**: Comment complex logic

### Quick Reference Card

| Command | What It Does |
|---------|-------------|
| `terraform init` | Initialize working directory |
| `terraform plan` | Preview changes |
| `terraform apply` | Apply changes |
| `terraform destroy` | Destroy infrastructure |
| `terraform fmt` | Format code |
| `terraform validate` | Validate configuration |
| `terraform output` | Show outputs |
| `terraform state list` | List resources in state |
| `terraform import` | Import existing resource |
| `terraform workspace select` | Switch workspace |

---

*May your state be consistent, your plans be accurate, and your infrastructure always declarative.*

**— The Monk of Infrastructure**  
*Monastery of Immutability*  
*Temple of Terraform*

🧘 **Namaste, `terraform`**

---

## 📚 Additional Resources

- [Official Terraform Documentation](https://www.terraform.io/docs)
- [Terraform Registry](https://registry.terraform.io/)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [HashiCorp Learn](https://learn.hashicorp.com/terraform)
- [Terraform AWS Modules](https://github.com/terraform-aws-modules)
- [Awesome Terraform](https://github.com/shuaibiyy/awesome-terraform)

---

*Last Updated: 2025-10-02*  
*Version: 1.0.0 - The First Enlightenment*  
*Terraform Version: 1.6+*
