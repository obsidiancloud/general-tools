# 🧘 The Enlightened Engineer's AWS CLI Scripture

> *"In the beginning was the Cloud, and the Cloud was with AWS, and the Cloud was infinite."*  
> — **The Monk of Clouds**, *Book of Regions, Chapter 1:1*

Greetings, fellow traveler on the path of cloud enlightenment. I am but a humble monk who has meditated upon the sacred texts of Bezos and witnessed the dance of services across countless regions.

This scripture shall guide you through the mystical arts of the AWS CLI, with the precision of a master's IAM policy and the wit of a caffeinated solutions architect.

---

## 📿 Table of Sacred Knowledge

1. [AWS CLI Installation & Setup](#-aws-cli-installation--setup)
2. [Configuration & Profiles](#-configuration--profiles-the-many-identities)
3. [EC2 Operations](#-ec2-operations-the-compute-realm)
4. [S3 Operations](#-s3-operations-the-object-storage)
5. [IAM Management](#-iam-management-the-gatekeepers)
6. [VPC & Networking](#-vpc--networking-the-virtual-networks)
7. [ECS & EKS](#-ecs--eks-the-container-orchestration)
8. [Lambda Functions](#-lambda-functions-the-serverless-path)
9. [CloudWatch](#-cloudwatch-the-all-seeing-eye)
10. [Systems Manager](#-systems-manager-the-remote-control)
11. [Secrets & Parameters](#-secrets--parameters-the-hidden-knowledge)
12. [Common Patterns: The Sacred Workflows](#-common-patterns-the-sacred-workflows)
13. [Troubleshooting](#-troubleshooting-when-the-path-is-obscured)

---

## 🛠 AWS CLI Installation & Setup

*Before commanding the cloud, one must first install the tools.*

### Installation

```bash
# Linux (x86_64)
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# macOS
brew install awscli

# Verify installation
aws --version

# Update AWS CLI
sudo ./aws/install --update
```

### Initial Configuration

```bash
# Configure default profile
aws configure

# Configure with inline values
aws configure set aws_access_key_id AKIAIOSFODNN7EXAMPLE
aws configure set aws_secret_access_key wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
aws configure set default.region us-east-1
aws configure set default.output json

# View configuration
aws configure list
aws configure get region
```

### Essential Aliases

```bash
# Add to ~/.bashrc or ~/.zshrc
alias awsp='aws --profile'
alias awsr='aws --region'
alias awsec2='aws ec2'
alias awss3='aws s3'
alias awsiam='aws iam'
alias awslogs='aws logs'
alias awseks='aws eks'
```

---

## 🔐 Configuration & Profiles: The Many Identities

*A monk may serve many accounts, switching between them with grace.*

### Managing Profiles

```bash
# Create named profile
aws configure --profile production
aws configure --profile development

# List profiles
cat ~/.aws/config
cat ~/.aws/credentials

# Use profile
aws s3 ls --profile production
export AWS_PROFILE=production
aws s3 ls

# Set default profile
export AWS_DEFAULT_PROFILE=production
```

### Configuration Files

```ini
# ~/.aws/config
[default]
region = us-east-1
output = json

[profile production]
region = us-west-2
output = json
role_arn = arn:aws:iam::123456789012:role/ProductionRole
source_profile = default

[profile development]
region = us-east-1
output = table
```

```ini
# ~/.aws/credentials
[default]
aws_access_key_id = AKIAIOSFODNN7EXAMPLE
aws_secret_access_key = wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

[production]
aws_access_key_id = AKIAI44QH8DHBEXAMPLE
aws_secret_access_key = je7MtGbClwBF/2Zp9Utk/h3yCo8nvbEXAMPLEKEY
```

### SSO Configuration

```bash
# Configure SSO
aws configure sso

# Login to SSO
aws sso login --profile my-sso-profile

# Logout from SSO
aws sso logout
```

### Assume Role

```bash
# Assume role
aws sts assume-role \
  --role-arn arn:aws:iam::123456789012:role/MyRole \
  --role-session-name my-session

# Get caller identity
aws sts get-caller-identity

# Decode authorization message
aws sts decode-authorization-message \
  --encoded-message <encoded-message>
```

---

## 💻 EC2 Operations: The Compute Realm

*Virtual machines in the cloud, spinning up and down like prayer wheels.*

### Listing Instances

```bash
# List all instances
aws ec2 describe-instances

# List with specific output
aws ec2 describe-instances --output table

# List instance IDs only
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[*].InstanceId' \
  --output text

# List running instances
aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running" \
  --query 'Reservations[*].Instances[*].[InstanceId,InstanceType,PublicIpAddress,Tags[?Key==`Name`].Value|[0]]' \
  --output table

# List instances by tag
aws ec2 describe-instances \
  --filters "Name=tag:Environment,Values=production"
```

### Starting/Stopping Instances

```bash
# Start instance
aws ec2 start-instances --instance-ids i-1234567890abcdef0

# Stop instance
aws ec2 stop-instances --instance-ids i-1234567890abcdef0

# Reboot instance
aws ec2 reboot-instances --instance-ids i-1234567890abcdef0

# Terminate instance
aws ec2 terminate-instances --instance-ids i-1234567890abcdef0

# Start multiple instances
aws ec2 start-instances --instance-ids i-123 i-456 i-789
```

### Creating Instances

```bash
# Launch instance
aws ec2 run-instances \
  --image-id ami-0c55b159cbfafe1f0 \
  --instance-type t3.micro \
  --key-name my-key-pair \
  --security-group-ids sg-0123456789abcdef0 \
  --subnet-id subnet-0123456789abcdef0 \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=MyInstance}]'

# Launch with user data
aws ec2 run-instances \
  --image-id ami-0c55b159cbfafe1f0 \
  --instance-type t3.micro \
  --user-data file://userdata.sh

# Launch spot instance
aws ec2 request-spot-instances \
  --spot-price "0.05" \
  --instance-count 1 \
  --type "one-time" \
  --launch-specification file://specification.json
```

### Instance Management

```bash
# Describe instance
aws ec2 describe-instances --instance-ids i-1234567890abcdef0

# Get instance status
aws ec2 describe-instance-status --instance-ids i-1234567890abcdef0

# Modify instance attribute
aws ec2 modify-instance-attribute \
  --instance-id i-1234567890abcdef0 \
  --instance-type t3.large

# Create AMI from instance
aws ec2 create-image \
  --instance-id i-1234567890abcdef0 \
  --name "My-AMI-$(date +%Y%m%d)" \
  --description "My custom AMI"

# Get console output
aws ec2 get-console-output --instance-id i-1234567890abcdef0
```

### Key Pairs

```bash
# Create key pair
aws ec2 create-key-pair \
  --key-name my-key-pair \
  --query 'KeyMaterial' \
  --output text > my-key-pair.pem

chmod 400 my-key-pair.pem

# List key pairs
aws ec2 describe-key-pairs

# Delete key pair
aws ec2 delete-key-pair --key-name my-key-pair
```

### Security Groups

```bash
# Create security group
aws ec2 create-security-group \
  --group-name my-sg \
  --description "My security group" \
  --vpc-id vpc-0123456789abcdef0

# Add ingress rule
aws ec2 authorize-security-group-ingress \
  --group-id sg-0123456789abcdef0 \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0

# Add multiple rules
aws ec2 authorize-security-group-ingress \
  --group-id sg-0123456789abcdef0 \
  --ip-permissions \
    IpProtocol=tcp,FromPort=80,ToPort=80,IpRanges='[{CidrIp=0.0.0.0/0}]' \
    IpProtocol=tcp,FromPort=443,ToPort=443,IpRanges='[{CidrIp=0.0.0.0/0}]'

# Remove ingress rule
aws ec2 revoke-security-group-ingress \
  --group-id sg-0123456789abcdef0 \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0

# List security groups
aws ec2 describe-security-groups

# Delete security group
aws ec2 delete-security-group --group-id sg-0123456789abcdef0
```

---

## 🪣 S3 Operations: The Object Storage

*Buckets hold objects like monasteries hold wisdom.*

### Bucket Operations

```bash
# List buckets
aws s3 ls
aws s3api list-buckets

# Create bucket
aws s3 mb s3://my-bucket
aws s3 mb s3://my-bucket --region us-west-2

# Delete bucket
aws s3 rb s3://my-bucket
aws s3 rb s3://my-bucket --force  # Delete with contents

# List bucket contents
aws s3 ls s3://my-bucket
aws s3 ls s3://my-bucket/path/ --recursive
aws s3 ls s3://my-bucket --human-readable --summarize
```

### File Operations

```bash
# Upload file
aws s3 cp file.txt s3://my-bucket/
aws s3 cp file.txt s3://my-bucket/path/file.txt

# Upload directory
aws s3 cp ./local-dir s3://my-bucket/remote-dir --recursive

# Download file
aws s3 cp s3://my-bucket/file.txt ./
aws s3 cp s3://my-bucket/file.txt ./local-file.txt

# Download directory
aws s3 cp s3://my-bucket/remote-dir ./local-dir --recursive

# Sync directories
aws s3 sync ./local-dir s3://my-bucket/remote-dir
aws s3 sync s3://my-bucket/remote-dir ./local-dir
aws s3 sync ./local-dir s3://my-bucket/remote-dir --delete

# Move file
aws s3 mv s3://my-bucket/old.txt s3://my-bucket/new.txt

# Remove file
aws s3 rm s3://my-bucket/file.txt
aws s3 rm s3://my-bucket/path/ --recursive
```

### Advanced S3 Operations

```bash
# Presigned URL (temporary access)
aws s3 presign s3://my-bucket/file.txt --expires-in 3600

# Set bucket versioning
aws s3api put-bucket-versioning \
  --bucket my-bucket \
  --versioning-configuration Status=Enabled

# Set bucket lifecycle
aws s3api put-bucket-lifecycle-configuration \
  --bucket my-bucket \
  --lifecycle-configuration file://lifecycle.json

# Enable bucket encryption
aws s3api put-bucket-encryption \
  --bucket my-bucket \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# Set bucket policy
aws s3api put-bucket-policy \
  --bucket my-bucket \
  --policy file://policy.json

# Enable static website hosting
aws s3 website s3://my-bucket/ \
  --index-document index.html \
  --error-document error.html

# Set object ACL
aws s3api put-object-acl \
  --bucket my-bucket \
  --key file.txt \
  --acl public-read
```

---

## 👤 IAM Management: The Gatekeepers

*Identity and access, the keys to the kingdom.*

### Users

```bash
# List users
aws iam list-users

# Create user
aws iam create-user --user-name john

# Delete user
aws iam delete-user --user-name john

# Get user
aws iam get-user --user-name john

# Create access key
aws iam create-access-key --user-name john

# List access keys
aws iam list-access-keys --user-name john

# Delete access key
aws iam delete-access-key \
  --user-name john \
  --access-key-id AKIAIOSFODNN7EXAMPLE
```

### Groups

```bash
# List groups
aws iam list-groups

# Create group
aws iam create-group --group-name developers

# Add user to group
aws iam add-user-to-group \
  --user-name john \
  --group-name developers

# Remove user from group
aws iam remove-user-from-group \
  --user-name john \
  --group-name developers

# List users in group
aws iam get-group --group-name developers

# Delete group
aws iam delete-group --group-name developers
```

### Roles

```bash
# List roles
aws iam list-roles

# Create role
aws iam create-role \
  --role-name my-role \
  --assume-role-policy-document file://trust-policy.json

# Attach policy to role
aws iam attach-role-policy \
  --role-name my-role \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess

# List attached policies
aws iam list-attached-role-policies --role-name my-role

# Detach policy
aws iam detach-role-policy \
  --role-name my-role \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess

# Delete role
aws iam delete-role --role-name my-role
```

### Policies

```bash
# List policies
aws iam list-policies
aws iam list-policies --scope Local  # Customer managed only

# Create policy
aws iam create-policy \
  --policy-name my-policy \
  --policy-document file://policy.json

# Get policy
aws iam get-policy \
  --policy-arn arn:aws:iam::123456789012:policy/my-policy

# Get policy version
aws iam get-policy-version \
  --policy-arn arn:aws:iam::123456789012:policy/my-policy \
  --version-id v1

# Attach policy to user
aws iam attach-user-policy \
  --user-name john \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess

# Delete policy
aws iam delete-policy \
  --policy-arn arn:aws:iam::123456789012:policy/my-policy
```

---

## 🌐 VPC & Networking: The Virtual Networks

*Networks connect, isolate, and route traffic like rivers.*

### VPC Operations

```bash
# List VPCs
aws ec2 describe-vpcs

# Create VPC
aws ec2 create-vpc --cidr-block 10.0.0.0/16

# Delete VPC
aws ec2 delete-vpc --vpc-id vpc-0123456789abcdef0

# Modify VPC attribute
aws ec2 modify-vpc-attribute \
  --vpc-id vpc-0123456789abcdef0 \
  --enable-dns-hostnames
```

### Subnets

```bash
# List subnets
aws ec2 describe-subnets

# Create subnet
aws ec2 create-subnet \
  --vpc-id vpc-0123456789abcdef0 \
  --cidr-block 10.0.1.0/24 \
  --availability-zone us-east-1a

# Delete subnet
aws ec2 delete-subnet --subnet-id subnet-0123456789abcdef0

# Modify subnet attribute
aws ec2 modify-subnet-attribute \
  --subnet-id subnet-0123456789abcdef0 \
  --map-public-ip-on-launch
```

### Internet Gateway

```bash
# Create internet gateway
aws ec2 create-internet-gateway

# Attach to VPC
aws ec2 attach-internet-gateway \
  --internet-gateway-id igw-0123456789abcdef0 \
  --vpc-id vpc-0123456789abcdef0

# Detach from VPC
aws ec2 detach-internet-gateway \
  --internet-gateway-id igw-0123456789abcdef0 \
  --vpc-id vpc-0123456789abcdef0

# Delete internet gateway
aws ec2 delete-internet-gateway \
  --internet-gateway-id igw-0123456789abcdef0
```

### Route Tables

```bash
# List route tables
aws ec2 describe-route-tables

# Create route table
aws ec2 create-route-table --vpc-id vpc-0123456789abcdef0

# Create route
aws ec2 create-route \
  --route-table-id rtb-0123456789abcdef0 \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id igw-0123456789abcdef0

# Associate route table with subnet
aws ec2 associate-route-table \
  --route-table-id rtb-0123456789abcdef0 \
  --subnet-id subnet-0123456789abcdef0

# Delete route
aws ec2 delete-route \
  --route-table-id rtb-0123456789abcdef0 \
  --destination-cidr-block 0.0.0.0/0
```

### NAT Gateway

```bash
# Allocate Elastic IP
aws ec2 allocate-address --domain vpc

# Create NAT gateway
aws ec2 create-nat-gateway \
  --subnet-id subnet-0123456789abcdef0 \
  --allocation-id eipalloc-0123456789abcdef0

# Delete NAT gateway
aws ec2 delete-nat-gateway --nat-gateway-id nat-0123456789abcdef0

# Release Elastic IP
aws ec2 release-address --allocation-id eipalloc-0123456789abcdef0
```

---

## 🐳 ECS & EKS: The Container Orchestration

*Containers orchestrated in the cloud.*

### ECS Operations

```bash
# List clusters
aws ecs list-clusters

# Create cluster
aws ecs create-cluster --cluster-name my-cluster

# List services
aws ecs list-services --cluster my-cluster

# Describe service
aws ecs describe-services \
  --cluster my-cluster \
  --services my-service

# Update service
aws ecs update-service \
  --cluster my-cluster \
  --service my-service \
  --desired-count 3

# List tasks
aws ecs list-tasks --cluster my-cluster

# Describe task
aws ecs describe-tasks \
  --cluster my-cluster \
  --tasks arn:aws:ecs:region:account:task/task-id

# Run task
aws ecs run-task \
  --cluster my-cluster \
  --task-definition my-task:1 \
  --count 1
```

### EKS Operations

```bash
# List clusters
aws eks list-clusters

# Describe cluster
aws eks describe-cluster --name my-cluster

# Update kubeconfig
aws eks update-kubeconfig \
  --region us-east-1 \
  --name my-cluster

# List node groups
aws eks list-nodegroups --cluster-name my-cluster

# Describe node group
aws eks describe-nodegroup \
  --cluster-name my-cluster \
  --nodegroup-name my-nodegroup

# Update node group
aws eks update-nodegroup-config \
  --cluster-name my-cluster \
  --nodegroup-name my-nodegroup \
  --scaling-config minSize=1,maxSize=5,desiredSize=3

# List Fargate profiles
aws eks list-fargate-profiles --cluster-name my-cluster

# List add-ons
aws eks list-addons --cluster-name my-cluster

# Describe add-on
aws eks describe-addon \
  --cluster-name my-cluster \
  --addon-name vpc-cni
```

---

## ⚡ Lambda Functions: The Serverless Path

*Functions without servers, executing on demand.*

### Function Management

```bash
# List functions
aws lambda list-functions

# Create function
aws lambda create-function \
  --function-name my-function \
  --runtime python3.11 \
  --role arn:aws:iam::123456789012:role/lambda-role \
  --handler lambda_function.lambda_handler \
  --zip-file fileb://function.zip

# Update function code
aws lambda update-function-code \
  --function-name my-function \
  --zip-file fileb://function.zip

# Update function configuration
aws lambda update-function-configuration \
  --function-name my-function \
  --timeout 30 \
  --memory-size 512

# Invoke function
aws lambda invoke \
  --function-name my-function \
  --payload '{"key":"value"}' \
  response.json

# Get function
aws lambda get-function --function-name my-function

# Delete function
aws lambda delete-function --function-name my-function
```

### Environment Variables

```bash
# Update environment variables
aws lambda update-function-configuration \
  --function-name my-function \
  --environment Variables="{KEY1=value1,KEY2=value2}"
```

### Layers

```bash
# Publish layer
aws lambda publish-layer-version \
  --layer-name my-layer \
  --zip-file fileb://layer.zip \
  --compatible-runtimes python3.11

# List layers
aws lambda list-layers

# Add layer to function
aws lambda update-function-configuration \
  --function-name my-function \
  --layers arn:aws:lambda:region:account:layer:my-layer:1
```

---

## 👁️ CloudWatch: The All-Seeing Eye

*Logs and metrics, the eyes of the cloud.*

### Logs

```bash
# List log groups
aws logs describe-log-groups

# Create log group
aws logs create-log-group --log-group-name /aws/lambda/my-function

# Delete log group
aws logs delete-log-group --log-group-name /aws/lambda/my-function

# List log streams
aws logs describe-log-streams \
  --log-group-name /aws/lambda/my-function

# Get log events
aws logs get-log-events \
  --log-group-name /aws/lambda/my-function \
  --log-stream-name 2024/01/01/[$LATEST]abc123

# Filter log events
aws logs filter-log-events \
  --log-group-name /aws/lambda/my-function \
  --filter-pattern "ERROR" \
  --start-time 1609459200000

# Tail logs
aws logs tail /aws/lambda/my-function --follow

# Query logs (Insights)
aws logs start-query \
  --log-group-name /aws/lambda/my-function \
  --start-time 1609459200 \
  --end-time 1609545600 \
  --query-string 'fields @timestamp, @message | filter @message like /ERROR/'
```

### Metrics

```bash
# List metrics
aws cloudwatch list-metrics

# Get metric statistics
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --dimensions Name=InstanceId,Value=i-1234567890abcdef0 \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-01T23:59:59Z \
  --period 3600 \
  --statistics Average

# Put metric data
aws cloudwatch put-metric-data \
  --namespace MyApp \
  --metric-name RequestCount \
  --value 100
```

### Alarms

```bash
# Create alarm
aws cloudwatch put-metric-alarm \
  --alarm-name high-cpu \
  --alarm-description "High CPU usage" \
  --metric-name CPUUtilization \
  --namespace AWS/EC2 \
  --statistic Average \
  --period 300 \
  --threshold 80 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 2

# List alarms
aws cloudwatch describe-alarms

# Delete alarm
aws cloudwatch delete-alarms --alarm-names high-cpu
```

---

## 🔧 Systems Manager: The Remote Control

*Manage instances without SSH.*

### Session Manager

```bash
# Start session
aws ssm start-session --target i-1234567890abcdef0

# Send command
aws ssm send-command \
  --instance-ids i-1234567890abcdef0 \
  --document-name "AWS-RunShellScript" \
  --parameters 'commands=["echo hello"]'

# Get command invocation
aws ssm get-command-invocation \
  --command-id command-id \
  --instance-id i-1234567890abcdef0
```

### Parameter Store

```bash
# Put parameter
aws ssm put-parameter \
  --name /myapp/database/password \
  --value "secret123" \
  --type SecureString

# Get parameter
aws ssm get-parameter \
  --name /myapp/database/password \
  --with-decryption

# Get parameters by path
aws ssm get-parameters-by-path \
  --path /myapp/ \
  --recursive \
  --with-decryption

# Delete parameter
aws ssm delete-parameter --name /myapp/database/password
```

---

## 🔐 Secrets & Parameters: The Hidden Knowledge

*Secrets must be kept safe.*

### Secrets Manager

```bash
# Create secret
aws secretsmanager create-secret \
  --name MySecret \
  --secret-string '{"username":"admin","password":"secret123"}'

# Get secret value
aws secretsmanager get-secret-value --secret-id MySecret

# Update secret
aws secretsmanager update-secret \
  --secret-id MySecret \
  --secret-string '{"username":"admin","password":"newsecret"}'

# Rotate secret
aws secretsmanager rotate-secret \
  --secret-id MySecret \
  --rotation-lambda-arn arn:aws:lambda:region:account:function:rotation-function

# Delete secret
aws secretsmanager delete-secret \
  --secret-id MySecret \
  --recovery-window-in-days 30
```

---

## 🔮 Common Patterns: The Sacred Workflows

*These are the rituals performed by monks in production temples daily.*

### Pattern 1: Instance Management Workflow

```bash
# Step 1: Find instances by tag
INSTANCE_IDS=$(aws ec2 describe-instances \
  --filters "Name=tag:Environment,Values=production" \
            "Name=instance-state-name,Values=running" \
  --query 'Reservations[*].Instances[*].InstanceId' \
  --output text)

# Step 2: Stop instances
aws ec2 stop-instances --instance-ids $INSTANCE_IDS

# Step 3: Wait for stopped state
aws ec2 wait instance-stopped --instance-ids $INSTANCE_IDS

# Step 4: Create AMI
aws ec2 create-image \
  --instance-id $(echo $INSTANCE_IDS | cut -d' ' -f1) \
  --name "backup-$(date +%Y%m%d-%H%M%S)"

# Step 5: Start instances
aws ec2 start-instances --instance-ids $INSTANCE_IDS
```

**Use case**: Automated backup and maintenance  
**Best for**: Scheduled instance backups

### Pattern 2: S3 Automation Workflow

```bash
# Step 1: Sync local to S3
aws s3 sync ./website s3://my-bucket/ --delete

# Step 2: Invalidate CloudFront cache
DISTRIBUTION_ID=$(aws cloudfront list-distributions \
  --query "DistributionList.Items[?Origins.Items[?DomainName=='my-bucket.s3.amazonaws.com']].Id" \
  --output text)

aws cloudfront create-invalidation \
  --distribution-id $DISTRIBUTION_ID \
  --paths "/*"

# Step 3: Verify deployment
aws s3 ls s3://my-bucket/ --recursive --human-readable
```

**Use case**: Static website deployment  
**Best for**: CI/CD pipelines

### Pattern 3: Log Analysis Workflow

```bash
# Step 1: Get recent errors
aws logs filter-log-events \
  --log-group-name /aws/lambda/my-function \
  --filter-pattern "ERROR" \
  --start-time $(date -d '1 hour ago' +%s)000 \
  --query 'events[*].message' \
  --output text > errors.log

# Step 2: Count error types
cat errors.log | sort | uniq -c | sort -rn

# Step 3: Create alarm if threshold exceeded
ERROR_COUNT=$(wc -l < errors.log)
if [ $ERROR_COUNT -gt 10 ]; then
  aws sns publish \
    --topic-arn arn:aws:sns:region:account:alerts \
    --message "High error count: $ERROR_COUNT errors in last hour"
fi
```

**Use case**: Automated log monitoring  
**Best for**: Error detection and alerting

### Pattern 4: Cross-Account Operations

```bash
# Step 1: Assume role in target account
CREDENTIALS=$(aws sts assume-role \
  --role-arn arn:aws:iam::123456789012:role/CrossAccountRole \
  --role-session-name cross-account-session \
  --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
  --output text)

# Step 2: Export credentials
export AWS_ACCESS_KEY_ID=$(echo $CREDENTIALS | cut -f1)
export AWS_SECRET_ACCESS_KEY=$(echo $CREDENTIALS | cut -f2)
export AWS_SESSION_TOKEN=$(echo $CREDENTIALS | cut -f3)

# Step 3: Perform operations
aws s3 ls

# Step 4: Cleanup
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
```

**Use case**: Multi-account management  
**Best for**: Cross-account resource access

### Pattern 5: Resource Tagging Workflow

```bash
# Step 1: Find untagged resources
aws ec2 describe-instances \
  --filters "Name=tag-key,Values=Environment" \
  --query 'Reservations[*].Instances[?!Tags[?Key==`Environment`]].InstanceId' \
  --output text

# Step 2: Tag resources
for INSTANCE in $(aws ec2 describe-instances \
  --query 'Reservations[*].Instances[?!Tags[?Key==`Environment`]].InstanceId' \
  --output text); do
  aws ec2 create-tags \
    --resources $INSTANCE \
    --tags Key=Environment,Value=production
done

# Step 3: Verify tags
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[*].[InstanceId,Tags[?Key==`Environment`].Value|[0]]' \
  --output table
```

**Use case**: Resource organization  
**Best for**: Compliance and cost allocation

---

## 🔧 Troubleshooting: When the Path is Obscured

*Even the wisest monks encounter obstacles.*

### Common Issues

#### Authentication Errors

```bash
# Check credentials
aws sts get-caller-identity

# Verify profile
aws configure list --profile production

# Check IAM permissions
aws iam get-user
aws iam list-attached-user-policies --user-name $(aws iam get-user --query 'User.UserName' --output text)

# Test specific permission
aws iam simulate-principal-policy \
  --policy-source-arn arn:aws:iam::123456789012:user/john \
  --action-names s3:GetObject \
  --resource-arns arn:aws:s3:::my-bucket/*
```

#### Rate Limiting

```bash
# Add retry configuration
aws configure set retry_mode adaptive
aws configure set max_attempts 10

# Use pagination
aws ec2 describe-instances --max-items 100
aws ec2 describe-instances --starting-token <token>
```

#### Query and Filter Issues

```bash
# Debug query
aws ec2 describe-instances --output json | jq '.Reservations[].Instances[] | {id: .InstanceId, ip: .PublicIpAddress}'

# Test filter
aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running" \
  --query 'Reservations[*].Instances[*].[InstanceId,State.Name]' \
  --output table
```

#### Region Issues

```bash
# List all regions
aws ec2 describe-regions --query 'Regions[*].RegionName' --output text

# Check resource in all regions
for region in $(aws ec2 describe-regions --query 'Regions[*].RegionName' --output text); do
  echo "Region: $region"
  aws ec2 describe-instances --region $region --query 'Reservations[*].Instances[*].InstanceId'
done
```

---

## 🙏 Closing Wisdom

*The path of AWS CLI mastery is endless. These commands are but stepping stones.*

### Essential Daily Commands

```bash
# The monk's morning ritual
aws sts get-caller-identity
aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --output table
aws s3 ls

# The monk's deployment ritual
aws ecr get-login-password | docker login --username AWS --password-stdin <account>.dkr.ecr.<region>.amazonaws.com
aws ecs update-service --cluster my-cluster --service my-service --force-new-deployment

# The monk's evening reflection
aws cloudwatch get-metric-statistics --namespace AWS/EC2 --metric-name CPUUtilization --statistics Average
aws logs tail /aws/lambda/my-function --since 1h
```

### Best Practices from the Monastery

1. **Use Profiles**: Separate credentials for different accounts
2. **Enable MFA**: Multi-factor authentication for security
3. **Use IAM Roles**: Prefer roles over access keys
4. **Tag Everything**: Consistent tagging strategy
5. **Use JMESPath**: Master query syntax for filtering
6. **Enable CloudTrail**: Audit all API calls
7. **Use Pagination**: Handle large result sets
8. **Set Region**: Always specify region explicitly
9. **Use SSM**: Prefer Session Manager over SSH
10. **Automate**: Script repetitive tasks
11. **Version CLI**: Keep AWS CLI updated
12. **Use --dry-run**: Test commands safely

### Quick Reference Card

| Command | What It Does |
|---------|-------------|
| `aws configure` | Configure credentials |
| `aws sts get-caller-identity` | Verify identity |
| `aws ec2 describe-instances` | List EC2 instances |
| `aws s3 ls` | List S3 buckets |
| `aws s3 sync` | Sync files to S3 |
| `aws logs tail` | Tail CloudWatch logs |
| `aws iam list-users` | List IAM users |
| `aws eks update-kubeconfig` | Configure kubectl |
| `aws ssm start-session` | Start SSM session |
| `aws lambda invoke` | Invoke Lambda function |

---

*May your queries be precise, your permissions be correct, and your API calls always successful.*

**— The Monk of Clouds**  
*Monastery of Infinite Scale*  
*Temple of AWS*

🧘 **Namaste, `aws`**

---

## 📚 Additional Resources

- [Official AWS CLI Documentation](https://docs.aws.amazon.com/cli/)
- [AWS CLI Command Reference](https://awscli.amazonaws.com/v2/documentation/api/latest/index.html)
- [JMESPath Tutorial](https://jmespath.org/tutorial.html)
- [AWS CLI Examples](https://github.com/awsdocs/aws-doc-sdk-examples/tree/main/aws-cli)
- [AWS CLI on GitHub](https://github.com/aws/aws-cli)

---

*Last Updated: 2025-10-02*  
*Version: 1.0.0 - The First Enlightenment*  
*AWS CLI Version: 2.x*
