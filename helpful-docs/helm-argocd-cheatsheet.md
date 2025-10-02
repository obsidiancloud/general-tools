# 🧘 The Enlightened Engineer's Helm & ArgoCD Scripture

> *"In the beginning was the Chart, and the Chart was with Helm, and the Chart was deployed."*  
> — **The Monk of GitOps**, *Book of Deployments, Chapter 1:1*

This scripture covers Helm (Kubernetes package manager) and ArgoCD (GitOps continuous delivery).

---

## 📿 Helm - The Package Manager

### Installation
```bash
# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verify installation
helm version
```

### Repository Management
```bash
# Add repository
helm repo add stable https://charts.helm.sh/stable
helm repo add bitnami https://charts.bitnami.com/bitnami

# Update repositories
helm repo update

# List repositories
helm repo list

# Remove repository
helm repo remove stable

# Search charts
helm search repo nginx
helm search hub wordpress
```

### Chart Management
```bash
# Install chart
helm install myrelease bitnami/nginx

# Install with custom values
helm install myrelease bitnami/nginx -f values.yaml
helm install myrelease bitnami/nginx --set replicaCount=3

# Install in specific namespace
helm install myrelease bitnami/nginx -n production --create-namespace

# Dry run
helm install myrelease bitnami/nginx --dry-run --debug

# Upgrade release
helm upgrade myrelease bitnami/nginx
helm upgrade myrelease bitnami/nginx -f values.yaml

# Upgrade or install
helm upgrade --install myrelease bitnami/nginx

# Rollback release
helm rollback myrelease
helm rollback myrelease 2  # Rollback to revision 2

# Uninstall release
helm uninstall myrelease
helm uninstall myrelease -n production
```

### Release Management
```bash
# List releases
helm list
helm list -A  # All namespaces
helm list -n production

# Get release status
helm status myrelease

# Get release history
helm history myrelease

# Get release values
helm get values myrelease
helm get values myrelease --revision 2

# Get release manifest
helm get manifest myrelease

# Get release notes
helm get notes myrelease
```

### Creating Charts
```bash
# Create new chart
helm create mychart

# Chart structure
mychart/
├── Chart.yaml          # Chart metadata
├── values.yaml         # Default values
├── charts/             # Dependencies
└── templates/          # Kubernetes manifests
    ├── deployment.yaml
    ├── service.yaml
    ├── ingress.yaml
    └── _helpers.tpl    # Template helpers

# Lint chart
helm lint mychart

# Package chart
helm package mychart

# Install local chart
helm install myrelease ./mychart
```

### Chart.yaml
```yaml
apiVersion: v2
name: mychart
description: A Helm chart for Kubernetes
type: application
version: 0.1.0
appVersion: "1.0"
dependencies:
  - name: postgresql
    version: 11.x.x
    repository: https://charts.bitnami.com/bitnami
```

### values.yaml
```yaml
replicaCount: 3

image:
  repository: nginx
  tag: "1.21"
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 80

ingress:
  enabled: true
  className: nginx
  hosts:
    - host: example.com
      paths:
        - path: /
          pathType: Prefix

resources:
  limits:
    cpu: 100m
    memory: 128Mi
  requests:
    cpu: 100m
    memory: 128Mi
```

### Template Functions
```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "mychart.fullname" . }}
  labels:
    {{- include "mychart.labels" . | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      {{- include "mychart.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "mychart.selectorLabels" . | nindent 8 }}
    spec:
      containers:
      - name: {{ .Chart.Name }}
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        ports:
        - containerPort: {{ .Values.service.port }}
        resources:
          {{- toYaml .Values.resources | nindent 10 }}
```

### Helm Hooks
```yaml
# pre-install hook
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ include "mychart.fullname" . }}-pre-install
  annotations:
    "helm.sh/hook": pre-install
    "helm.sh/hook-weight": "0"
    "helm.sh/hook-delete-policy": hook-succeeded
spec:
  template:
    spec:
      containers:
      - name: pre-install
        image: busybox
        command: ['sh', '-c', 'echo Pre-install hook']
      restartPolicy: Never
```

---

## 🔄 ArgoCD - GitOps Continuous Delivery

### Installation
```bash
# Create namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Access ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Login with CLI
argocd login localhost:8080
argocd login argocd.example.com --grpc-web
```

