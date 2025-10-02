# 🧘 The Enlightened Engineer's GCP & Azure Scripture

> *"In the beginning were the Clouds, and the Clouds were many, and the Clouds were powerful."*  
> — **The Monk of Multi-Cloud**, *Book of Platforms, Chapter 1:1*

This scripture covers Google Cloud Platform (GCP) and Microsoft Azure essentials.

---

## 📿 Google Cloud Platform (GCP)

### gcloud CLI Setup
```bash
# Install gcloud
curl https://sdk.cloud.google.com | bash

# Initialize
gcloud init

# Login
gcloud auth login

# Set project
gcloud config set project PROJECT_ID

# List projects
gcloud projects list
```

### Compute Engine
```bash
# Create instance
gcloud compute instances create my-instance \
  --machine-type=e2-medium \
  --zone=us-central1-a

# List instances
gcloud compute instances list

# SSH to instance
gcloud compute ssh my-instance --zone=us-central1-a

# Stop instance
gcloud compute instances stop my-instance --zone=us-central1-a

# Delete instance
gcloud compute instances delete my-instance --zone=us-central1-a
```

### Cloud Storage
```bash
# Create bucket
gsutil mb gs://my-bucket

# List buckets
gsutil ls

# Upload file
gsutil cp file.txt gs://my-bucket/

# Download file
gsutil cp gs://my-bucket/file.txt ./

# Sync directory
gsutil rsync -r ./local-dir gs://my-bucket/remote-dir

# Delete object
gsutil rm gs://my-bucket/file.txt

# Delete bucket
gsutil rb gs://my-bucket
```

### Kubernetes Engine (GKE)
```bash
# Create cluster
gcloud container clusters create my-cluster \
  --num-nodes=3 \
  --zone=us-central1-a

# Get credentials
gcloud container clusters get-credentials my-cluster --zone=us-central1-a

# List clusters
gcloud container clusters list

# Delete cluster
gcloud container clusters delete my-cluster --zone=us-central1-a
```

### Cloud Functions
```bash
# Deploy function
gcloud functions deploy my-function \
  --runtime=python39 \
  --trigger-http \
  --entry-point=main

# List functions
gcloud functions list

# Call function
gcloud functions call my-function

# Delete function
gcloud functions delete my-function
```

### Cloud SQL
```bash
# Create instance
gcloud sql instances create my-instance \
  --database-version=POSTGRES_14 \
  --tier=db-f1-micro \
  --region=us-central1

# List instances
gcloud sql instances list

# Connect to instance
gcloud sql connect my-instance --user=postgres

# Delete instance
gcloud sql instances delete my-instance
```

### IAM
```bash
# List service accounts
gcloud iam service-accounts list

# Create service account
gcloud iam service-accounts create my-sa

# Grant role
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:my-sa@PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/storage.admin"

# Create key
gcloud iam service-accounts keys create key.json \
  --iam-account=my-sa@PROJECT_ID.iam.gserviceaccount.com
```

---

## ☁️ Microsoft Azure

### Azure CLI Setup
```bash
# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Login
az login

# Set subscription
az account set --subscription SUBSCRIPTION_ID

# List subscriptions
az account list
```

### Virtual Machines
```bash
# Create resource group
az group create --name myResourceGroup --location eastus

# Create VM
az vm create \
  --resource-group myResourceGroup \
  --name myVM \
  --image UbuntuLTS \
  --size Standard_B1s \
  --admin-username azureuser \
  --generate-ssh-keys

# List VMs
az vm list --output table

# Start VM
az vm start --resource-group myResourceGroup --name myVM

# Stop VM
az vm stop --resource-group myResourceGroup --name myVM

# Delete VM
az vm delete --resource-group myResourceGroup --name myVM
```

