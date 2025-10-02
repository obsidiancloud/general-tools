# 🧘 The Enlightened Engineer's Jenkins Scripture

> *"In the beginning was the Pipeline, and the Pipeline was with Jenkins, and the Pipeline was automated."*  
> — **The Monk of CI/CD**, *Book of Automation, Chapter 1:1*

Greetings, fellow traveler on the path of continuous integration enlightenment. I am but a humble monk who has meditated upon the sacred texts of Kohsuke and witnessed the dance of builds across countless pipelines.

This scripture shall guide you through the mystical arts of Jenkins, with the precision of a master's Jenkinsfile and the wit of a caffeinated DevOps engineer.

---

## 📿 Table of Sacred Knowledge

1. [Jenkins Installation & Setup](#-jenkins-installation--setup)
2. [Pipeline Basics](#-pipeline-basics-the-foundation)
3. [Declarative Pipeline](#-declarative-pipeline-the-structured-path)
4. [Scripted Pipeline](#-scripted-pipeline-the-flexible-path)
5. [Pipeline Syntax](#-pipeline-syntax-the-language)
6. [Credentials Management](#-credentials-management-the-secrets)
7. [Shared Libraries](#-shared-libraries-the-reusable-wisdom)
8. [Multibranch Pipelines](#-multibranch-pipelines-the-branch-automation)
9. [Docker Integration](#-docker-integration-the-containerization)
10. [Kubernetes Integration](#-kubernetes-integration-the-orchestration)
11. [Common Patterns: The Sacred Workflows](#-common-patterns-the-sacred-workflows)
12. [Troubleshooting](#-troubleshooting-when-the-path-is-obscured)

---

## 🛠 Jenkins Installation & Setup

*Before automating builds, one must first install Jenkins.*

### Installation

```bash
# Ubuntu/Debian
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
sudo apt-get install jenkins

# RHEL/CentOS
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum install jenkins

# Docker
docker run -d -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  --name jenkins \
  jenkins/jenkins:lts

# Docker Compose
version: '3.8'
services:
  jenkins:
    image: jenkins/jenkins:lts
    ports:
      - "8080:8080"
      - "50000:50000"
    volumes:
      - jenkins_home:/var/jenkins_home
    environment:
      - JAVA_OPTS=-Djenkins.install.runSetupWizard=false

volumes:
  jenkins_home:

# Start Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Get initial admin password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

### Initial Configuration

```bash
# Access Jenkins
http://localhost:8080

# Install suggested plugins
# Create admin user
# Configure Jenkins URL

# Install additional plugins via CLI
java -jar jenkins-cli.jar -s http://localhost:8080/ install-plugin \
  pipeline-model-definition \
  docker-workflow \
  kubernetes \
  git \
  credentials-binding
```

---

## 📋 Pipeline Basics: The Foundation

*Pipelines define the automation workflow.*

### Simple Pipeline

```groovy
// Jenkinsfile
pipeline {
    agent any
    
    stages {
        stage('Build') {
            steps {
                echo 'Building...'
                sh 'make build'
            }
        }
        
        stage('Test') {
            steps {
                echo 'Testing...'
                sh 'make test'
            }
        }
        
        stage('Deploy') {
            steps {
                echo 'Deploying...'
                sh 'make deploy'
            }
        }
    }
}
```

### Pipeline Structure

```groovy
pipeline {
    // Where to run
    agent any
    
    // Environment variables
    environment {
        APP_NAME = 'myapp'
        VERSION = '1.0.0'
    }
    
    // Build parameters
    parameters {
        string(name: 'ENVIRONMENT', defaultValue: 'dev', description: 'Environment')
        choice(name: 'DEPLOY_TARGET', choices: ['dev', 'staging', 'prod'], description: 'Deploy target')
        booleanParam(name: 'RUN_TESTS', defaultValue: true, description: 'Run tests')
    }
    
    // Build triggers
    triggers {
        cron('H 2 * * *')  // Daily at 2 AM
        pollSCM('H/5 * * * *')  // Poll every 5 minutes
    }
    
    // Build options
    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timestamps()
        timeout(time: 1, unit: 'HOURS')
    }
    
    // Stages
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                sh 'make build'
            }
        }
    }
    
    // Post-build actions
    post {
        always {
            echo 'Pipeline finished'
        }
        success {
            echo 'Pipeline succeeded'
        }
        failure {
            echo 'Pipeline failed'
        }
    }
}
```

---

## 🏗️ Declarative Pipeline: The Structured Path

*Declarative pipelines provide a structured, opinionated syntax.*

### Complete Example

```groovy
pipeline {
    agent {
        label 'linux'
    }
    
    environment {
        DOCKER_REGISTRY = 'registry.example.com'
        APP_NAME = 'myapp'
        VERSION = "${env.BUILD_NUMBER}"
    }
    
    parameters {
        choice(name: 'ENVIRONMENT', choices: ['dev', 'staging', 'prod'], description: 'Deployment environment')
        booleanParam(name: 'SKIP_TESTS', defaultValue: false, description: 'Skip tests')
    }
    
    options {
        buildDiscarder(logRotator(numToKeepStr: '30'))
        timestamps()
        timeout(time: 1, unit: 'HOURS')
        disableConcurrentBuilds()
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                script {
                    echo "Building ${APP_NAME} version ${VERSION}"
                }
                sh '''
                    npm install
                    npm run build
                '''
            }
        }
        
        stage('Test') {
            when {
                expression { params.SKIP_TESTS == false }
            }
            steps {
                sh 'npm test'
            }
            post {
                always {
                    junit 'test-results/**/*.xml'
                }
            }
        }
        
        stage('Docker Build') {
            steps {
                script {
                    docker.build("${DOCKER_REGISTRY}/${APP_NAME}:${VERSION}")
                }
            }
        }
        
        stage('Docker Push') {
            steps {
                script {
                    docker.withRegistry("https://${DOCKER_REGISTRY}", 'docker-credentials') {
                        docker.image("${DOCKER_REGISTRY}/${APP_NAME}:${VERSION}").push()
                        docker.image("${DOCKER_REGISTRY}/${APP_NAME}:${VERSION}").push('latest')
                    }
                }
            }
        }
        
        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                script {
                    if (params.ENVIRONMENT == 'prod') {
                        input message: 'Deploy to production?', ok: 'Deploy'
                    }
                }
                sh """
                    kubectl set image deployment/${APP_NAME} \
                        ${APP_NAME}=${DOCKER_REGISTRY}/${APP_NAME}:${VERSION} \
                        -n ${params.ENVIRONMENT}
                """
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        success {
            slackSend(
                color: 'good',
                message: "Build ${env.BUILD_NUMBER} succeeded for ${APP_NAME}"
            )
        }
        failure {
            slackSend(
                color: 'danger',
                message: "Build ${env.BUILD_NUMBER} failed for ${APP_NAME}"
            )
        }
    }
}
```

### Agent Configuration

```groovy
// Any available agent
agent any

// Specific label
agent {
    label 'linux'
}

// Docker agent
agent {
    docker {
        image 'node:18'
        args '-v /tmp:/tmp'
    }
}

// Kubernetes agent
agent {
    kubernetes {
        yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: maven
    image: maven:3.8-jdk-11
    command: ['cat']
    tty: true
'''
    }
}

// None (stages define their own agents)
agent none

// Different agents per stage
pipeline {
    agent none
    stages {
        stage('Build') {
            agent { label 'linux' }
            steps {
                sh 'make build'
            }
        }
        stage('Test') {
            agent { docker 'node:18' }
            steps {
                sh 'npm test'
            }
        }
    }
}
```

### When Conditions

```groovy
stage('Deploy to Production') {
    when {
        // Branch condition
        branch 'main'
        
        // Environment condition
        environment name: 'DEPLOY', value: 'true'
        
        // Expression
        expression { params.ENVIRONMENT == 'prod' }
        
        // Tag
        tag 'release-*'
        
        // Change request
        changeRequest()
        
        // Multiple conditions (AND)
        allOf {
            branch 'main'
            environment name: 'DEPLOY', value: 'true'
        }
        
        // Multiple conditions (OR)
        anyOf {
            branch 'main'
            branch 'develop'
        }
        
        // NOT condition
        not {
            branch 'feature/*'
        }
    }
    steps {
        sh 'deploy.sh'
    }
}
```

---

## 🔧 Scripted Pipeline: The Flexible Path

*Scripted pipelines provide maximum flexibility with Groovy.*

### Basic Scripted Pipeline

```groovy
node {
    stage('Checkout') {
        checkout scm
    }
    
    stage('Build') {
        sh 'make build'
    }
    
    stage('Test') {
        sh 'make test'
    }
    
    stage('Deploy') {
        sh 'make deploy'
    }
}
```

### Advanced Scripted Pipeline

```groovy
node('linux') {
    def app
    def version = env.BUILD_NUMBER
    
    try {
        stage('Checkout') {
            checkout scm
            version = sh(returnStdout: true, script: 'git describe --tags').trim()
        }
        
        stage('Build') {
            sh """
                npm install
                npm run build
            """
        }
        
        stage('Test') {
            parallel(
                'Unit Tests': {
                    sh 'npm run test:unit'
                },
                'Integration Tests': {
                    sh 'npm run test:integration'
                },
                'Linting': {
                    sh 'npm run lint'
                }
            )
        }
        
        stage('Docker Build') {
            app = docker.build("myapp:${version}")
        }
        
        stage('Docker Push') {
            docker.withRegistry('https://registry.example.com', 'docker-credentials') {
                app.push(version)
                app.push('latest')
            }
        }
        
        stage('Deploy') {
            if (env.BRANCH_NAME == 'main') {
                input message: 'Deploy to production?', ok: 'Deploy'
                
                withCredentials([string(credentialsId: 'kube-token', variable: 'TOKEN')]) {
                    sh """
                        kubectl set image deployment/myapp \
                            myapp=registry.example.com/myapp:${version} \
                            --token=${TOKEN}
                    """
                }
            }
        }
        
        currentBuild.result = 'SUCCESS'
    } catch (Exception e) {
        currentBuild.result = 'FAILURE'
        throw e
    } finally {
        stage('Cleanup') {
            cleanWs()
        }
        
        stage('Notify') {
            if (currentBuild.result == 'SUCCESS') {
                slackSend color: 'good', message: "Build ${version} succeeded"
            } else {
                slackSend color: 'danger', message: "Build ${version} failed"
            }
        }
    }
}
```

---

## 📝 Pipeline Syntax: The Language

*Understanding pipeline syntax is essential.*

### Variables

```groovy
// Environment variables
environment {
    APP_NAME = 'myapp'
    VERSION = '1.0.0'
}

// Access environment variables
echo "Building ${env.APP_NAME}"
echo "Version: ${VERSION}"

// Script block variables
script {
    def version = sh(returnStdout: true, script: 'git describe --tags').trim()
    env.VERSION = version
}
```

### Parallel Execution

```groovy
stage('Parallel Tests') {
    parallel {
        stage('Unit Tests') {
            steps {
                sh 'npm run test:unit'
            }
        }
        stage('Integration Tests') {
            steps {
                sh 'npm run test:integration'
            }
        }
        stage('E2E Tests') {
            steps {
                sh 'npm run test:e2e'
            }
        }
    }
}

// Scripted pipeline parallel
parallel(
    'Unit': {
        sh 'npm run test:unit'
    },
    'Integration': {
        sh 'npm run test:integration'
    },
    'E2E': {
        sh 'npm run test:e2e'
    }
)
```

### Input Steps

```groovy
stage('Deploy to Production') {
    steps {
        // Simple input
        input message: 'Deploy to production?', ok: 'Deploy'
        
        // Input with parameters
        script {
            def userInput = input(
                message: 'Deploy configuration',
                parameters: [
                    choice(name: 'ENVIRONMENT', choices: ['staging', 'prod'], description: 'Environment'),
                    string(name: 'VERSION', defaultValue: '1.0.0', description: 'Version')
                ]
            )
            echo "Deploying ${userInput.VERSION} to ${userInput.ENVIRONMENT}"
        }
    }
}
```

### Retry and Timeout

```groovy
stage('Deploy') {
    steps {
        // Retry on failure
        retry(3) {
            sh 'deploy.sh'
        }
        
        // Timeout
        timeout(time: 5, unit: 'MINUTES') {
            sh 'long-running-task.sh'
        }
        
        // Combined
        timeout(time: 10, unit: 'MINUTES') {
            retry(3) {
                sh 'flaky-deploy.sh'
            }
        }
    }
}
```

---

## 🔐 Credentials Management: The Secrets

*Secure credential handling is critical.*

### Using Credentials

```groovy
pipeline {
    agent any
    
    stages {
        stage('Deploy') {
            steps {
                // Username/Password
                withCredentials([usernamePassword(
                    credentialsId: 'docker-hub',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker push myapp:latest
                    '''
                }
                
                // Secret text
                withCredentials([string(credentialsId: 'api-token', variable: 'API_TOKEN')]) {
                    sh 'curl -H "Authorization: Bearer $API_TOKEN" https://api.example.com'
                }
                
                // SSH key
                withCredentials([sshUserPrivateKey(
                    credentialsId: 'ssh-key',
                    keyFileVariable: 'SSH_KEY',
                    usernameVariable: 'SSH_USER'
                )]) {
                    sh 'ssh -i $SSH_KEY $SSH_USER@server.example.com "deploy.sh"'
                }
                
                // Certificate
                withCredentials([certificate(
                    credentialsId: 'cert',
                    keystoreVariable: 'KEYSTORE',
                    passwordVariable: 'KEYSTORE_PASS'
                )]) {
                    sh 'sign-app.sh --keystore $KEYSTORE --password $KEYSTORE_PASS'
                }
            }
        }
    }
}
```

### Multiple Credentials

```groovy
withCredentials([
    usernamePassword(credentialsId: 'docker-hub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS'),
    string(credentialsId: 'api-token', variable: 'API_TOKEN'),
    file(credentialsId: 'config-file', variable: 'CONFIG')
]) {
    sh '''
        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
        curl -H "Authorization: Bearer $API_TOKEN" https://api.example.com
        cp $CONFIG /app/config.yml
    '''
}
```

---

## 📚 Shared Libraries: The Reusable Wisdom

*Shared libraries enable code reuse across pipelines.*

### Creating Shared Library

```
my-shared-library/
├── vars/
│   ├── buildApp.groovy
│   ├── deployApp.groovy
│   └── notifySlack.groovy
└── src/
    └── com/
        └── example/
            └── Utils.groovy
```

```groovy
// vars/buildApp.groovy
def call(Map config) {
    pipeline {
        agent any
        stages {
            stage('Build') {
                steps {
                    sh "npm install"
                    sh "npm run build"
                }
            }
        }
    }
}

// vars/deployApp.groovy
def call(String environment, String version) {
    sh """
        kubectl set image deployment/myapp \
            myapp=registry.example.com/myapp:${version} \
            -n ${environment}
    """
}

// vars/notifySlack.groovy
def call(String message, String color = 'good') {
    slackSend(
        color: color,
        message: message
    )
}

// src/com/example/Utils.groovy
package com.example

class Utils {
    static String getVersion() {
        return new Date().format('yyyyMMdd-HHmmss')
    }
}
```

### Using Shared Library

```groovy
@Library('my-shared-library') _

pipeline {
    agent any
    
    stages {
        stage('Build') {
            steps {
                script {
                    buildApp()
                }
            }
        }
        
        stage('Deploy') {
            steps {
                script {
                    def version = com.example.Utils.getVersion()
                    deployApp('production', version)
                }
            }
        }
    }
    
    post {
        success {
            notifySlack("Build succeeded", "good")
        }
        failure {
            notifySlack("Build failed", "danger")
        }
    }
}
```

---

## 🌿 Multibranch Pipelines: The Branch Automation

*Multibranch pipelines automatically create jobs for branches.*

### Configuration

```groovy
// Jenkinsfile in repository
pipeline {
    agent any
    
    stages {
        stage('Build') {
            steps {
                echo "Building branch: ${env.BRANCH_NAME}"
                sh 'make build'
            }
        }
        
        stage('Test') {
            steps {
                sh 'make test'
            }
        }
        
        stage('Deploy to Dev') {
            when {
                branch 'develop'
            }
            steps {
                sh 'deploy.sh dev'
            }
        }
        
        stage('Deploy to Staging') {
            when {
                branch 'release/*'
            }
            steps {
                sh 'deploy.sh staging'
            }
        }
        
        stage('Deploy to Production') {
            when {
                branch 'main'
            }
            steps {
                input message: 'Deploy to production?'
                sh 'deploy.sh prod'
            }
        }
    }
}
```

### Branch-Specific Logic

```groovy
pipeline {
    agent any
    
    environment {
        DEPLOY_ENV = "${env.BRANCH_NAME == 'main' ? 'prod' : env.BRANCH_NAME == 'develop' ? 'dev' : 'staging'}"
    }
    
    stages {
        stage('Build') {
            steps {
                script {
                    if (env.BRANCH_NAME.startsWith('feature/')) {
                        echo "Building feature branch"
                    } else if (env.BRANCH_NAME.startsWith('hotfix/')) {
                        echo "Building hotfix branch"
                    }
                }
                sh 'make build'
            }
        }
        
        stage('Deploy') {
            steps {
                sh "deploy.sh ${DEPLOY_ENV}"
            }
        }
    }
}
```

---

## 🐳 Docker Integration: The Containerization

*Jenkins integrates seamlessly with Docker.*

### Docker Pipeline

```groovy
pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'registry.example.com'
        IMAGE_NAME = 'myapp'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
    }
    
    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}")
                }
            }
        }
        
        stage('Test in Container') {
            steps {
                script {
                    docker.image("${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}").inside {
                        sh 'npm test'
                    }
                }
            }
        }
        
        stage('Push to Registry') {
            steps {
                script {
                    docker.withRegistry("https://${DOCKER_REGISTRY}", 'docker-credentials') {
                        docker.image("${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}").push()
                        docker.image("${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}").push('latest')
                    }
                }
            }
        }
    }
    
    post {
        always {
            sh "docker rmi ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} || true"
        }
    }
}
```

### Docker Agent

```groovy
pipeline {
    agent {
        docker {
            image 'node:18'
            args '-v /tmp:/tmp'
        }
    }
    
    stages {
        stage('Build') {
            steps {
                sh 'npm install'
                sh 'npm run build'
            }
        }
    }
}

