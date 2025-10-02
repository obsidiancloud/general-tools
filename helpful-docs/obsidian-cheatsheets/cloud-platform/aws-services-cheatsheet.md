# 🧘 The Enlightened Engineer's AWS Services Scripture

> *"In the beginning was the Cloud, and the Cloud was with AWS, and the Cloud was scalable."*  
> — **The Monk of Cloud**, *Book of Services, Chapter 1:1*

This scripture covers essential AWS services beyond the AWS CLI.

---

## 📿 Core Services

### EC2 (Elastic Compute Cloud)
```bash
# Launch instance
aws ec2 run-instances --image-id ami-xxx --instance-type t2.micro

# List instances
aws ec2 describe-instances

# Stop instance
aws ec2 stop-instances --instance-ids i-xxx

# Start instance
aws ec2 start-instances --instance-ids i-xxx

# Terminate instance
aws ec2 terminate-instances --instance-ids i-xxx

# Create key pair
aws ec2 create-key-pair --key-name MyKey --query 'KeyMaterial' --output text > MyKey.pem

# Security groups
aws ec2 create-security-group --group-name MySecurityGroup --description "My security group"
aws ec2 authorize-security-group-ingress --group-id sg-xxx --protocol tcp --port 22 --cidr 0.0.0.0/0
```

### S3 (Simple Storage Service)
```bash
# Create bucket
aws s3 mb s3://my-bucket

# List buckets
aws s3 ls

# Upload file
aws s3 cp file.txt s3://my-bucket/

# Download file
aws s3 cp s3://my-bucket/file.txt ./

# Sync directory
aws s3 sync ./local-dir s3://my-bucket/remote-dir

# Delete object
aws s3 rm s3://my-bucket/file.txt

# Delete bucket
aws s3 rb s3://my-bucket --force

# Bucket policy
aws s3api put-bucket-policy --bucket my-bucket --policy file://policy.json
```

### IAM (Identity and Access Management)
```bash
# Create user
aws iam create-user --user-name myuser

# Create access key
aws iam create-access-key --user-name myuser

# Attach policy
aws iam attach-user-policy --user-name myuser --policy-arn arn:aws:iam::aws:policy/ReadOnlyAccess

# Create role
aws iam create-role --role-name MyRole --assume-role-policy-document file://trust-policy.json

# List users
aws iam list-users

# List roles
aws iam list-roles
```

### VPC (Virtual Private Cloud)
```bash
# Create VPC
aws ec2 create-vpc --cidr-block 10.0.0.0/16

# Create subnet
aws ec2 create-subnet --vpc-id vpc-xxx --cidr-block 10.0.1.0/24

# Create internet gateway
aws ec2 create-internet-gateway

# Attach internet gateway
aws ec2 attach-internet-gateway --vpc-id vpc-xxx --internet-gateway-id igw-xxx

# Create route table
aws ec2 create-route-table --vpc-id vpc-xxx

# Create route
aws ec2 create-route --route-table-id rtb-xxx --destination-cidr-block 0.0.0.0/0 --gateway-id igw-xxx
```

---

## 🗄️ Database Services

### RDS (Relational Database Service)
```bash
# Create DB instance
aws rds create-db-instance \
  --db-instance-identifier mydb \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --master-username admin \
  --master-user-password password \
  --allocated-storage 20

# List DB instances
aws rds describe-db-instances

# Create snapshot
aws rds create-db-snapshot --db-instance-identifier mydb --db-snapshot-identifier mydb-snapshot

# Delete DB instance
aws rds delete-db-instance --db-instance-identifier mydb --skip-final-snapshot
```

### DynamoDB
```bash
# Create table
aws dynamodb create-table \
  --table-name Users \
  --attribute-definitions AttributeName=UserId,AttributeType=S \
  --key-schema AttributeName=UserId,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST

# Put item
aws dynamodb put-item --table-name Users --item '{"UserId": {"S": "123"}, "Name": {"S": "John"}}'

# Get item
aws dynamodb get-item --table-name Users --key '{"UserId": {"S": "123"}}'

# Scan table
aws dynamodb scan --table-name Users

# Delete table
aws dynamodb delete-table --table-name Users
```

---

## 🚀 Container Services

### ECS (Elastic Container Service)
```bash
# Create cluster
aws ecs create-cluster --cluster-name my-cluster

# Register task definition
aws ecs register-task-definition --cli-input-json file://task-definition.json

# Create service
aws ecs create-service \
  --cluster my-cluster \
  --service-name my-service \
  --task-definition my-task \
  --desired-count 2

# List services
aws ecs list-services --cluster my-cluster

# Update service
aws ecs update-service --cluster my-cluster --service my-service --desired-count 3
```