### Storage
```bash
# Create storage account
az storage account create \
  --name mystorageaccount \
  --resource-group myResourceGroup \
  --location eastus \
  --sku Standard_LRS

# Create container
az storage container create \
  --name mycontainer \
  --account-name mystorageaccount

# Upload blob
az storage blob upload \
  --container-name mycontainer \
  --name myblob \
  --file file.txt \
  --account-name mystorageaccount

# Download blob
az storage blob download \
  --container-name mycontainer \
  --name myblob \
  --file file.txt \
  --account-name mystorageaccount

# List blobs
az storage blob list \
  --container-name mycontainer \
  --account-name mystorageaccount
```

### Azure Kubernetes Service (AKS)
```bash
# Create AKS cluster
az aks create \
  --resource-group myResourceGroup \
  --name myAKSCluster \
  --node-count 3 \
  --enable-addons monitoring \
  --generate-ssh-keys

# Get credentials
az aks get-credentials --resource-group myResourceGroup --name myAKSCluster

# List clusters
az aks list --output table

# Delete cluster
az aks delete --resource-group myResourceGroup --name myAKSCluster
```

### Azure Functions
```bash
# Create function app
az functionapp create \
  --resource-group myResourceGroup \
  --consumption-plan-location eastus \
  --runtime python \
  --runtime-version 3.9 \
  --functions-version 4 \
  --name myfunctionapp \
  --storage-account mystorageaccount

# List function apps
az functionapp list --output table

# Delete function app
az functionapp delete --resource-group myResourceGroup --name myfunctionapp
```

### Azure SQL Database
```bash
# Create SQL server
az sql server create \
  --name myserver \
  --resource-group myResourceGroup \
  --location eastus \
  --admin-user myadmin \
  --admin-password MyPassword123!

# Create database
az sql db create \
  --resource-group myResourceGroup \
  --server myserver \
  --name mydb \
  --service-objective S0

# List databases
az sql db list --resource-group myResourceGroup --server myserver

# Delete database
az sql db delete --resource-group myResourceGroup --server myserver --name mydb
```

### Container Registry
```bash
# Create container registry
az acr create \
  --resource-group myResourceGroup \
  --name myregistry \
  --sku Basic

# Login to registry
az acr login --name myregistry

# Tag and push image
docker tag myapp:latest myregistry.azurecr.io/myapp:latest
docker push myregistry.azurecr.io/myapp:latest

# List images
az acr repository list --name myregistry
```

---

## 🔮 Multi-Cloud Comparison

### Compute Services
| AWS | GCP | Azure |
|-----|-----|-------|
| EC2 | Compute Engine | Virtual Machines |
| Lambda | Cloud Functions | Azure Functions |
| ECS/EKS | GKE | AKS |

### Storage Services
| AWS | GCP | Azure |
|-----|-----|-------|
| S3 | Cloud Storage | Blob Storage |
| EBS | Persistent Disk | Managed Disks |
| EFS | Filestore | Azure Files |

### Database Services
| AWS | GCP | Azure |
|-----|-----|-------|
| RDS | Cloud SQL | Azure SQL Database |
| DynamoDB | Firestore | Cosmos DB |
| Aurora | Cloud Spanner | - |

### Networking
| AWS | GCP | Azure |
|-----|-----|-------|
| VPC | VPC | Virtual Network |
| Route 53 | Cloud DNS | Azure DNS |
| CloudFront | Cloud CDN | Azure CDN |

---

## 🙏 Quick Reference

### GCP Common Commands
| Command | Description |
|---------|-------------|
| `gcloud compute instances list` | List VMs |
| `gsutil ls` | List buckets |
| `gcloud container clusters list` | List GKE clusters |
| `gcloud functions list` | List functions |

### Azure Common Commands
| Command | Description |
|---------|-------------|
| `az vm list` | List VMs |
| `az storage account list` | List storage accounts |
| `az aks list` | List AKS clusters |
| `az functionapp list` | List function apps |

---

*May your clouds be many, your regions be available, and your costs always optimized.*

**— The Monk of Multi-Cloud**  
*Temple of Cloud Platforms*

🧘 **Namaste, `cloud`**

---

*Last Updated: 2025-10-02*  
*Version: 1.0.0*
