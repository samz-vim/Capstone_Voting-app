# NationalVote — Cloud-Native Voting Application

A DevOps capstone project demonstrating how to build, containerize, deploy, and manage a web-based voting application using cloud infrastructure, Kubernetes, Infrastructure as Code, and CI/CD automation.

## Table of Contents

- [Project Overview](#project-overview)
- [Project Objectives](#project-objectives)
- [Features](#features)
- [Technology Stack](#technology-stack)
- [System Architecture](#system-architecture)
- [Application Candidates](#application-candidates)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Run the Application Locally](#run-the-application-locally)
- [Build and Run with Docker](#build-and-run-with-docker)
- [AWS Infrastructure](#aws-infrastructure)
- [Kubernetes Deployment with K3s](#kubernetes-deployment-with-k3s)
- [Helm Deployment](#helm-deployment)
- [CI/CD Pipeline](#cicd-pipeline)
- [Database Configuration](#database-configuration)
- [Monitoring and Observability](#monitoring-and-observability)
- [Verification and Testing](#verification-and-testing)
- [Troubleshooting](#troubleshooting)
- [Evidence and Screenshots](#evidence-and-screenshots)
- [Security Considerations](#security-considerations)
- [Future Improvements](#future-improvements)
- [Author](#author)

---

## Project Overview

NationalVote is a web-based voting application developed as a DevOps capstone project. The project focuses on automating the application delivery process, packaging the application into a Docker image, deploying it to cloud-hosted Kubernetes, and verifying the health of the deployed services.

The application uses Flask and Gunicorn for the web application and PostgreSQL for persistent relational database functionality.

The infrastructure and deployment workflow are designed around Amazon Web Services (AWS), Terraform, Docker, GitHub Actions, Kubernetes (K3s), and Helm.

This project demonstrates practical DevOps workflows, including version control, automated builds, container image publishing, cloud deployment, orchestration, and operational troubleshooting.

**Project status:** The application, database connection, deployment, CI/CD pipeline, and monitoring should each be verified independently before the project is described as fully operational.

## Project Objectives

1. Develop a functional voting web application.
2. Package the application and its dependencies into a Docker image.
3. Provision cloud infrastructure using Terraform where supported by the AWS account.
4. Deploy the application and database to Kubernetes running on an AWS EC2 instance.
5. Use Helm to manage Kubernetes application resources.
6. Automate build, test, image publishing, and deployment using GitHub Actions.
7. Verify application availability, pod health, service connectivity, and deployment status.
8. Introduce monitoring and observability using Prometheus and Grafana where configured.
9. Document deployment procedures, troubleshooting steps, and project evidence.

## Features

The application is intended to provide:

- A web interface for viewing the available candidates.
- Voting functionality.
- Vote counting and results display.
- A Flask-based backend.
- PostgreSQL database integration.
- Docker-based application packaging.
- Kubernetes deployment and service exposure.
- Helm-based deployment management.
- Automated CI/CD through GitHub Actions.
- Monitoring and troubleshooting support.

The availability of each feature must be confirmed against the current running application.

## Technology Stack

| Technology | Purpose |
|---|---|
| Python | Application programming language |
| Flask | Web application framework |
| Gunicorn | Python application server |
| PostgreSQL | Relational database |
| Docker | Application containerization |
| Docker Hub | Container image registry |
| AWS EC2 | Cloud virtual machine hosting |
| Terraform | Infrastructure as Code |
| Kubernetes / K3s | Container orchestration |
| Helm | Kubernetes package and release management |
| Git and GitHub | Version control and source hosting |
| GitHub Actions | CI/CD automation |
| Prometheus | Metrics collection, if configured |
| Grafana | Monitoring dashboards, if configured |

## System Architecture

The intended deployment workflow is:

```text
Developer
   |
   v
GitHub Repository
   |
   v
GitHub Actions
   |
   +----> Application Tests
   |
   +----> Docker Image Build
   |
   +----> Docker Hub Image Push
   |
   +----> SSH Deployment to AWS EC2
                 |
                 v
             K3s Cluster
                 |
          +------+------+
          |             |
          v             v
    NationalVote     PostgreSQL
       Flask          Database
          |
          v
   Kubernetes Service
          |
          v
     Web Browser

Monitoring, when configured:
Kubernetes / Application Metrics
          |
          v
      Prometheus
          |
          v
       Grafana
```

The browser accesses the application through the configured Kubernetes NodePort service. The intended external port is `30080`.

## Application Candidates

The application is designed around three candidates:

1. Bola Ahmed Tinubu
2. Peter Obi
3. Atiku Abubakar

This is a demonstration application. Its results must not be interpreted as official election results.

## Project Structure

The expected project layout includes the following components. Actual filenames may differ slightly in the repository.

```text
Capstone_Voting-app/
├── app/
│   └── __init__.py
├── tests/
├── templates/
├── static/
├── Dockerfile
├── requirements.txt
├── .dockerignore
├── .gitignore
├── README.md
├── .github/
│   └── workflows/
│       └── deploy.yml
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── ...
└── helm/
    └── voting-app/
        ├── Chart.yaml
        ├── values.yaml
        └── templates/
            ├── deployment.yaml
            ├── service.yaml
            └── postgres.yaml
```

The directory tree is illustrative. Keep only paths and files that actually exist in your repository.

## Prerequisites

Install or configure the following tools on the appropriate machine:

- Git
- Python and pip
- Docker
- AWS CLI
- Terraform
- An AWS account with the necessary permissions
- An EC2 Ubuntu instance
- SSH access to the EC2 instance
- K3s and Helm on the EC2 instance
- A GitHub repository
- A Docker Hub account

You do not need to install Kubernetes on your Windows computer for this deployment. Kubernetes commands can be run remotely on the EC2 server through SSH.

## Run the Application Locally

Clone the repository:

```bash
git clone https://github.com/YOUR_GITHUB_USERNAME/Capstone_Voting-app.git
cd Capstone_Voting-app
```

Create a Python virtual environment:

```bash
python -m venv .venv
```

Activate it on Windows PowerShell:

```powershell
.\.venv\Scripts\Activate.ps1
```

On Linux or macOS:

```bash
source .venv/bin/activate
```

Install dependencies:

```bash
pip install -r requirements.txt
```

Run the application using the entry point documented by the repository. For a Flask application exposing `app` from the `app` package, the command may be:

```bash
flask --app app run --host=0.0.0.0 --port=5000
```

Open:

```text
http://127.0.0.1:5000
```

If the application requires PostgreSQL, configure a valid database connection before running it. The local development command alone does not guarantee that database-dependent pages will work.

## Build and Run with Docker

Build the image from the project root:

```bash
docker build -t nationalvote:local .
```

Confirm that the image exists:

```bash
docker images
```

Run the container:

```bash
docker run --rm -p 5000:5000 nationalvote:local
```

If the application requires PostgreSQL, the database must also be running and the correct database connection environment variable must be supplied. Do not assume the application can connect to a database on `localhost` from inside a container.

Test the web endpoint:

```bash
curl -i http://127.0.0.1:5000
```

A successful HTTP response should normally return `200 OK` for the home page.

### Publish the image to Docker Hub

Log in to Docker Hub:

```bash
docker login
```

Build and tag the image using your Docker Hub username:

```bash
docker build -t samzcode/nationalvote:latest .
```

Push it:

```bash
docker push samzcode/nationalvote:latest
```

Verify that the image and tag exist in Docker Hub before deploying them to Kubernetes.

For automated deployment, an immutable commit-based tag is preferable to relying on `latest` alone.

## AWS Infrastructure

The deployment uses an AWS EC2 Ubuntu instance to host K3s and the application.

### Verify AWS CLI access

```bash
aws --version
aws sts get-caller-identity
```

If the identity command fails, resolve AWS credentials and permissions before running Terraform.

### Terraform workflow

Change into the directory containing the Terraform configuration:

```bash
cd terraform
```

Initialize Terraform:

```bash
terraform init
```

Validate the configuration:

```bash
terraform validate
```

Review the planned changes:

```bash
terraform plan
```

Apply only after reviewing the plan and confirming the intended resources:

```bash
terraform apply
```

Inspect available outputs:

```bash
terraform output
```

Return to the repository root when finished:

```bash
cd ..
```

**Important:** Terraform should not be run blindly against an existing environment. Confirm that the correct state backend, AWS account, permissions, and resource ownership are configured first. An explicit AWS Organizations policy denial cannot be fixed merely by changing the Terraform code.

## Kubernetes Deployment with K3s

Connect to the Ubuntu EC2 instance using SSH:

```bash
ssh -i /path/to/your-key.pem ubuntu@YOUR_EC2_PUBLIC_IP
```

Replace the key path and public IP with your actual values.

### 1. Check K3s

```bash
sudo systemctl status k3s --no-pager
```

Check the Kubernetes node:

```bash
sudo k3s kubectl get nodes
```

The node should report `Ready` before application deployment proceeds.

### 2. Check the application namespace

```bash
sudo k3s kubectl get namespace voting-app
```

If the namespace does not exist, create it:

```bash
sudo k3s kubectl create namespace voting-app
```

If it already exists, do not create it again.

### 3. Inspect application resources

```bash
sudo k3s kubectl get pods -n voting-app -o wide
```

```bash
sudo k3s kubectl get deployments -n voting-app
```

```bash
sudo k3s kubectl get services -n voting-app
```

The intended resources include:

- `nationalvote` — application Deployment.
- `nationalvote-service` — application Service.
- `voting-postgres` — PostgreSQL Deployment and Service.

Actual names must match the Kubernetes configuration in the repository.

### 4. Verify application access

The intended application URL is:

```text
http://YOUR_EC2_PUBLIC_IP:30080
```

The EC2 security group must allow inbound TCP traffic on port `30080` if direct public NodePort access is being used. Restrict access appropriately for a demonstration environment.

Before testing from a browser, test locally on EC2:

```bash
curl -i --max-time 10 http://127.0.0.1:30080
```

A successful response should return the application page, normally with HTTP status `200 OK`.

## Helm Deployment

The Helm chart is expected at:

```text
helm/voting-app/
```

Check that Helm is installed:

```bash
sudo helm version
```

Validate the chart:

```bash
sudo helm lint ./helm/voting-app
```

Inspect the rendered Kubernetes resources:

```bash
sudo helm template nationalvote ./helm/voting-app \
  --namespace voting-app
```

If the chart has valid configuration and the required Kubernetes resources are ready, deploy or update the release:

```bash
sudo helm upgrade --install nationalvote ./helm/voting-app \
  --namespace voting-app \
  --wait \
  --timeout 5m
```

Inspect the release:

```bash
sudo helm --kubeconfig /etc/rancher/k3s/k3s.yaml \
  list -n voting-app
```

Check the deployment:

```bash
sudo k3s kubectl rollout status deployment/nationalvote \
  -n voting-app --timeout=120s
```

A successful Helm command is not sufficient by itself. Verify that the application container starts, the database connection succeeds, and the HTTP endpoint responds correctly.

## CI/CD Pipeline

GitHub Actions is intended to automate the application delivery process.

### Intended pipeline stages

1. Retrieve the source code from GitHub.
2. Install dependencies and run the available automated tests.
3. Build the Docker image.
4. Authenticate to Docker Hub using GitHub Secrets.
5. Push the image to Docker Hub.
6. Connect to the EC2 instance using SSH.
7. Transfer or access the Helm chart.
8. Deploy the new image using Helm.
9. Check rollout and application health.

### Required GitHub configuration

Open the GitHub repository and navigate to:

**Settings → Secrets and variables → Actions**

Create the secrets required by the actual workflow. Common examples include:

| Secret | Purpose |
|---|---|
| `DOCKERHUB_USERNAME` | Docker Hub username |
| `DOCKERHUB_TOKEN` | Docker Hub access token |
| `EC2_HOST` | EC2 public IP or hostname |
| `EC2_SSH_PRIVATE_KEY` | Private SSH key for deployment |
| `AWS_ACCESS_KEY_ID` | AWS access key, if the workflow uses access keys |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key, if the workflow uses access keys |

If the workflow expects a region or image repository variable, configure those as well. The names must match the YAML workflow exactly.

Never commit private keys, access tokens, passwords, or database credentials to the repository.

### Run and verify the workflow

1. Commit and push a change to the configured branch.
2. Open the repository's **Actions** tab.
3. Open the latest workflow run.
4. Inspect the test, image build, image push, and deployment steps.
5. Confirm that the new image tag is present in Docker Hub.
6. Verify the deployed image and application health on EC2.

A green workflow status is useful evidence, but application health must still be checked independently.

## Database Configuration

PostgreSQL is the intended relational database for NationalVote.

The Kubernetes database Service is expected to be named:

```text
voting-postgres
```

The database connection must point to that Kubernetes Service from inside the application pod, rather than to `localhost`.

For example, the connection URL has this general structure:

```text
postgresql+psycopg://DB_USER:DB_PASSWORD@voting-postgres:5432/DB_NAME
```

The application configuration uses the `DATABASE_URL` environment variable. Supply the actual username, password, and database name that match the PostgreSQL configuration.

### Database verification

Check the database pod:

```bash
sudo k3s kubectl get pods -n voting-app
```

Check its logs:

```bash
sudo k3s kubectl logs deployment/voting-postgres \
  -n voting-app --tail=50
```

Check the Service:

```bash
sudo k3s kubectl get service voting-postgres \
  -n voting-app
```

The application should not be considered healthy until it can connect to PostgreSQL and successfully initialize or access its required tables.

**Storage warning:** If the PostgreSQL Deployment uses `emptyDir`, its data is not durable across pod replacement. A production-oriented deployment should use persistent storage and a backup strategy.

## Monitoring and Observability

Prometheus and Grafana are intended monitoring components for this project where they have been installed and configured.

Check whether Grafana is deployed:

```bash
sudo k3s kubectl get pods -A | grep -i grafana
```

Check for Prometheus:

```bash
sudo k3s kubectl get pods -A | grep -i prometheus
```

List services:

```bash
sudo k3s kubectl get services -A
```

If Grafana is installed in the `monitoring` namespace and its Service is named `monitoring-grafana`, you can use port forwarding:

```bash
sudo k3s kubectl port-forward \
  -n monitoring service/monitoring-grafana 3000:80
```

Keep that terminal running and open the following URL on the same machine where the port-forward command is running:

```text
http://127.0.0.1:3000
```

If the Service name or namespace differs, use the actual values shown by `kubectl get services -A`.

Grafana dashboards should be captured as project evidence only after confirming that Grafana is accessible and that the displayed metrics are being collected.

## Verification and Testing

Run these commands on the EC2 instance to inspect the deployed application.

### Kubernetes node

```bash
sudo k3s kubectl get nodes -o wide
```

Expected: the node is `Ready`.

### Application and database pods

```bash
sudo k3s kubectl get pods -n voting-app -o wide
```

Expected: application and database pods are ready, with no repeated restarts.

### Deployment status

```bash
sudo k3s kubectl get deployments -n voting-app
```

Expected: available replicas match the intended replica count.

### Services

```bash
sudo k3s kubectl get services -n voting-app
```

Expected: the application Service exposes the configured NodePort.

### Application logs

```bash
sudo k3s kubectl logs deployment/nationalvote \
  -n voting-app --tail=50
```

Expected: no startup failure or database connection error.

### HTTP response

```bash
curl -i --max-time 10 http://127.0.0.1:30080
```

Expected: the home page responds successfully.

### Helm release

```bash
sudo helm --kubeconfig /etc/rancher/k3s/k3s.yaml \
  list -n voting-app
```

Expected: the release is deployed.

### Save a deployment record

```bash
mkdir -p ~/NationalVote_Evidence

{
  echo "=== DATE ==="
  date
  echo "=== NODES ==="
  sudo k3s kubectl get nodes -o wide
  echo "=== PODS ==="
  sudo k3s kubectl get pods -n voting-app -o wide
  echo "=== SERVICES ==="
  sudo k3s kubectl get services -n voting-app
  echo "=== DEPLOYMENTS ==="
  sudo k3s kubectl get deployments -n voting-app
  echo "=== HELM ==="
  sudo helm --kubeconfig /etc/rancher/k3s/k3s.yaml \
    list -n voting-app
} 2>&1 | tee ~/NationalVote_Evidence/deployment-evidence.txt
```

This creates a text record of the current state. It does not, by itself, prove that every component is healthy.

## Troubleshooting

### Kubernetes cluster unreachable

If Helm reports that it cannot connect to `localhost:8080`, explicitly specify the K3s configuration file:

```bash
sudo helm --kubeconfig /etc/rancher/k3s/k3s.yaml \
  list -n voting-app
```

Check K3s:

```bash
sudo systemctl status k3s --no-pager
```

### Application pod keeps restarting

Inspect the pod and its logs:

```bash
sudo k3s kubectl get pods -n voting-app
```

```bash
sudo k3s kubectl logs deployment/nationalvote \
  -n voting-app --tail=100
```

If the container restarted, inspect the previous container logs:

```bash
sudo k3s kubectl logs deployment/nationalvote \
  -n voting-app --previous --tail=100
```

A database connection failure may indicate that `DATABASE_URL` is missing or incorrect, the PostgreSQL Service is unavailable, or the database credentials do not match.

### ImagePullBackOff

Check the configured image:

```bash
sudo k3s kubectl get deployment nationalvote \
  -n voting-app \
  -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
```

Confirm that the image repository and tag exist in Docker Hub and that the cluster can pull them.

### NodePort does not respond

Check the Service and application pods:

```bash
sudo k3s kubectl get svc -n voting-app
```

```bash
sudo k3s kubectl get pods -n voting-app -o wide
```

Then test locally:

```bash
curl -i --max-time 10 http://127.0.0.1:30080
```

If local access works but external access fails, inspect the EC2 security group and network rules.

### Helm ownership conflict

Helm may reject an existing Kubernetes resource that was created outside the release. Inspect the resource and release before changing labels or annotations. Avoid deleting the namespace or database resources merely to resolve an ownership conflict.

### Terraform permission errors

If AWS returns an explicit Organizations Service Control Policy denial, verify the account and organizational restrictions. Changing IAM permissions alone cannot override an explicit SCP deny.

## Evidence and Screenshots

Create a folder named `NationalVote_Capstone_Evidence` to keep the evidence organized.

Recommended screenshots:

| Filename | Evidence |
|---|---|
| `01-kubernetes-node.png` | K3s node in `Ready` state |
| `02-application-pods.png` | Application and PostgreSQL pod status |
| `03-kubernetes-services.png` | Kubernetes Services and NodePort |
| `04-kubernetes-deployments.png` | Deployment replica status |
| `05-helm-release.png` | Helm release status |
| `06-website-test.png` | Successful HTTP response |
| `07-application-logs.png` | Application startup and database connection logs |
| `08-nationalvote-homepage.png` | Application displayed in the browser |
| `09-voting-results.png` | Voting interface or results page |
| `10-github-actions.png` | Successful CI/CD workflow run |
| `11-docker-hub.png` | Published image and tags |
| `12-monitoring-dashboard.png` | Working Grafana dashboard, if configured |
| `13-terraform.png` | Terraform validation or reviewed plan |

On Windows, press **Windows + Shift + S** to capture a screenshot, then save it using the appropriate filename.

Only describe a screenshot as proof of success when the output actually demonstrates that result. If a component is not yet working, document the issue separately rather than presenting a failed state as successful deployment evidence.

## Security Considerations

- Store application and database secrets in appropriate secret-management systems.
- Use Kubernetes Secrets or an external secret manager for database credentials.
- Do not commit `.env` files, private keys, AWS credentials, or Docker Hub tokens.
- Use restricted IAM permissions for automation.
- Restrict SSH and NodePort access to trusted IP addresses where practical.
- Use persistent database storage and backups for data that must survive pod replacement.
- Use immutable image tags to make deployments traceable.
- Treat the voting application as a demonstration, not a production election system.

## Future Improvements

Possible improvements include:

- Add automated unit and integration tests.
- Implement readiness and liveness probes.
- Improve database persistence and backup procedures.
- Add Prometheus metrics and Grafana dashboards.
- Introduce automated post-deployment smoke tests.
- Improve CI/CD rollback and deployment verification.
- Add HTTPS and stronger access controls.
- Use immutable image tags and image scanning.
- Document resource sizing, availability, and recovery procedures.

## Author

**NationalVote — DevOps Capstone Project**

Focus areas: Cloud Infrastructure, Infrastructure as Code, Containerization, Kubernetes, Helm, CI/CD Automation, and Monitoring.

Built as a practical project to demonstrate DevOps engineering workflows and cloud application deployment.