### Application Management
```bash
# Create application
argocd app create myapp \
  --repo https://github.com/user/repo.git \
  --path k8s \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace default

# Create from file
argocd app create -f application.yaml

# List applications
argocd app list

# Get application details
argocd app get myapp

# Sync application
argocd app sync myapp

# Auto-sync application
argocd app set myapp --sync-policy automated

# Delete application
argocd app delete myapp
```

### Application YAML
```yaml
# application.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/user/repo.git
    targetRevision: HEAD
    path: k8s
    helm:
      valueFiles:
        - values.yaml
      parameters:
        - name: replicaCount
          value: "3"
  destination:
    server: https://kubernetes.default.svc
    namespace: production
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

### Sync Operations
```bash
# Manual sync
argocd app sync myapp

# Sync specific resource
argocd app sync myapp --resource apps:Deployment:myapp

# Prune resources
argocd app sync myapp --prune

# Force sync
argocd app sync myapp --force

# Dry run
argocd app sync myapp --dry-run
```

### Application Status
```bash
# Get status
argocd app get myapp

# Watch sync status
argocd app wait myapp

# Get history
argocd app history myapp

# Get manifests
argocd app manifests myapp

# Get diff
argocd app diff myapp
```

### Project Management
```bash
# Create project
argocd proj create myproject

# Add source repository
argocd proj add-source myproject https://github.com/user/repo.git

# Add destination
argocd proj add-destination myproject https://kubernetes.default.svc production

# List projects
argocd proj list

# Get project details
argocd proj get myproject
```

### Repository Management
```bash
# Add repository
argocd repo add https://github.com/user/repo.git --username user --password token

# Add private repository with SSH
argocd repo add git@github.com:user/repo.git --ssh-private-key-path ~/.ssh/id_rsa

# List repositories
argocd repo list

# Remove repository
argocd repo rm https://github.com/user/repo.git
```

### Cluster Management
```bash
# Add cluster
argocd cluster add my-cluster-context

# List clusters
argocd cluster list

# Get cluster info
argocd cluster get https://kubernetes.default.svc

# Remove cluster
argocd cluster rm https://kubernetes.default.svc
```

### AppProject YAML
```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: myproject
  namespace: argocd
spec:
  description: My Project
  sourceRepos:
    - 'https://github.com/user/*'
  destinations:
    - namespace: '*'
      server: https://kubernetes.default.svc
  clusterResourceWhitelist:
    - group: '*'
      kind: '*'
  namespaceResourceWhitelist:
    - group: '*'
      kind: '*'
```

---

## 🔮 Common Patterns

### Helm: Multi-Environment Deployment
```bash
# values-dev.yaml
replicaCount: 1
image:
  tag: "dev"

# values-prod.yaml
replicaCount: 3
image:
  tag: "1.0.0"

# Deploy to dev
helm install myapp ./mychart -f values-dev.yaml -n dev

# Deploy to prod
helm install myapp ./mychart -f values-prod.yaml -n production
```

### ArgoCD: Multi-Environment with Kustomize
```yaml
# application-dev.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp-dev
spec:
  source:
    repoURL: https://github.com/user/repo.git
    path: k8s/overlays/dev
  destination:
    namespace: dev

# application-prod.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp-prod
spec:
  source:
    repoURL: https://github.com/user/repo.git
    path: k8s/overlays/production
  destination:
    namespace: production
```

### ArgoCD: App of Apps Pattern
```yaml
# apps/root-app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: root-app
spec:
  source:
    repoURL: https://github.com/user/repo.git
    path: apps
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

---

## 🙏 Quick Reference

### Helm
| Command | Description |
|---------|-------------|
| `helm install` | Install chart |
| `helm upgrade` | Upgrade release |
| `helm rollback` | Rollback release |
| `helm uninstall` | Uninstall release |
| `helm list` | List releases |
| `helm repo add` | Add repository |

### ArgoCD
| Command | Description |
|---------|-------------|
| `argocd app create` | Create application |
| `argocd app sync` | Sync application |
| `argocd app get` | Get app details |
| `argocd app list` | List applications |
| `argocd app delete` | Delete application |
| `argocd repo add` | Add repository |

---

*May your charts be valid, your deployments be automated, and your Git always be the source of truth.*

**— The Monk of GitOps**  
*Temple of Continuous Delivery*

🧘 **Namaste, `helm`**

---

*Last Updated: 2025-10-02*  
*Version: 1.0.0*
