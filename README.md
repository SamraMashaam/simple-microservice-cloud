# Cloud Project - Microservices Deployment with CI/CD Pipeline

A complete automated deployment pipeline for a microservices application on AWS, featuring Docker, Terraform, Ansible, Kubernetes (microk8s), GitHub Actions, and ArgoCD.

## Project Overview

This project takes a simple 3-tier microservices application and deploys it on AWS EC2 with a fully automated CI/CD pipeline. Any code change pushed to GitHub automatically builds new Docker images, updates Kubernetes manifests, and deploys to the cluster—all without manual intervention.

### The Microservices Application

The application consists of three services:
- **QuoteService** (Python/Flask): Returns random inspirational quotes
- **ApiGateway** (Node.js/Express): Acts as a gateway between frontend and quote service
- **FrontendApplication** (HTML/JavaScript/Nginx): User interface to display quotes

Original repo: [simple-microservice-example](https://github.com/kasvith/simple-microservice-example)

---

## Tools & Technologies

### Infrastructure & Configuration
- **Terraform**: Creates and manages AWS infrastructure (VPC, EC2, security groups) as code
- **Ansible**: Configures the EC2 instance (installs Docker, microk8s, sets up users)
- **AWS EC2**: The server running our Kubernetes cluster (t3.small instance with Ubuntu 22.04)

### Containerization & Orchestration
- **Docker**: Packages each microservice into containers
- **Docker Hub**: Stores our Docker images
- **Kubernetes (microk8s)**: Manages and runs containers on the EC2 instance
- **microk8s**: Lightweight Kubernetes distribution perfect for single-node setups

### CI/CD Pipeline
- **GitHub Actions**: Automatically builds Docker images when code changes
- **ArgoCD**: Monitors the Git repo and auto-deploys changes to Kubernetes

---

### The Complete Pipeline Flow:

1. **Developer pushes code** to GitHub
2. **GitHub Actions triggers**, builds new Docker images, pushes to Docker Hub, updates K8s manifests
3. **ArgoCD detects** manifest changes in Git
4. **ArgoCD syncs** the Kubernetes cluster with the new configuration
5. **Application updates** automatically—no manual deployment needed!

---

## Setup Steps (From Scratch)

### Phase 1: Local Setup

1. **Installed tools on WSL Ubuntu:**
   - AWS CLI (to interact with AWS)
   - Terraform (infrastructure as code)
   - Ansible (configuration management)
   - Docker (containerization)
   - Git (version control)

2. **Configured AWS CLI:**

3. **Forked and cloned the microservices repo:**

---

### Phase 2: Containerization (Docker)

Created a `Dockerfile` for each service:

**QuoteService (Python):**
- Base image: `python:3.11-slim`
- Installs Flask
- Exposes port 5000

**ApiGateway (Node.js):**
- Base image: `node:18-alpine`
- Installs npm dependencies
- Exposes port 3000

**FrontendApplication (Multi-stage):**
- Stage 1: Builds the app with Node.js and webpack
- Stage 2: Serves with nginx
- Exposes port 80

Built and tested images locally

Pushed to Docker Hub

---

### Phase 3: Infrastructure as Code (Terraform)

Created Terraform configuration files:

**`provider.tf`**: AWS provider setup
**`variables.tf`**: Configurable values (region, instance type, etc.)
**`vpc.tf`**: VPC, subnet, internet gateway, route tables
**`security-groups.tf`**: Firewall rules for SSH, HTTP, app ports
**`ec2.tf`**: EC2 instance and SSH key pair
**`outputs.tf`**: Displays useful info like EC2 IP address

**What was created:**
- 1 VPC (Virtual Private Cloud)
- 1 Public subnet
- 1 Internet Gateway
- Security groups with ports: 22 (SSH), 80 (HTTP), 443 (HTTPS), 3000 (API), 8080 & 30080 (Frontend), 30081 & 30443 (ArgoCD)
- 1 EC2 instance (t3.small, 2GB RAM, 30GB storage)
- 1 Elastic IP (so the IP doesn't change on restart)

**Result:** EC2 instance running at `52.1.139.2`

---

### Phase 4: Configuration Management (Ansible)

Created Ansible playbook to configure the EC2:

**`inventory.ini`**: Defines the EC2 host
**`playbook.yml`**: Automation script that:
- Updates all system packages
- Installs Docker
- Installs microk8s (Kubernetes)
- Enables DNS, storage, and ingress addons
- Sets up user permissions

**Result:** EC2 fully configured with Docker and Kubernetes ready to deploy apps

---

### Phase 5: Kubernetes Manifests

Created YAML files for each microservice:

**For each service:**
- **Deployment**: Defines how many replicas, which Docker image, resource limits
- **Service**: Exposes the deployment (ClusterIP for internal, NodePort for external access)

Files created:
- `quote-service-deployment.yaml` & `quote-service-service.yaml`
- `api-gateway-deployment.yaml` & `api-gateway-service.yaml`
- `frontend-deployment.yaml` & `frontend-service.yaml`

Deployed to Kubernetes

**Result:** Application accessible at `http://52.1.139.2:30080`

---

### Phase 6: CI Pipeline (GitHub Actions)

Created `.github/workflows/ci-cd.yml`:

**What it does:**
1. Triggers on code changes to microservices
2. Builds Docker images with git SHA as tag
3. Pushes images to Docker Hub
4. Updates K8s manifests with new image tags
5. Commits updated manifests back to GitHub

**Result:** Any code push triggers automatic Docker builds

---

### Phase 7: CD Pipeline (ArgoCD)

Installed ArgoCD on the Kubernetes cluster

**Scaled down unnecessary components** (due to 2GB RAM limit):
- applicationset-controller
- dex-server
- notifications-controller

Created ArgoCD Application to watch the GitHub repo

**What ArgoCD does:**
- Monitors the `k8s/` folder in GitHub
- Detects when manifests change
- Automatically syncs Kubernetes cluster with Git
- Self-heals if manual changes are made to the cluster

**ArgoCD UI:** `http://52.1.139.2:30081`

**Result:** Complete GitOps—Git is the single source of truth

---

## How the Pipeline Works (End-to-End)

1. **Developer changes code** (e.g., adds a new quote to `QuoteService/quotes.txt`)
2. **Commits and pushes** to GitHub
3. **GitHub Actions workflow runs**:
   - Builds new `quote-service` Docker image
   - Tags it with git SHA (e.g., `7cf3a42`)
   - Pushes to Docker Hub
   - Updates `k8s/quote-service-deployment.yaml` with new tag
   - Commits changes back to GitHub
4. **ArgoCD detects changes**:
   - Sees updated manifest in Git
   - Syncs Kubernetes cluster
   - Pulls new Docker image
   - Rolls out updated pods
5. **Application updates automatically**:
   - Old quote-service pod terminates
   - New pod starts with updated code
   - Users see the new quote without any downtime!

---

## Accessing the Application

- **Frontend:** http://52.1.139.2:30080
- **API Gateway:** http://52.1.139.2:30003/api/randomquote
- **ArgoCD UI:** http://52.1.139.2:30081 (admin / [get password from secret])

---
---

## Key Learnings

- **Infrastructure as Code**: Terraform makes AWS setup reproducible and version-controlled
- **Configuration Management**: Ansible automates server setup—no manual SSH commands
- **Containerization**: Docker ensures apps run the same everywhere
- **Orchestration**: Kubernetes manages containers, handles restarts, and scales apps
- **GitOps**: ArgoCD keeps the cluster in sync with Git—Git becomes the single source of truth
- **Automation**: GitHub Actions eliminates manual builds and deployments

---

## Acknowledgments

- Original microservices app by [@kasvith](https://github.com/kasvith/simple-microservice-example)
- Built as a DevOps learning project demonstrating full CI/CD pipeline implementation