// Different Docker images per stage
pipeline {
    agent none
    
    stages {
        stage('Build') {
            agent {
                docker { image 'node:18' }
            }
            steps {
                sh 'npm run build'
            }
        }
        
        stage('Test') {
            agent {
                docker { image 'node:18' }
            }
            steps {
                sh 'npm test'
            }
        }
    }
}
```

---

## ☸️ Kubernetes Integration: The Orchestration

*Jenkins can run builds in Kubernetes pods.*

### Kubernetes Pod Template

```groovy
pipeline {
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
metadata:
  labels:
    jenkins: agent
spec:
  containers:
  - name: maven
    image: maven:3.8-jdk-11
    command:
    - cat
    tty: true
  - name: docker
    image: docker:latest
    command:
    - cat
    tty: true
    volumeMounts:
    - name: docker-sock
      mountPath: /var/run/docker.sock
  volumes:
  - name: docker-sock
    hostPath:
      path: /var/run/docker.sock
'''
        }
    }
    
    stages {
        stage('Build') {
            steps {
                container('maven') {
                    sh 'mvn clean package'
                }
            }
        }
        
        stage('Docker Build') {
            steps {
                container('docker') {
                    sh 'docker build -t myapp:${BUILD_NUMBER} .'
                }
            }
        }
    }
}
```

---

## 🔮 Common Patterns: The Sacred Workflows

*These are the rituals performed by monks in production temples daily.*

### Pattern 1: Complete CI/CD Pipeline

```groovy
@Library('shared-library') _

pipeline {
    agent any
    
    environment {
        APP_NAME = 'myapp'
        DOCKER_REGISTRY = 'registry.example.com'
        VERSION = "${env.BUILD_NUMBER}"
    }
    
    parameters {
        choice(name: 'ENVIRONMENT', choices: ['dev', 'staging', 'prod'], description: 'Deployment environment')
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    env.GIT_COMMIT_SHORT = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
                    env.VERSION = "${env.BUILD_NUMBER}-${env.GIT_COMMIT_SHORT}"
                }
            }
        }
        
        stage('Build') {
            steps {
                sh 'npm install'
                sh 'npm run build'
            }
        }
        
        stage('Test') {
            parallel {
                stage('Unit Tests') {
                    steps {
                        sh 'npm run test:unit'
                    }
                    post {
                        always {
                            junit 'test-results/unit/**/*.xml'
                        }
                    }
                }
                stage('Integration Tests') {
                    steps {
                        sh 'npm run test:integration'
                    }
                    post {
                        always {
                            junit 'test-results/integration/**/*.xml'
                        }
                    }
                }
                stage('Code Coverage') {
                    steps {
                        sh 'npm run coverage'
                    }
                    post {
                        always {
                            publishHTML([
                                reportDir: 'coverage',
                                reportFiles: 'index.html',
                                reportName: 'Coverage Report'
                            ])
                        }
                    }
                }
            }
        }
        
        stage('Security Scan') {
            steps {
                sh 'npm audit'
                sh 'trivy fs --severity HIGH,CRITICAL .'
            }
        }
        
        stage('Docker Build') {
            steps {
                script {
                    docker.build("${DOCKER_REGISTRY}/${APP_NAME}:${VERSION}")
                }
            }
        }
        
        stage('Docker Scan') {
            steps {
                sh "trivy image ${DOCKER_REGISTRY}/${APP_NAME}:${VERSION}"
            }
        }
        
        stage('Docker Push') {
            steps {
                script {
                    docker.withRegistry("https://${DOCKER_REGISTRY}", 'docker-credentials') {
                        docker.image("${DOCKER_REGISTRY}/${APP_NAME}:${VERSION}").push()
                        if (env.BRANCH_NAME == 'main') {
                            docker.image("${DOCKER_REGISTRY}/${APP_NAME}:${VERSION}").push('latest')
                        }
                    }
                }
            }
        }
        
        stage('Deploy') {
            when {
                anyOf {
                    branch 'main'
                    branch 'develop'
                }
            }
            steps {
                script {
                    if (params.ENVIRONMENT == 'prod') {
                        input message: 'Deploy to production?', ok: 'Deploy'
                    }
                    
                    withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                        sh """
                            kubectl set image deployment/${APP_NAME} \
                                ${APP_NAME}=${DOCKER_REGISTRY}/${APP_NAME}:${VERSION} \
                                -n ${params.ENVIRONMENT}
                            kubectl rollout status deployment/${APP_NAME} -n ${params.ENVIRONMENT}
                        """
                    }
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        success {
            slackSend(
                color: 'good',
                message: "✅ Build ${VERSION} succeeded\nBranch: ${env.BRANCH_NAME}\nEnvironment: ${params.ENVIRONMENT}"
            )
        }
        failure {
            slackSend(
                color: 'danger',
                message: "❌ Build ${VERSION} failed\nBranch: ${env.BRANCH_NAME}\nCheck: ${env.BUILD_URL}"
            )
        }
    }
}
```

**Use case**: Complete CI/CD workflow  
**Best for**: Production applications

### Pattern 2: Matrix Build

```groovy
pipeline {
    agent none
    
    stages {
        stage('Build Matrix') {
            matrix {
                agent any
                axes {
                    axis {
                        name 'PLATFORM'
                        values 'linux', 'windows', 'mac'
                    }
                    axis {
                        name 'NODE_VERSION'
                        values '16', '18', '20'
                    }
                }
                stages {
                    stage('Build') {
                        steps {
                            echo "Building on ${PLATFORM} with Node ${NODE_VERSION}"
                            sh "npm install"
                            sh "npm run build"
                        }
                    }
                    stage('Test') {
                        steps {
                            sh "npm test"
                        }
                    }
                }
            }
        }
    }
}
```

**Use case**: Multi-platform builds  
**Best for**: Cross-platform applications

### Pattern 3: Blue/Green Deployment

```groovy
pipeline {
    agent any
    
    environment {
        APP_NAME = 'myapp'
        VERSION = "${env.BUILD_NUMBER}"
    }
    
    stages {
        stage('Deploy to Green') {
            steps {
                sh """
                    kubectl set image deployment/${APP_NAME}-green \
                        ${APP_NAME}=${DOCKER_REGISTRY}/${APP_NAME}:${VERSION} \
                        -n production
                    kubectl rollout status deployment/${APP_NAME}-green -n production
                """
            }
        }
        
        stage('Health Check') {
            steps {
                script {
                    def healthCheck = sh(
                        returnStatus: true,
                        script: 'curl -f http://green.example.com/health'
                    )
                    if (healthCheck != 0) {
                        error("Health check failed")
                    }
                }
            }
        }
        
        stage('Switch Traffic') {
            steps {
                input message: 'Switch traffic to green?', ok: 'Switch'
                sh """
                    kubectl patch service ${APP_NAME} \
                        -p '{"spec":{"selector":{"version":"green"}}}' \
                        -n production
                """
            }
        }
    }
}
```

**Use case**: Zero-downtime deployment  
**Best for**: Production environments

---

## 🔧 Troubleshooting: When the Path is Obscured

### Common Issues

#### Pipeline Syntax Errors

```groovy
// Validate Jenkinsfile
// Use Jenkins Pipeline Syntax Generator
// http://localhost:8080/pipeline-syntax/

// Test pipeline locally
// Use Jenkins Linter
curl -X POST -F "jenkinsfile=<Jenkinsfile" http://localhost:8080/pipeline-model-converter/validate
```

#### Build Hanging

```groovy
// Add timeout
options {
    timeout(time: 1, unit: 'HOURS')
}

// Check for input steps blocking
// Review console output
// Check agent availability
```

#### Credential Issues

```bash
# Verify credentials exist
# Check credential ID matches
# Ensure proper permissions

# Test credential access
withCredentials([string(credentialsId: 'test', variable: 'TEST')]) {
    sh 'echo "Credential accessible"'
}
```

---

## 🙏 Closing Wisdom

### Best Practices from the Monastery

1. **Use Declarative Pipeline**: Easier to read and maintain
2. **Version Control Jenkinsfile**: Store in repository
3. **Use Shared Libraries**: Reuse common code
4. **Secure Credentials**: Use Jenkins credentials store
5. **Parallel Execution**: Speed up builds
6. **Proper Error Handling**: Use try-catch and post blocks
7. **Clean Workspace**: Always clean up
8. **Use Docker Agents**: Consistent build environments
9. **Implement Timeouts**: Prevent hanging builds
10. **Monitor Build Times**: Optimize slow stages
11. **Use Multibranch**: Automate branch builds
12. **Regular Backups**: Backup Jenkins configuration

### Quick Reference Card

| Directive | What It Does |
|-----------|-------------|
| `pipeline {}` | Define pipeline |
| `agent any` | Run on any agent |
| `stages {}` | Define stages |
| `steps {}` | Define steps |
| `post {}` | Post-build actions |
| `when {}` | Conditional execution |
| `parallel {}` | Parallel execution |
| `withCredentials` | Use credentials |
| `input` | Manual approval |
| `script {}` | Groovy script block |

---

*May your builds be green, your deployments be smooth, and your pipelines always automated.*

**— The Monk of CI/CD**  
*Monastery of Automation*  
*Temple of Jenkins*

🧘 **Namaste, `jenkins`**

---

## 📚 Additional Resources

- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [Pipeline Syntax](https://www.jenkins.io/doc/book/pipeline/syntax/)
- [Plugin Index](https://plugins.jenkins.io/)
- [Jenkins Best Practices](https://www.jenkins.io/doc/book/pipeline/pipeline-best-practices/)

---

*Last Updated: 2025-10-02*  
*Version: 1.0.0 - The First Enlightenment*  
*Jenkins Version: 2.400+*
