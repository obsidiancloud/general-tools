# 🧘 The Enlightened Engineer's Kubernetes & kubectl Scripture

> *"In the beginning was the Pod, and the Pod was with the Cluster, and the Pod was orchestrated."*  
> — **The Monk of Kubernetes**, *Book of Orchestration, Chapter 1:1*

Greetings, fellow traveler on the path of container orchestration enlightenment. I am but a humble monk who has meditated upon the sacred texts of Borg and witnessed the dance of pods across countless clusters.

This scripture shall guide you through the mystical arts of Kubernetes and kubectl, with the precision of a master's declarative manifest and the wit of a caffeinated cluster administrator.

---

## 📿 Table of Sacred Knowledge

1. [kubectl Configuration & Setup](#-kubectl-configuration--setup)
2. [Contexts & Clusters](#-contexts--clusters-the-many-realms)
3. [Pod Management](#-pod-management-the-atomic-units)
4. [Deployments](#-deployments-the-path-of-replication)
5. [Services & Networking](#-services--networking-the-web-of-connection)
6. [ConfigMaps & Secrets](#-configmaps--secrets-the-sacred-scrolls)
7. [Persistent Volumes](#-persistent-volumes-the-eternal-storage)
8. [Resource Management](#-resource-management-the-balance-of-power)
9. [Debugging & Inspection](#-debugging--inspection-seeing-the-truth)
10. [Advanced kubectl Techniques](#-advanced-kubectl-techniques)
11. [AWS EKS Operations](#-aws-eks-operations-the-cloud-temple)
12. [Common Patterns: The Sacred Workflows](#-common-patterns-the-sacred-workflows)
13. [Troubleshooting](#-troubleshooting-when-the-path-is-obscured)

---

## 🛠 kubectl Configuration & Setup

*Before commanding the cluster, one must first connect to it.*

### Installation

```bash
# Linux
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# macOS
brew install kubectl

# Verify installation
kubectl version --client
kubectl version --short
```

### Initial Configuration

```bash
# View config
kubectl config view
kubectl config view --minify  # Current context only

# Set cluster credentials (manual)
kubectl config set-cluster my-cluster --server=https://k8s.example.com
kubectl config set-credentials admin --token=bearer_token
kubectl config set-context my-context --cluster=my-cluster --user=admin

# Set namespace preference
kubectl config set-context --current --namespace=production
```

### Essential Aliases (The Shortcuts of the Wise)

```bash
# Add to ~/.bashrc or ~/.zshrc
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgd='kubectl get deployments'
alias kgn='kubectl get nodes'
alias kdp='kubectl describe pod'
alias kdd='kubectl describe deployment'
alias kl='kubectl logs'
alias kx='kubectl exec -it'
alias ka='kubectl apply -f'
alias kdel='kubectl delete'

# Enable kubectl completion
source <(kubectl completion bash)  # bash
source <(kubectl completion zsh)   # zsh
```

### Powerful kubectl Configurations

```bash
# Set default output format
kubectl config set-context --current --namespace=default

# Create kubeconfig from scratch
export KUBECONFIG=~/.kube/config

# Merge multiple kubeconfigs
KUBECONFIG=~/.kube/config:~/.kube/config-eks kubectl config view --flatten > ~/.kube/merged-config
export KUBECONFIG=~/.kube/merged-config
```

---

## 🌍 Contexts & Clusters: The Many Realms

*A monk may serve many monasteries, switching between them with grace.*

### Managing Contexts

```bash
# List contexts
kubectl config get-contexts
kubectl config current-context

# Switch context
kubectl config use-context production
kubectl config use-context staging

# Rename context
kubectl config rename-context old-name new-name

# Delete context
kubectl config delete-context old-context

# Set default namespace for context
kubectl config set-context production --namespace=prod-apps
```

### Quick Context Switching

```bash
# Using kubectx (install: brew install kubectx)
kubectx                    # List contexts
kubectx production         # Switch to production
kubectx -                  # Switch to previous context

# Using kubens (namespace switching)
kubens                     # List namespaces
kubens production          # Switch to production namespace
kubens -                   # Switch to previous namespace
```

### Cluster Information

```bash
# Cluster info
kubectl cluster-info
kubectl cluster-info dump

# API resources
kubectl api-resources
kubectl api-resources --namespaced=true
kubectl api-resources --namespaced=false

# API versions
kubectl api-versions

# Node information
kubectl get nodes
kubectl get nodes -o wide
kubectl describe node node-name
kubectl top nodes          # Resource usage
```

---

## 🌱 Pod Management: The Atomic Units

*The Pod is the smallest unit of enlightenment in the Kubernetes realm.*

### Creating Pods

```bash
# Run pod imperatively
kubectl run nginx --image=nginx
kubectl run nginx --image=nginx --port=80
kubectl run nginx --image=nginx --dry-run=client -o yaml > pod.yaml

# Run with specific options
kubectl run busybox --image=busybox --restart=Never --rm -it -- sh
kubectl run test --image=nginx --env="ENV=prod" --labels="app=test,tier=frontend"

# From YAML
kubectl apply -f pod.yaml
kubectl create -f pod.yaml
```

### Listing & Inspecting Pods

```bash
# List pods
kubectl get pods
kubectl get pods -o wide                    # More details
kubectl get pods -A                         # All namespaces
kubectl get pods -n namespace-name
kubectl get pods --show-labels
kubectl get pods -l app=nginx               # Label selector
kubectl get pods --field-selector status.phase=Running

# Watch pods
kubectl get pods -w
kubectl get pods -w -o wide

# Describe pod
kubectl describe pod pod-name
kubectl describe pod pod-name -n namespace

# Get pod YAML
kubectl get pod pod-name -o yaml
kubectl get pod pod-name -o json
```

### Pod Logs

```bash
# View logs
kubectl logs pod-name
kubectl logs pod-name -c container-name     # Specific container
kubectl logs pod-name --previous            # Previous instance
kubectl logs pod-name --tail=100            # Last 100 lines
kubectl logs pod-name --since=1h            # Last hour
kubectl logs pod-name -f                    # Follow/stream

# Multi-container pods
kubectl logs pod-name --all-containers=true
kubectl logs pod-name -c sidecar

# Logs with timestamps
kubectl logs pod-name --timestamps
```

### Executing Commands in Pods

```bash
# Execute command
kubectl exec pod-name -- ls /app
kubectl exec pod-name -c container-name -- env

# Interactive shell
kubectl exec -it pod-name -- /bin/bash
kubectl exec -it pod-name -- sh
kubectl exec -it pod-name -c container -- /bin/sh

# Debug with ephemeral container (K8s 1.23+)
kubectl debug pod-name -it --image=busybox --target=container-name
```

### Copying Files

```bash
# Copy from pod
kubectl cp pod-name:/path/to/file ./local-file
kubectl cp namespace/pod-name:/path/to/file ./local-file

# Copy to pod
kubectl cp ./local-file pod-name:/path/to/file
kubectl cp ./local-file pod-name:/path/to/file -c container-name
```

### Deleting Pods

```bash
# Delete pod
kubectl delete pod pod-name
kubectl delete pod pod-name --grace-period=0 --force  # Force delete
kubectl delete pods --all                              # All in namespace
kubectl delete pods -l app=nginx                       # By label
```

---

## 🔄 Deployments: The Path of Replication

*Deployments bring order to chaos, ensuring your pods are always present.*

### Creating Deployments

```bash
# Create deployment imperatively
kubectl create deployment nginx --image=nginx
kubectl create deployment nginx --image=nginx --replicas=3
kubectl create deployment nginx --image=nginx --dry-run=client -o yaml > deployment.yaml

# From YAML
kubectl apply -f deployment.yaml

# Expose deployment as service
kubectl expose deployment nginx --port=80 --target-port=80 --type=LoadBalancer
```

### Managing Deployments

```bash
# List deployments
kubectl get deployments
kubectl get deploy -o wide
kubectl get deploy -A

# Describe deployment
kubectl describe deployment nginx

# Get deployment YAML
kubectl get deployment nginx -o yaml

# Edit deployment
kubectl edit deployment nginx

# Set image (update)
kubectl set image deployment/nginx nginx=nginx:1.21
kubectl set image deployment/nginx nginx=nginx:1.21 --record
```

### Scaling

```bash
# Scale deployment
kubectl scale deployment nginx --replicas=5
kubectl scale deployment nginx --replicas=3

# Autoscaling
kubectl autoscale deployment nginx --min=2 --max=10 --cpu-percent=80

# View HPA
kubectl get hpa
kubectl describe hpa nginx
```

### Rollouts & Rollbacks

```bash
# Rollout status
kubectl rollout status deployment/nginx
kubectl rollout history deployment/nginx
kubectl rollout history deployment/nginx --revision=2

# Pause/resume rollout
kubectl rollout pause deployment/nginx
kubectl rollout resume deployment/nginx

# Rollback
kubectl rollout undo deployment/nginx
kubectl rollout undo deployment/nginx --to-revision=2

# Restart deployment (rolling restart)
kubectl rollout restart deployment/nginx
```

### Deployment Strategies

```bash
# RollingUpdate (default)
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0

# Recreate (downtime)
spec:
  strategy:
    type: Recreate
```

---

## 🌐 Services & Networking: The Web of Connection

*Services are the bridges between pods, the paths of communication.*

### Creating Services

```bash
# Create service imperatively
kubectl expose deployment nginx --port=80 --target-port=80
kubectl expose pod nginx --port=80 --name=nginx-service
kubectl create service clusterip nginx --tcp=80:80
kubectl create service nodeport nginx --tcp=80:80 --node-port=30080
kubectl create service loadbalancer nginx --tcp=80:80

# From YAML
kubectl apply -f service.yaml
```

### Service Types

```bash
# ClusterIP (internal only)
kubectl create service clusterip my-svc --tcp=80:8080

# NodePort (external access via node IP)
kubectl create service nodeport my-svc --tcp=80:8080 --node-port=30080

# LoadBalancer (cloud provider LB)
kubectl create service loadbalancer my-svc --tcp=80:8080

# ExternalName (DNS alias)
kubectl create service externalname my-svc --external-name=example.com
```

### Inspecting Services

```bash
# List services
kubectl get services
kubectl get svc -o wide
kubectl get svc -A

# Describe service
kubectl describe svc nginx

# Get endpoints
kubectl get endpoints
kubectl get ep nginx

# Service DNS testing
kubectl run tmp --image=busybox --rm -it -- nslookup nginx.default.svc.cluster.local
```

### Ingress

```bash
# List ingress
kubectl get ingress
kubectl get ing -A

# Describe ingress
kubectl describe ingress my-ingress

# Create ingress
kubectl create ingress my-ingress --rule="host.com/path=service:port"

# Example ingress YAML
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx
            port:
              number: 80
```

### Network Policies

```bash
# List network policies
kubectl get networkpolicies
kubectl get netpol

# Describe network policy
kubectl describe netpol my-policy

# Example: Deny all ingress
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
```

---

## 📜 ConfigMaps & Secrets: The Sacred Scrolls

*Configuration and secrets, separated from code, as wisdom dictates.*

### ConfigMaps

```bash
# Create from literal
kubectl create configmap my-config --from-literal=key1=value1 --from-literal=key2=value2

# Create from file
kubectl create configmap my-config --from-file=config.txt
kubectl create configmap my-config --from-file=configs/

# Create from env file
kubectl create configmap my-config --from-env-file=config.env

# List configmaps
kubectl get configmaps
kubectl get cm

# Describe configmap
kubectl describe cm my-config

# Get configmap data
kubectl get cm my-config -o yaml

# Edit configmap
kubectl edit cm my-config

# Delete configmap
kubectl delete cm my-config
```

### Secrets

```bash
# Create generic secret
kubectl create secret generic my-secret --from-literal=password=secret123
kubectl create secret generic my-secret --from-file=ssh-key=~/.ssh/id_rsa

# Create TLS secret
kubectl create secret tls tls-secret --cert=path/to/cert --key=path/to/key

# Create docker registry secret
kubectl create secret docker-registry regcred \
  --docker-server=registry.example.com \
  --docker-username=user \
  --docker-password=pass \
  --docker-email=user@example.com

# List secrets
kubectl get secrets
kubectl get secret my-secret -o yaml

# Decode secret
kubectl get secret my-secret -o jsonpath='{.data.password}' | base64 -d

# Edit secret
kubectl edit secret my-secret

# Delete secret
kubectl delete secret my-secret
```

### Using ConfigMaps & Secrets in Pods

```yaml
# Environment variables from ConfigMap
env:
- name: CONFIG_KEY
  valueFrom:
    configMapKeyRef:
      name: my-config
      key: key1

# Environment variables from Secret
env:
- name: PASSWORD
  valueFrom:
    secretKeyRef:
      name: my-secret
      key: password

# Volume mount ConfigMap
volumes:
- name: config-volume
  configMap:
    name: my-config
volumeMounts:
- name: config-volume
  mountPath: /etc/config

# Volume mount Secret
volumes:
- name: secret-volume
  secret:
    secretName: my-secret
volumeMounts:
- name: secret-volume
  mountPath: /etc/secrets
  readOnly: true
```

---

## 💾 Persistent Volumes: The Eternal Storage

*Data persists beyond the life of pods, stored in the sacred volumes.*

### Persistent Volumes (PV)

```bash
# List PVs
kubectl get pv
kubectl get persistentvolumes

# Describe PV
kubectl describe pv pv-name

# Delete PV
kubectl delete pv pv-name
```

### Persistent Volume Claims (PVC)

```bash
# List PVCs
kubectl get pvc
kubectl get persistentvolumeclaims

# Describe PVC
kubectl describe pvc pvc-name

# Create PVC
kubectl apply -f pvc.yaml

# Delete PVC
kubectl delete pvc pvc-name

# Example PVC YAML
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: gp2
```

### Storage Classes

```bash
# List storage classes
kubectl get storageclass
kubectl get sc

# Describe storage class
kubectl describe sc gp2

# Set default storage class
kubectl patch storageclass gp2 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

### Using PVCs in Pods

```yaml
spec:
  volumes:
  - name: data-volume
    persistentVolumeClaim:
      claimName: my-pvc
  containers:
  - name: app
    volumeMounts:
    - name: data-volume
      mountPath: /data
```

---

## ⚖️ Resource Management: The Balance of Power

*Resources must be managed wisely, lest chaos consume the cluster.*

### Resource Requests & Limits

```yaml
# Pod with resource requests/limits
spec:
  containers:
  - name: app
    resources:
      requests:
        memory: "128Mi"
        cpu: "250m"
      limits:
        memory: "256Mi"
        cpu: "500m"
```

### Resource Quotas

```bash
# List resource quotas
kubectl get resourcequota
kubectl get quota

# Describe quota
kubectl describe quota my-quota

# Create quota
kubectl create quota my-quota --hard=pods=10,requests.cpu=4,requests.memory=8Gi

# Example ResourceQuota YAML
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-quota
spec:
  hard:
    requests.cpu: "10"
    requests.memory: 20Gi
    limits.cpu: "20"
    limits.memory: 40Gi
    persistentvolumeclaims: "10"
```

### Limit Ranges

```bash
# List limit ranges
kubectl get limitrange
kubectl get limits

# Describe limit range
kubectl describe limitrange my-limits

# Example LimitRange YAML
apiVersion: v1
kind: LimitRange
metadata:
  name: mem-limit-range
spec:
  limits:
  - default:
      memory: 512Mi
      cpu: 500m
    defaultRequest:
      memory: 256Mi
      cpu: 250m
    type: Container
```

### Viewing Resource Usage

```bash
# Node resource usage
kubectl top nodes
kubectl top nodes --sort-by=cpu
kubectl top nodes --sort-by=memory

# Pod resource usage
kubectl top pods
kubectl top pods -A
kubectl top pods --sort-by=cpu
kubectl top pods --sort-by=memory
kubectl top pod pod-name --containers
```

---

## 🔍 Debugging & Inspection: Seeing the Truth

*To solve a problem, one must first see it clearly.*

### Describe Resources

```bash
# Describe various resources
kubectl describe pod pod-name
kubectl describe deployment deployment-name
kubectl describe service service-name
kubectl describe node node-name
kubectl describe pvc pvc-name
```

### Events

```bash
# View events
kubectl get events
kubectl get events --sort-by='.lastTimestamp'
kubectl get events --field-selector type=Warning
kubectl get events --field-selector involvedObject.name=pod-name
kubectl get events -w  # Watch events

# Events for specific namespace
kubectl get events -n namespace-name
```

### Logs

```bash
# Pod logs
kubectl logs pod-name
kubectl logs pod-name -f                    # Follow
kubectl logs pod-name --previous            # Previous container
kubectl logs pod-name -c container-name     # Specific container
kubectl logs pod-name --tail=100            # Last 100 lines
kubectl logs pod-name --since=1h            # Last hour

# Deployment logs (all pods)
kubectl logs deployment/nginx
kubectl logs deployment/nginx -f

# Label selector logs
kubectl logs -l app=nginx
kubectl logs -l app=nginx --all-containers=true
```

### Port Forwarding

```bash
# Forward pod port to local
kubectl port-forward pod/nginx 8080:80
kubectl port-forward pod/nginx 8080:80 --address=0.0.0.0

# Forward service port
kubectl port-forward service/nginx 8080:80

# Forward deployment port
kubectl port-forward deployment/nginx 8080:80
```

### Debug Containers (K8s 1.23+)

```bash
# Create debug container in pod
kubectl debug pod-name -it --image=busybox
kubectl debug pod-name -it --image=ubuntu --target=container-name

# Debug node
kubectl debug node/node-name -it --image=ubuntu

# Create copy of pod for debugging
kubectl debug pod-name -it --copy-to=debug-pod --container=debug
```

### Proxy & API Access

```bash
# Start kubectl proxy
kubectl proxy
kubectl proxy --port=8080

# Access API
curl http://localhost:8001/api/v1/namespaces/default/pods

# Direct API access
kubectl get --raw /api/v1/namespaces/default/pods
```

---

## 🔮 Advanced kubectl Techniques

*For those seeking deeper wisdom.*

### Custom Columns

```bash
# Custom output columns
kubectl get pods -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,NODE:.spec.nodeName

kubectl get nodes -o custom-columns=NAME:.metadata.name,CPU:.status.capacity.cpu,MEMORY:.status.capacity.memory

# Deployment with custom columns
kubectl get deploy -o custom-columns=NAME:.metadata.name,REPLICAS:.spec.replicas,IMAGE:.spec.template.spec.containers[0].image
```

### JSONPath

```bash
# Extract specific fields
kubectl get pods -o jsonpath='{.items[*].metadata.name}'
kubectl get pods -o jsonpath='{.items[*].status.podIP}'

# With range
kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.phase}{"\n"}{end}'

# Nested fields
kubectl get pods -o jsonpath='{.items[0].spec.containers[0].image}'

# Filter by field
kubectl get pods -o jsonpath='{.items[?(@.status.phase=="Running")].metadata.name}'
```

### Label Selectors

```bash
# Equality-based
kubectl get pods -l app=nginx
kubectl get pods -l app=nginx,tier=frontend
kubectl get pods -l 'app in (nginx,apache)'
kubectl get pods -l 'app notin (nginx,apache)'

# Set-based
kubectl get pods -l 'environment,tier'
kubectl get pods -l 'environment!=production'

# Label operations
kubectl label pods pod-name app=nginx
kubectl label pods pod-name app=nginx --overwrite
kubectl label pods pod-name app-  # Remove label
```

### Field Selectors

```bash
# Select by field
kubectl get pods --field-selector status.phase=Running
kubectl get pods --field-selector status.phase!=Running
kubectl get services --field-selector metadata.namespace=default
kubectl get pods --field-selector spec.nodeName=node-1

# Multiple selectors
kubectl get pods --field-selector status.phase=Running,spec.restartPolicy=Always
```

### Patching Resources

```bash
# Strategic merge patch
kubectl patch deployment nginx -p '{"spec":{"replicas":5}}'

# JSON patch
kubectl patch pod pod-name --type='json' -p='[{"op": "replace", "path": "/spec/containers/0/image", "value":"nginx:1.21"}]'

# Merge patch
kubectl patch service nginx --type merge -p '{"spec":{"type":"LoadBalancer"}}'
```

### Dry Run & Diff

```bash
# Dry run (client-side)
kubectl apply -f deployment.yaml --dry-run=client

# Dry run (server-side)
kubectl apply -f deployment.yaml --dry-run=server

# Show diff before applying
kubectl diff -f deployment.yaml

# Generate YAML without creating
kubectl create deployment nginx --image=nginx --dry-run=client -o yaml
```

### Kustomize

```bash
# Apply kustomization
kubectl apply -k ./kustomize/overlays/production

# View kustomization output
kubectl kustomize ./kustomize/overlays/production

# Build kustomization
kubectl kustomize ./kustomize/base > output.yaml
```

### Helm Integration

```bash
# Install helm chart
helm install my-release stable/nginx

# List helm releases
helm list

# Upgrade release
helm upgrade my-release stable/nginx

# Rollback release
helm rollback my-release 1

# Uninstall release
helm uninstall my-release

# Get manifest
helm get manifest my-release
```

---

## ☁️ AWS EKS Operations: The Cloud Temple

*The AWS monastery requires special rituals and incantations.*

### EKS Cluster Setup

```bash
# Install eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# Create EKS cluster
eksctl create cluster \
  --name my-cluster \
  --region us-east-1 \
  --nodegroup-name standard-workers \
  --node-type t3.medium \
  --nodes 3 \
  --nodes-min 1 \
  --nodes-max 4 \
  --managed

# Create cluster with Fargate
eksctl create cluster \
  --name my-cluster \
  --region us-east-1 \
  --fargate

# Delete cluster
eksctl delete cluster --name my-cluster --region us-east-1
```

### EKS Authentication

```bash
# Update kubeconfig for EKS
aws eks update-kubeconfig --region us-east-1 --name my-cluster
aws eks update-kubeconfig --region us-east-1 --name my-cluster --alias my-cluster-prod

# Verify connection
kubectl get svc
kubectl cluster-info

# Get cluster details
aws eks describe-cluster --name my-cluster --region us-east-1

# List clusters
aws eks list-clusters --region us-east-1
```

### IAM Roles for Service Accounts (IRSA)

```bash
# Create OIDC provider
eksctl utils associate-iam-oidc-provider \
  --cluster my-cluster \
  --region us-east-1 \
  --approve

# Create IAM service account
eksctl create iamserviceaccount \
  --name my-service-account \
  --namespace default \
  --cluster my-cluster \
  --region us-east-1 \
  --attach-policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess \
  --approve

# List IAM service accounts
eksctl get iamserviceaccount --cluster my-cluster --region us-east-1

# Delete IAM service account
eksctl delete iamserviceaccount \
  --name my-service-account \
  --namespace default \
  --cluster my-cluster \
  --region us-east-1
```

### EKS Node Groups

```bash
# Create managed node group
eksctl create nodegroup \
  --cluster my-cluster \
  --region us-east-1 \
  --name ng-1 \
  --node-type t3.medium \
  --nodes 3 \
  --nodes-min 1 \
  --nodes-max 4 \
  --managed

# Create Spot instance node group
eksctl create nodegroup \
  --cluster my-cluster \
  --region us-east-1 \
  --name spot-ng \
  --spot \
  --instance-types t3.medium,t3.large \
  --nodes 2 \
  --nodes-min 1 \
  --nodes-max 5

# List node groups
eksctl get nodegroup --cluster my-cluster --region us-east-1

# Scale node group
eksctl scale nodegroup \
  --cluster my-cluster \
  --region us-east-1 \
  --name ng-1 \
  --nodes 5

# Delete node group
eksctl delete nodegroup \
  --cluster my-cluster \
  --region us-east-1 \
  --name ng-1
```

### EKS Fargate Profiles

```bash
# Create Fargate profile
eksctl create fargateprofile \
  --cluster my-cluster \
  --region us-east-1 \
  --name fp-default \
  --namespace default

# List Fargate profiles
eksctl get fargateprofile --cluster my-cluster --region us-east-1

# Delete Fargate profile
eksctl delete fargateprofile \
  --cluster my-cluster \
  --region us-east-1 \
  --name fp-default
```

### AWS Load Balancer Controller

```bash
# Install AWS Load Balancer Controller
helm repo add eks https://aws.github.io/eks-charts
helm repo update

# Create IAM policy
curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.7/docs/install/iam_policy.json
aws iam create-policy \
  --policy-name AWSLoadBalancerControllerIAMPolicy \
  --policy-document file://iam_policy.json

# Create service account
eksctl create iamserviceaccount \
  --cluster=my-cluster \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --attach-policy-arn=arn:aws:iam::ACCOUNT_ID:policy/AWSLoadBalancerControllerIAMPolicy \
  --override-existing-serviceaccounts \
  --approve

# Install controller
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=my-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller

# Verify installation
kubectl get deployment -n kube-system aws-load-balancer-controller
```

### EBS CSI Driver & Storage

```bash
# Install EBS CSI driver
eksctl create iamserviceaccount \
  --name ebs-csi-controller-sa \
  --namespace kube-system \
  --cluster my-cluster \
  --region us-east-1 \
  --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --approve

# Install via addon
aws eks create-addon \
  --cluster-name my-cluster \
  --addon-name aws-ebs-csi-driver \
  --region us-east-1

# Create storage class
kubectl apply -f - <<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ebs-sc
provisioner: ebs.csi.aws.com
volumeBindingMode: WaitForFirstConsumer
parameters:
  type: gp3
  encrypted: "true"
EOF

# List storage classes
kubectl get sc
```

### EKS Add-ons Management

```bash
# List available add-ons
aws eks describe-addon-versions --region us-east-1

# List installed add-ons
aws eks list-addons --cluster-name my-cluster --region us-east-1

# Install add-on
aws eks create-addon \
  --cluster-name my-cluster \
  --addon-name vpc-cni \
  --region us-east-1

# Update add-on
aws eks update-addon \
  --cluster-name my-cluster \
  --addon-name vpc-cni \
  --addon-version v1.12.0-eksbuild.1 \
  --region us-east-1

# Delete add-on
aws eks delete-addon \
  --cluster-name my-cluster \
  --addon-name vpc-cni \
  --region us-east-1
```

### ECR Integration

```bash
# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com

# Create ECR repository
aws ecr create-repository --repository-name my-app --region us-east-1

# Tag and push image
docker tag my-app:latest ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/my-app:latest
docker push ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/my-app:latest

# Create pull secret for ECR (if needed)
kubectl create secret docker-registry ecr-secret \
  --docker-server=ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password --region us-east-1)
```

### EKS Ingress with ALB

```yaml
# Application Load Balancer Ingress
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:us-east-1:ACCOUNT_ID:certificate/CERT_ID
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS": 443}]'
    alb.ingress.kubernetes.io/ssl-redirect: '443'
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-service
            port:
              number: 80
```

### EKS Best Practices

```bash
# Enable control plane logging
aws eks update-cluster-config \
  --name my-cluster \
  --region us-east-1 \
  --logging '{"clusterLogging":[{"types":["api","audit","authenticator","controllerManager","scheduler"],"enabled":true}]}'

# Update cluster version
aws eks update-cluster-version \
  --name my-cluster \
  --region us-east-1 \
  --kubernetes-version 1.28

# Enable secrets encryption
aws eks associate-encryption-config \
  --cluster-name my-cluster \
  --region us-east-1 \
  --encryption-config '[{"resources":["secrets"],"provider":{"keyArn":"arn:aws:kms:us-east-1:ACCOUNT_ID:key/KEY_ID"}}]'
```

### EKS Cost Optimization

```bash
# Use Spot instances
eksctl create nodegroup \
  --cluster my-cluster \
  --spot \
  --instance-types t3.medium,t3.large,t3a.medium \
  --nodes-min 1 \
  --nodes-max 10

# Use Fargate for batch workloads
# Fargate charges per vCPU/memory per second

# Right-size node groups
kubectl top nodes
kubectl top pods -A

# Use Cluster Autoscaler
kubectl apply -f https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml

# Set resource requests/limits
# Prevents over-provisioning
```

### EKS Troubleshooting

```bash
# Check cluster status
aws eks describe-cluster --name my-cluster --region us-east-1 --query 'cluster.status'

# View control plane logs
aws logs tail /aws/eks/my-cluster/cluster --follow

# Check node status
kubectl get nodes
kubectl describe node node-name

# Check IAM authenticator
kubectl get configmap aws-auth -n kube-system -o yaml

# Test IRSA
kubectl run test --image=amazon/aws-cli --rm -it -- sts get-caller-identity

# Debug networking
kubectl run tmp --image=busybox --rm -it -- wget -O- http://service-name.namespace.svc.cluster.local
```

---

## 🔮 Common Patterns: The Sacred Workflows

*These are the rituals performed by monks in production temples daily.*

### Pattern 1: Rolling Update Deployment

```bash
# Step 1: Update deployment image
kubectl set image deployment/my-app app=my-app:v2 --record

# Step 2: Watch rollout status
kubectl rollout status deployment/my-app

# Step 3: Verify new pods
kubectl get pods -l app=my-app

# Step 4: Check application health
kubectl port-forward deployment/my-app 8080:80
curl http://localhost:8080/health

# Step 5: Rollback if needed
kubectl rollout undo deployment/my-app
```

**Use case**: Zero-downtime application updates  
**Best for**: Production deployments with gradual rollout

### Pattern 2: Blue/Green Deployment

```bash
# Step 1: Deploy green version
kubectl apply -f deployment-green.yaml

# Step 2: Wait for green to be ready
kubectl wait --for=condition=available --timeout=300s deployment/my-app-green

# Step 3: Test green deployment
kubectl port-forward deployment/my-app-green 8080:80

# Step 4: Switch service to green
kubectl patch service my-app -p '{"spec":{"selector":{"version":"green"}}}'

# Step 5: Verify traffic switch
kubectl get endpoints my-app

# Step 6: Delete blue deployment (after validation)
kubectl delete deployment my-app-blue
```

**Use case**: Instant rollback capability  
**Best for**: Critical applications requiring immediate rollback

### Pattern 3: Canary Deployment

```bash
# Step 1: Deploy canary with 10% traffic
kubectl apply -f deployment-canary.yaml  # 1 replica
kubectl apply -f deployment-stable.yaml  # 9 replicas

# Step 2: Monitor canary metrics
kubectl logs -l version=canary -f
kubectl top pods -l version=canary

# Step 3: Gradually increase canary traffic
kubectl scale deployment my-app-canary --replicas=3
kubectl scale deployment my-app-stable --replicas=7

# Step 4: Full rollout if successful
kubectl scale deployment my-app-canary --replicas=10
kubectl scale deployment my-app-stable --replicas=0

# Step 5: Cleanup old version
kubectl delete deployment my-app-stable
kubectl label deployment my-app-canary version=stable
```

**Use case**: Gradual rollout with risk mitigation  
**Best for**: Testing new features with subset of users

### Pattern 4: Debugging CrashLoopBackOff

```bash
# Step 1: Identify crashing pod
kubectl get pods | grep CrashLoopBackOff

# Step 2: Check pod events
kubectl describe pod pod-name | grep -A 10 Events

# Step 3: View current logs
kubectl logs pod-name

# Step 4: View previous container logs
kubectl logs pod-name --previous

# Step 5: Check resource limits
kubectl describe pod pod-name | grep -A 5 Limits

# Step 6: Debug with ephemeral container
kubectl debug pod-name -it --image=busybox --target=container-name

# Step 7: Check liveness/readiness probes
kubectl get pod pod-name -o yaml | grep -A 10 livenessProbe
```

**Use case**: Troubleshooting failing pods  
**Best for**: Identifying root cause of pod failures

### Pattern 5: Secrets Rotation

```bash
# Step 1: Create new secret version
kubectl create secret generic my-secret-v2 --from-literal=password=newpass123

# Step 2: Update deployment to use new secret
kubectl set env deployment/my-app --from=secret/my-secret-v2 --prefix=NEW_

# Step 3: Trigger rolling restart
kubectl rollout restart deployment/my-app

# Step 4: Verify new secret in use
kubectl exec deployment/my-app -- env | grep NEW_

# Step 5: Delete old secret
kubectl delete secret my-secret

# Step 6: Rename new secret
kubectl get secret my-secret-v2 -o yaml | sed 's/my-secret-v2/my-secret/' | kubectl apply -f -
kubectl delete secret my-secret-v2
```

**Use case**: Rotating credentials without downtime  
**Best for**: Security compliance and credential management

---

## 🔧 Troubleshooting: When the Path is Obscured

*Even the wisest monks encounter obstacles.*

### Common Issues

#### CrashLoopBackOff

```bash
# Check logs
kubectl logs pod-name
kubectl logs pod-name --previous

# Check events
kubectl describe pod pod-name

# Common causes:
# - Application error
# - Missing dependencies
# - Incorrect command/args
# - Resource limits too low
# - Failed liveness probe

# Fix: Update deployment
kubectl edit deployment deployment-name
```

#### ImagePullBackOff

```bash
# Check image name
kubectl describe pod pod-name | grep Image

# Verify image exists
docker pull image-name

# Check image pull secrets
kubectl get secrets
kubectl describe pod pod-name | grep -A 3 "Image Pull Secrets"

# Create image pull secret
kubectl create secret docker-registry regcred \
  --docker-server=registry.example.com \
  --docker-username=user \
  --docker-password=pass

# Add to deployment
spec:
  imagePullSecrets:
  - name: regcred
```

#### Pending Pods

```bash
# Check why pending
kubectl describe pod pod-name

# Common causes:
# - Insufficient resources
# - Node selector mismatch
# - Taints/tolerations
# - PVC not bound

# Check node resources
kubectl top nodes
kubectl describe nodes

# Check PVC status
kubectl get pvc
```

#### Service Not Accessible

```bash
# Check service
kubectl get svc service-name
kubectl describe svc service-name

# Check endpoints
kubectl get endpoints service-name

# Verify pod labels match service selector
kubectl get pods --show-labels
kubectl get svc service-name -o yaml | grep selector

# Test from within cluster
kubectl run tmp --image=busybox --rm -it -- wget -O- http://service-name
```

#### DNS Resolution Issues

```bash
# Test DNS
kubectl run tmp --image=busybox --rm -it -- nslookup kubernetes.default

# Check CoreDNS
kubectl get pods -n kube-system -l k8s-app=kube-dns
kubectl logs -n kube-system -l k8s-app=kube-dns

# Restart CoreDNS
kubectl rollout restart deployment/coredns -n kube-system
```

#### Node NotReady

```bash
# Check node status
kubectl get nodes
kubectl describe node node-name

# Check node conditions
kubectl get node node-name -o jsonpath='{.status.conditions}'

# SSH to node (if possible)
# Check kubelet logs
journalctl -u kubelet -f

# Drain and delete node
kubectl drain node-name --ignore-daemonsets --delete-emptydir-data
kubectl delete node node-name
```

#### High Memory/CPU Usage

```bash
# Check resource usage
kubectl top nodes
kubectl top pods -A --sort-by=memory
kubectl top pods -A --sort-by=cpu

# Identify resource hogs
kubectl describe node node-name | grep -A 5 "Allocated resources"

# Check for resource limits
kubectl get pods -A -o json | jq '.items[] | select(.spec.containers[].resources.limits == null) | .metadata.name'

# Set resource limits
kubectl set resources deployment nginx --limits=cpu=500m,memory=512Mi --requests=cpu=250m,memory=256Mi
```

---

## 🙏 Closing Wisdom

*The path of Kubernetes mastery is endless. These commands are but stepping stones.*

### Essential Daily Commands

```bash
# The monk's morning ritual
kubectl get nodes
kubectl get pods -A
kubectl get events --sort-by='.lastTimestamp' | tail -20
kubectl top nodes
kubectl top pods -A

# The monk's deployment ritual
kubectl apply -f manifests/
kubectl rollout status deployment/my-app
kubectl get pods -l app=my-app
kubectl logs -l app=my-app --tail=50

# The monk's evening reflection
kubectl get all -A
kubectl get events --field-selector type=Warning
```

### Best Practices from the Monastery

1. **Use Namespaces**: Organize resources logically, separate environments
2. **Set Resource Limits**: Prevent resource starvation, enable proper scheduling
3. **Health Checks**: Always define liveness and readiness probes
4. **Labels & Selectors**: Use consistent labeling strategy for organization
5. **ConfigMaps & Secrets**: Never hardcode configuration in images
6. **Rolling Updates**: Use RollingUpdate strategy with proper maxSurge/maxUnavailable
7. **RBAC**: Apply principle of least privilege
8. **Network Policies**: Restrict pod-to-pod communication
9. **Pod Security**: Use Pod Security Standards/Admission
10. **Monitoring**: Deploy metrics-server, Prometheus, and logging solutions
11. **Backup**: Regularly backup etcd and persistent volumes
12. **Version Control**: Store all manifests in Git

### Quick Reference Card

| Command | What It Does |
|---------|-------------|
| `kubectl get pods` | List pods |
| `kubectl describe pod <name>` | Show pod details |
| `kubectl logs <pod>` | View pod logs |
| `kubectl exec -it <pod> -- sh` | Shell into pod |
| `kubectl apply -f <file>` | Apply manifest |
| `kubectl delete -f <file>` | Delete resources |
| `kubectl get svc` | List services |
| `kubectl get nodes` | List nodes |
| `kubectl top pods` | Pod resource usage |
| `kubectl rollout restart deployment/<name>` | Restart deployment |
| `kubectl scale deployment/<name> --replicas=3` | Scale deployment |
| `kubectl port-forward <pod> 8080:80` | Forward port |

### When in Doubt

```bash
# The universal answers
kubectl get all -A           # What's running?
kubectl get events --sort-by='.lastTimestamp' | tail -20  # What happened?
kubectl describe pod <name>  # Why is it failing?
kubectl logs <pod>           # What does it say?
kubectl explain <resource>   # How does it work?
```

---

*May your pods be running, your nodes be ready, and your deployments always successful.*

**— The Monk of Kubernetes**  
*Monastery of Container Orchestration*  
*Temple of kubectl*

🧘 **Namaste, `kubectl`**

---

## 📚 Additional Resources

- [Official Kubernetes Documentation](https://kubernetes.io/docs/)
- [kubectl Cheat Sheet (Official)](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Kubernetes The Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way)
- [AWS EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- [eksctl Documentation](https://eksctl.io/)
- [Kubernetes Patterns Book](https://www.oreilly.com/library/view/kubernetes-patterns/9781492050278/)
- [CNCF Landscape](https://landscape.cncf.io/)

---

*Last Updated: 2025-10-02*  
*Version: 1.0.0 - The First Enlightenment*  
*Kubernetes Version: 1.28+*  
*kubectl Version: 1.28+*
