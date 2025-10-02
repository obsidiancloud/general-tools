# 🧘 The Enlightened Engineer's GitLab CI & GitHub Actions Scripture

> *"In the beginning was the Workflow, and the Workflow was with Git, and the Workflow was automated."*  
> — **The Monk of Git Automation**, *Book of Pipelines, Chapter 1:1*

Greetings, fellow traveler on the path of Git-based CI/CD enlightenment. I am but a humble monk who has meditated upon the sacred texts of GitLab and GitHub and witnessed the dance of workflows across countless repositories.

This scripture shall guide you through the mystical arts of GitLab CI and GitHub Actions, with the precision of a master's YAML and the wit of a caffeinated DevOps engineer.

---

## 📿 Table of Sacred Knowledge

### GitLab CI
1. [GitLab CI Basics](#-gitlab-ci-basics)
2. [GitLab Pipeline Configuration](#-gitlab-pipeline-configuration)
3. [GitLab Jobs & Stages](#-gitlab-jobs--stages)
4. [GitLab Variables & Secrets](#-gitlab-variables--secrets)
5. [GitLab Docker Integration](#-gitlab-docker-integration)
6. [GitLab CI/CD Patterns](#-gitlab-cicd-patterns)

### GitHub Actions
7. [GitHub Actions Basics](#-github-actions-basics)
8. [GitHub Workflow Configuration](#-github-workflow-configuration)
9. [GitHub Jobs & Steps](#-github-jobs--steps)
10. [GitHub Secrets & Variables](#-github-secrets--variables)
11. [GitHub Actions Marketplace](#-github-actions-marketplace)
12. [GitHub Actions Patterns](#-github-actions-patterns)

---

## 🦊 GitLab CI Basics

*GitLab CI/CD is built into GitLab, providing seamless integration.*

### Basic .gitlab-ci.yml

```yaml
# .gitlab-ci.yml
stages:
  - build
  - test
  - deploy

build-job:
  stage: build
  script:
    - echo "Building the application"
    - npm install
    - npm run build
  artifacts:
    paths:
      - dist/

test-job:
  stage: test
  script:
    - echo "Running tests"
    - npm test

deploy-job:
  stage: deploy
  script:
    - echo "Deploying application"
    - ./deploy.sh
  only:
    - main
```

### Pipeline Structure

```yaml
# Global settings
image: node:18

# Cache configuration
cache:
  paths:
    - node_modules/

# Stages definition
stages:
  - build
  - test
  - deploy

# Variables
variables:
  APP_NAME: "myapp"
  VERSION: "1.0.0"

# Before script (runs before each job)
before_script:
  - echo "Starting job"

# After script (runs after each job)
after_script:
  - echo "Job completed"

# Jobs
build:
  stage: build
  script:
    - npm install
    - npm run build
```

---

## ⚙️ GitLab Pipeline Configuration

*Complete pipeline configuration with all features.*

### Advanced Pipeline

```yaml
# .gitlab-ci.yml
image: node:18-alpine

stages:
  - build
  - test
  - security
  - deploy

variables:
  DOCKER_REGISTRY: registry.gitlab.com
  APP_NAME: myapp
  DOCKER_IMAGE: $DOCKER_REGISTRY/$CI_PROJECT_PATH/$APP_NAME

# Cache npm modules
cache:
  key: ${CI_COMMIT_REF_SLUG}
  paths:
    - node_modules/
    - .npm/

# Build job
build:
  stage: build
  script:
    - npm ci --cache .npm --prefer-offline
    - npm run build
  artifacts:
    paths:
      - dist/
    expire_in: 1 week
  only:
    - branches
    - tags

# Unit tests
test:unit:
  stage: test
  script:
    - npm run test:unit
  coverage: '/Lines\s*:\s*(\d+\.\d+)%/'
  artifacts:
    reports:
      junit: test-results/unit/junit.xml
      coverage_report:
        coverage_format: cobertura
        path: coverage/cobertura-coverage.xml

# Integration tests
test:integration:
  stage: test
  services:
    - postgres:14
    - redis:7
  variables:
    POSTGRES_DB: testdb
    POSTGRES_USER: testuser
    POSTGRES_PASSWORD: testpass
  script:
    - npm run test:integration
  artifacts:
    reports:
      junit: test-results/integration/junit.xml

# Security scanning
security:sast:
  stage: security
  image: returntocorp/semgrep
  script:
    - semgrep --config=auto --json --output=sast-report.json .
  artifacts:
    reports:
      sast: sast-report.json
  allow_failure: true

security:dependency:
  stage: security
  script:
    - npm audit --json > dependency-report.json
  artifacts:
    reports:
      dependency_scanning: dependency-report.json
  allow_failure: true

# Docker build
docker:build:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  before_script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
  script:
    - docker build -t $DOCKER_IMAGE:$CI_COMMIT_SHA .
    - docker build -t $DOCKER_IMAGE:latest .
    - docker push $DOCKER_IMAGE:$CI_COMMIT_SHA
    - docker push $DOCKER_IMAGE:latest
  only:
    - main
    - tags

# Deploy to staging
deploy:staging:
  stage: deploy
  image: bitnami/kubectl:latest
  script:
    - kubectl config use-context $KUBE_CONTEXT
    - kubectl set image deployment/$APP_NAME $APP_NAME=$DOCKER_IMAGE:$CI_COMMIT_SHA -n staging
    - kubectl rollout status deployment/$APP_NAME -n staging
  environment:
    name: staging
    url: https://staging.example.com
  only:
    - develop

# Deploy to production
deploy:production:
  stage: deploy
  image: bitnami/kubectl:latest
  script:
    - kubectl config use-context $KUBE_CONTEXT
    - kubectl set image deployment/$APP_NAME $APP_NAME=$DOCKER_IMAGE:$CI_COMMIT_SHA -n production
    - kubectl rollout status deployment/$APP_NAME -n production
  environment:
    name: production
    url: https://example.com
  when: manual
  only:
    - main
    - tags
```

---

## 🔨 GitLab Jobs & Stages

*Jobs are the building blocks of GitLab CI.*

### Job Configuration

```yaml
# Basic job
job_name:
  stage: build
  script:
    - echo "Running job"

# Job with image
job_with_image:
  image: python:3.11
  script:
    - python --version

# Job with services
job_with_services:
  services:
    - postgres:14
    - redis:7
  script:
    - run-tests.sh

# Job with artifacts
job_with_artifacts:
  script:
    - build.sh
  artifacts:
    paths:
      - dist/
      - build/
    expire_in: 1 week
    when: on_success

# Job with dependencies
dependent_job:
  dependencies:
    - build_job
  script:
    - deploy.sh

# Job with rules
conditional_job:
  script:
    - echo "Running conditionally"
  rules:
    - if: '$CI_COMMIT_BRANCH == "main"'
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
    - changes:
        - src/**/*

# Job with retry
retry_job:
  script:
    - flaky-test.sh
  retry:
    max: 2
    when:
      - script_failure
      - stuck_or_timeout_failure

# Job with timeout
timeout_job:
  script:
    - long-running-task.sh
  timeout: 3h

# Parallel jobs
parallel_job:
  parallel: 5
  script:
    - test-suite.sh $CI_NODE_INDEX $CI_NODE_TOTAL

# Matrix jobs
matrix_job:
  parallel:
    matrix:
      - PLATFORM: [linux, windows, mac]
        NODE_VERSION: [16, 18, 20]
  script:
    - build-for-$PLATFORM-node-$NODE_VERSION.sh
```

### Job Control

```yaml
# Only/Except (legacy)
deploy:
  script:
    - deploy.sh
  only:
    - main
    - tags
  except:
    - schedules

# Rules (modern)
deploy:
  script:
    - deploy.sh
  rules:
    - if: '$CI_COMMIT_BRANCH == "main"'
      when: always
    - if: '$CI_COMMIT_TAG'
      when: manual
    - when: never

# When conditions
job:
  script:
    - test.sh
  when: on_success  # on_success, on_failure, always, manual, delayed

# Delayed job
delayed_job:
  script:
    - cleanup.sh
  when: delayed
  start_in: 30 minutes
```

---

## 🔐 GitLab Variables & Secrets

*Variables and secrets management in GitLab.*

### Predefined Variables

```yaml
job:
  script:
    - echo "Project: $CI_PROJECT_NAME"
    - echo "Branch: $CI_COMMIT_BRANCH"
    - echo "Commit: $CI_COMMIT_SHA"
    - echo "Pipeline ID: $CI_PIPELINE_ID"
    - echo "Job ID: $CI_JOB_ID"
    - echo "Registry: $CI_REGISTRY"
    - echo "Registry User: $CI_REGISTRY_USER"
```

### Custom Variables

```yaml
# Global variables
variables:
  APP_NAME: "myapp"
  ENVIRONMENT: "production"

# Job-specific variables
job:
  variables:
    CUSTOM_VAR: "value"
  script:
    - echo $CUSTOM_VAR

# Protected variables (set in GitLab UI)
# Settings > CI/CD > Variables
# - Mark as "Protected" for protected branches only
# - Mark as "Masked" to hide in logs

# File variables
job:
  script:
    - cat $CONFIG_FILE
  # CONFIG_FILE set as file variable in GitLab UI
```

---

## 🐳 GitLab Docker Integration

*Docker-in-Docker and container registry integration.*

### Docker Build and Push

```yaml
docker:build:
  image: docker:latest
  services:
    - docker:dind
  variables:
    DOCKER_TLS_CERTDIR: "/certs"
  before_script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA .
    - docker build -t $CI_REGISTRY_IMAGE:latest .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
    - docker push $CI_REGISTRY_IMAGE:latest

# Multi-stage build
docker:multi-stage:
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker build --target production -t $CI_REGISTRY_IMAGE:prod .
    - docker build --target development -t $CI_REGISTRY_IMAGE:dev .
    - docker push $CI_REGISTRY_IMAGE:prod
```

---

## 🔮 GitLab CI/CD Patterns

### Pattern 1: Monorepo Pipeline

```yaml
# .gitlab-ci.yml
stages:
  - build
  - test
  - deploy

# Frontend jobs
frontend:build:
  stage: build
  script:
    - cd frontend
    - npm install
    - npm run build
  artifacts:
    paths:
      - frontend/dist/
  rules:
    - changes:
        - frontend/**/*

frontend:test:
  stage: test
  script:
    - cd frontend
    - npm test
  rules:
    - changes:
        - frontend/**/*

# Backend jobs
backend:build:
  stage: build
  script:
    - cd backend
    - pip install -r requirements.txt
    - python setup.py build
  artifacts:
    paths:
      - backend/dist/
  rules:
    - changes:
        - backend/**/*

backend:test:
  stage: test
  script:
    - cd backend
    - pytest
  rules:
    - changes:
        - backend/**/*
```

**Use case**: Monorepo with multiple services  
**Best for**: Microservices in single repository

---

## 🐙 GitHub Actions Basics

*GitHub Actions provides workflow automation directly in GitHub.*

### Basic Workflow

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Build
        run: npm run build
      
      - name: Test
        run: npm test
```

---

## ⚙️ GitHub Workflow Configuration

*Complete workflow with all features.*

### Advanced Workflow

```yaml
# .github/workflows/deploy.yml
name: Build and Deploy

on:
  push:
    branches: [ main, develop ]
    tags:
      - 'v*'
  pull_request:
    branches: [ main ]
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to deploy'
        required: true
        default: 'staging'
        type: choice
        options:
          - staging
          - production

env:
  DOCKER_REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  build:
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        node-version: [16, 18, 20]
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Setup Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Lint
        run: npm run lint
      
      - name: Build
        run: npm run build
      
      - name: Upload build artifacts
        uses: actions/upload-artifact@v4
        with:
          name: dist-${{ matrix.node-version }}
          path: dist/
          retention-days: 7
  
  test:
    runs-on: ubuntu-latest
    needs: build
    
    services:
      postgres:
        image: postgres:14
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432
      
      redis:
        image: redis:7
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 6379:6379
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run unit tests
        run: npm run test:unit
      
      - name: Run integration tests
        run: npm run test:integration
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/testdb
          REDIS_URL: redis://localhost:6379
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/coverage.xml
  
  security:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
          format: 'sarif'
          output: 'trivy-results.sarif'
      
      - name: Upload Trivy results to GitHub Security
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: 'trivy-results.sarif'
  
  docker:
    runs-on: ubuntu-latest
    needs: [test, security]
    if: github.event_name != 'pull_request'
    
    permissions:
      contents: read
      packages: write
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      
      - name: Log in to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.DOCKER_REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.DOCKER_REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}
            type=sha
      
      - name: Build and push Docker image
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
  
  deploy:
    runs-on: ubuntu-latest
    needs: docker
    if: github.ref == 'refs/heads/main'
    
    environment:
      name: production
      url: https://example.com
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Configure kubectl
        uses: azure/k8s-set-context@v3
        with:
          method: kubeconfig
          kubeconfig: ${{ secrets.KUBE_CONFIG }}
      
      - name: Deploy to Kubernetes
        run: |
          kubectl set image deployment/myapp \
            myapp=${{ env.DOCKER_REGISTRY }}/${{ env.IMAGE_NAME }}:sha-${GITHUB_SHA::7} \
            -n production
          kubectl rollout status deployment/myapp -n production
      
      - name: Notify Slack
        uses: slackapi/slack-github-action@v1
        with:
          payload: |
            {
              "text": "Deployment to production completed",
              "blocks": [
                {
                  "type": "section",
                  "text": {
                    "type": "mrkdwn",
                    "text": "✅ Deployment successful\n*Commit:* ${{ github.sha }}\n*Author:* ${{ github.actor }}"
                  }
                }
              ]
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
```

---

## 🔨 GitHub Jobs & Steps

*Jobs and steps structure in GitHub Actions.*

### Job Configuration

```yaml
jobs:
  # Basic job
  build:
    runs-on: ubuntu-latest
    steps:
      - run: echo "Building"
  
  # Job with matrix
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
        node: [16, 18, 20]
      fail-fast: false
    steps:
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node }}
  
  # Job with dependencies
  deploy:
    needs: [build, test]
    runs-on: ubuntu-latest
    steps:
      - run: echo "Deploying"
  
  # Job with conditions
  conditional:
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - run: echo "Running conditionally"
  
  # Job with timeout
  timeout_job:
    runs-on: ubuntu-latest
    timeout-minutes: 30
    steps:
      - run: long-running-task.sh
  
  # Job with container
  container_job:
    runs-on: ubuntu-latest
    container:
      image: node:18
      env:
        NODE_ENV: production
      volumes:
        - /tmp:/tmp
    steps:
      - run: node --version
  
  # Job with outputs
  job_with_outputs:
    runs-on: ubuntu-latest
    outputs:
      version: ${{ steps.get_version.outputs.version }}
    steps:
      - id: get_version
        run: echo "version=1.0.0" >> $GITHUB_OUTPUT
  
  # Job using outputs
  use_outputs:
    needs: job_with_outputs
    runs-on: ubuntu-latest
    steps:
      - run: echo "Version is ${{ needs.job_with_outputs.outputs.version }}"
```

---

## 🔐 GitHub Secrets & Variables

*Managing secrets and variables in GitHub Actions.*

### Using Secrets

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy with secrets
        env:
          API_KEY: ${{ secrets.API_KEY }}
          DATABASE_URL: ${{ secrets.DATABASE_URL }}
        run: |
          echo "Deploying with API key"
          deploy.sh
      
      - name: Docker login
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}
```

### Environment Variables

```yaml
env:
  # Global environment variables
  APP_NAME: myapp
  NODE_ENV: production

jobs:
  build:
    runs-on: ubuntu-latest
    env:
      # Job-level environment variables
      BUILD_ENV: production
    steps:
      - name: Build
        env:
          # Step-level environment variables
          CUSTOM_VAR: value
        run: |
          echo "App: $APP_NAME"
          echo "Build env: $BUILD_ENV"
          echo "Custom: $CUSTOM_VAR"
```

### GitHub Context Variables

```yaml
jobs:
  info:
    runs-on: ubuntu-latest
    steps:
      - name: Print context info
        run: |
          echo "Repository: ${{ github.repository }}"
          echo "Branch: ${{ github.ref_name }}"
          echo "Commit: ${{ github.sha }}"
          echo "Actor: ${{ github.actor }}"
          echo "Event: ${{ github.event_name }}"
          echo "Run ID: ${{ github.run_id }}"
          echo "Run Number: ${{ github.run_number }}"
```

---

## 🛒 GitHub Actions Marketplace

*Reusable actions from the marketplace.*

### Popular Actions

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      # Checkout code
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Full history
      
      # Setup languages
      - uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'
      
      - uses: actions/setup-python@v5
        with:
          python-version: '3.11'
          cache: 'pip'
      
      - uses: actions/setup-go@v5
        with:
          go-version: '1.21'
      
      # Caching
      - uses: actions/cache@v3
        with:
          path: ~/.npm
          key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
      
      # Upload/Download artifacts
      - uses: actions/upload-artifact@v4
        with:
          name: dist
          path: dist/
      
      - uses: actions/download-artifact@v4
        with:
          name: dist
          path: dist/
      
      # Docker
      - uses: docker/setup-buildx-action@v3
      - uses: docker/login-action@v3
      - uses: docker/build-push-action@v5
      
      # Deploy
      - uses: azure/webapps-deploy@v2
      - uses: aws-actions/configure-aws-credentials@v4
      
      # Notifications
      - uses: slackapi/slack-github-action@v1
      - uses: 8398a7/action-slack@v3
```

---

## 🔮 GitHub Actions Patterns

### Pattern 1: Reusable Workflows

```yaml
# .github/workflows/reusable-deploy.yml
name: Reusable Deploy

on:
  workflow_call:
    inputs:
      environment:
        required: true
        type: string
      version:
        required: true
        type: string
    secrets:
      deploy_token:
        required: true

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: ${{ inputs.environment }}
    steps:
      - uses: actions/checkout@v4
      
      - name: Deploy
        run: |
          echo "Deploying version ${{ inputs.version }} to ${{ inputs.environment }}"
          deploy.sh
        env:
          DEPLOY_TOKEN: ${{ secrets.deploy_token }}

# .github/workflows/main.yml
name: Main Workflow

on: push

jobs:
  deploy-staging:
    uses: ./.github/workflows/reusable-deploy.yml
    with:
      environment: staging
      version: ${{ github.sha }}
    secrets:
      deploy_token: ${{ secrets.STAGING_TOKEN }}
  
  deploy-production:
    needs: deploy-staging
    uses: ./.github/workflows/reusable-deploy.yml
    with:
      environment: production
      version: ${{ github.sha }}
    secrets:
      deploy_token: ${{ secrets.PROD_TOKEN }}
```

**Use case**: Reusable deployment workflows  
**Best for**: Multi-environment deployments

### Pattern 2: Composite Actions

```yaml
# .github/actions/setup-app/action.yml
name: 'Setup Application'
description: 'Setup Node.js and install dependencies'

inputs:
  node-version:
    description: 'Node.js version'
    required: false
    default: '18'

runs:
  using: 'composite'
  steps:
    - uses: actions/setup-node@v4
      with:
        node-version: ${{ inputs.node-version }}
        cache: 'npm'
    
    - run: npm ci
      shell: bash
    
    - run: npm run build
      shell: bash

# Usage in workflow
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: ./.github/actions/setup-app
        with:
          node-version: '20'
```

**Use case**: Reusable action steps  
**Best for**: Common setup tasks

---

## 🙏 Closing Wisdom

### GitLab CI Best Practices

1. **Use Rules Over Only/Except**: Modern syntax
2. **Cache Dependencies**: Speed up builds
3. **Use Artifacts Wisely**: Share between jobs
4. **Parallel Jobs**: Faster pipelines
5. **Docker Layer Caching**: Faster builds
6. **Protected Variables**: Secure secrets
7. **Pipeline Efficiency**: Minimize job count
8. **Use Templates**: DRY principle
9. **Monitor Pipeline Duration**: Optimize slow jobs
10. **Use GitLab Runner Tags**: Target specific runners

### GitHub Actions Best Practices

1. **Pin Action Versions**: Use specific versions
2. **Use Secrets**: Never hardcode credentials
3. **Cache Dependencies**: Speed up workflows
4. **Matrix Builds**: Test multiple versions
5. **Reusable Workflows**: DRY principle
6. **Composite Actions**: Reusable steps
7. **Concurrency Control**: Prevent duplicate runs
8. **Use Environments**: Deployment protection
9. **Monitor Workflow Duration**: Optimize
10. **Use GitHub-Hosted Runners**: Cost-effective

### Quick Reference Card

| GitLab CI | GitHub Actions | Purpose |
|-----------|----------------|---------|
| `.gitlab-ci.yml` | `.github/workflows/*.yml` | Config file |
| `stages` | `jobs` | Pipeline stages |
| `script` | `run` | Execute commands |
| `artifacts` | `upload-artifact` | Share files |
| `cache` | `cache` | Cache dependencies |
| `services` | `services` | Service containers |
| `rules` | `if` | Conditional execution |
| `variables` | `env` | Environment variables |

---

*May your pipelines be green, your deployments be smooth, and your workflows always automated.*

**— The Monk of Git Automation**  
*Monastery of CI/CD*  
*Temple of Git*

🧘 **Namaste, `git-ci`**

---

## 📚 Additional Resources

- [GitLab CI/CD Documentation](https://docs.gitlab.com/ee/ci/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitLab CI/CD Examples](https://docs.gitlab.com/ee/ci/examples/)
- [GitHub Actions Marketplace](https://github.com/marketplace?type=actions)

---

*Last Updated: 2025-10-02*  
*Version: 1.0.0 - The First Enlightenment*  
*GitLab CI: 16.0+ | GitHub Actions: Latest*