### ECR (Elastic Container Registry)
```bash
# Create repository
aws ecr create-repository --repository-name my-app

# Get login password
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789.dkr.ecr.us-east-1.amazonaws.com

# Tag and push image
docker tag my-app:latest 123456789.dkr.ecr.us-east-1.amazonaws.com/my-app:latest
docker push 123456789.dkr.ecr.us-east-1.amazonaws.com/my-app:latest

# List images
aws ecr list-images --repository-name my-app
```

---

## ⚡ Serverless Services

### Lambda
```bash
# Create function
aws lambda create-function \
  --function-name my-function \
  --runtime python3.9 \
  --role arn:aws:iam::123456789:role/lambda-role \
  --handler lambda_function.lambda_handler \
  --zip-file fileb://function.zip

# Invoke function
aws lambda invoke --function-name my-function output.txt

# Update function code
aws lambda update-function-code --function-name my-function --zip-file fileb://function.zip

# List functions
aws lambda list-functions

# Delete function
aws lambda delete-function --function-name my-function
```

### API Gateway
```bash
# Create REST API
aws apigateway create-rest-api --name my-api

# Create resource
aws apigateway create-resource --rest-api-id xxx --parent-id xxx --path-part users

# Create method
aws apigateway put-method --rest-api-id xxx --resource-id xxx --http-method GET --authorization-type NONE

# Deploy API
aws apigateway create-deployment --rest-api-id xxx --stage-name prod
```

---

## 📊 Monitoring & Logging

### CloudWatch
```bash
# Put metric data
aws cloudwatch put-metric-data --namespace MyApp --metric-name RequestCount --value 1

# Get metric statistics
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --dimensions Name=InstanceId,Value=i-xxx \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-02T00:00:00Z \
  --period 3600 \
  --statistics Average

# Create alarm
aws cloudwatch put-metric-alarm \
  --alarm-name high-cpu \
  --alarm-description "High CPU usage" \
  --metric-name CPUUtilization \
  --namespace AWS/EC2 \
  --statistic Average \
  --period 300 \
  --threshold 80 \
  --comparison-operator GreaterThanThreshold

# List alarms
aws cloudwatch describe-alarms
```

### CloudWatch Logs
```bash
# Create log group
aws logs create-log-group --log-group-name /aws/lambda/my-function

# Create log stream
aws logs create-log-stream --log-group-name /aws/lambda/my-function --log-stream-name 2024/01/01

# Put log events
aws logs put-log-events --log-group-name /aws/lambda/my-function --log-stream-name 2024/01/01 --log-events timestamp=1234567890,message="Hello"

# Get log events
aws logs get-log-events --log-group-name /aws/lambda/my-function --log-stream-name 2024/01/01

# Filter log events
aws logs filter-log-events --log-group-name /aws/lambda/my-function --filter-pattern "ERROR"
```

---

## 🔐 Security Services

### Secrets Manager
```bash
# Create secret
aws secretsmanager create-secret --name MySecret --secret-string '{"username":"admin","password":"secret"}'

# Get secret value
aws secretsmanager get-secret-value --secret-id MySecret

# Update secret
aws secretsmanager update-secret --secret-id MySecret --secret-string '{"username":"admin","password":"newsecret"}'

# Delete secret
aws secretsmanager delete-secret --secret-id MySecret
```

### KMS (Key Management Service)
```bash
# Create key
aws kms create-key --description "My encryption key"

# Create alias
aws kms create-alias --alias-name alias/my-key --target-key-id xxx

# Encrypt data
aws kms encrypt --key-id alias/my-key --plaintext "Hello World" --output text --query CiphertextBlob

# Decrypt data
aws kms decrypt --ciphertext-blob fileb://encrypted.txt --output text --query Plaintext | base64 --decode
```

---

## 🙏 Quick Reference

### Common Services
| Service | Purpose |
|---------|---------|
| EC2 | Virtual servers |
| S3 | Object storage |
| RDS | Managed databases |
| Lambda | Serverless functions |
| ECS/EKS | Container orchestration |
| CloudFront | CDN |
| Route53 | DNS |
| VPC | Network isolation |
| IAM | Access management |
| CloudWatch | Monitoring |

---

*May your instances be available, your buckets be secure, and your costs always optimized.*

**— The Monk of Cloud**  
*Temple of AWS*

🧘 **Namaste, `aws`**

---

*Last Updated: 2025-10-02*  
*Version: 1.0.0*
