# NationalVote — Complete Beginner Setup and Deployment Guide

This guide explains how a new developer can set up, run, containerize, deploy, and verify the NationalVote voting application.

It assumes basic familiarity with a computer but does not assume prior experience with AWS, Docker, Terraform, Kubernetes, Helm, or CI/CD.

> **Important:** Follow the stages in order. Do not proceed to the next stage until the current stage works. Commands must be adjusted if your repository, AWS configuration, or Kubernetes resources use different names.

## Project Roadmap

The overall workflow is:

1. Obtain the project source code.
2. Install and verify the required tools.
3. Run the application locally.
4. Build and test the Docker image.
5. Create and configure AWS infrastructure.
6. Install or verify K3s and Helm on the EC2 server.
7. Configure PostgreSQL and the application database connection.
8. Deploy the application using Helm.
9. Configure GitHub Actions and Docker Hub.
10. Run the automated CI/CD pipeline.
11. Verify the application and monitoring.
12. Record screenshots and document the results.

---

## Stage 1 — Obtain the project

Install Git from the official Git website.

Open PowerShell and run:

```powershell
git --version
```

Clone the repository:

```powershell
git clone https://github.com/YOUR_GITHUB_USERNAME/Capstone_Voting-app.git
```

Enter the project directory:

```powershell
cd Capstone_Voting-app
```

Replace `YOUR_GITHUB_USERNAME` with the actual GitHub account containing the repository.

Check the files:

```powershell
Get-ChildItem
```

Expected files and directories may include:

- `README.md`
- `app/`
- `Dockerfile`
- `requirements.txt`
- `terraform/`
- `helm/`
- `.github/workflows/`

The actual file structure may differ. Review the repository before running commands that depend on a particular file.

## Stage 2 — Install the required tools

Install the following tools on the computer or server where they will be used.

| Tool | Purpose |
|---|---|
| Git | Download and version the source code |
| Python and pip | Run the Flask application |
| Docker | Build and run containers |
| AWS CLI | Interact with AWS |
| Terraform | Provision infrastructure |
| Helm | Manage Kubernetes releases |
| K3s | Run Kubernetes on the EC2 server |
| GitHub account | Host code and run CI/CD |
| Docker Hub account | Store Docker images |

You do not need to run Kubernetes locally on Windows for this project. The intended Kubernetes environment is the AWS EC2 server.

Verify the tools:

```powershell
git --version
python --version
docker --version
aws --version
terraform --version
```

A command may not be available on Windows if its tool has not been installed or added to PATH. Resolve installation issues before proceeding.

## Stage 3 — Run the application locally

From the project root, create a Python virtual environment:

```powershell
python -m venv .venv
```

Activate it:

```powershell
.\.venv\Scripts\Activate.ps1
```

Install the application dependencies:

```powershell
pip install -r requirements.txt
```

If PowerShell blocks virtual environment activation, follow the Python documentation for a safe activation method or use the environment's Python executable directly.

Run the application using the entry point configured in the repository. For example, if the Flask application is exposed as `app` from the `app` package:

```powershell
flask --app app run --host=127.0.0.1 --port=5000
```

Open a browser at:

`http://127.0.0.1:5000`

Confirm that the home page loads.

If the application requires PostgreSQL, configure a valid database connection before testing database-dependent functionality. A home page that loads does not necessarily prove that voting and results persistence work.

Stop the development server with `Ctrl+C`.

## Stage 4 — Build and test the Docker image

Ensure Docker Desktop is running on Windows, or Docker is available on the machine where the build will run.

From the project root:

```powershell
docker build -t nationalvote:local .
```

Check the image:

```powershell
docker images
```

Run the container:

```powershell
docker run --rm -p 5000:5000 nationalvote:local
```

Test the endpoint in another PowerShell window:

```powershell
curl.exe -i http://127.0.0.1:5000
```

If the application depends on PostgreSQL, the database must also be reachable from the container, and the correct connection configuration must be supplied.

Stop the container with `Ctrl+C`.

## Stage 5 — Configure Docker Hub

Create or sign in to a Docker Hub account.

Authenticate:

```powershell
docker login
```

Build the image using the repository name:

```powershell
docker build -t samzcode/nationalvote:latest .
```

Push it:

```powershell
docker push samzcode/nationalvote:latest
```

Verify that the image appears in Docker Hub.

The example assumes the image repository is `samzcode/nationalvote`. Replace it if your actual repository name differs.

For repeatable deployments, publish a commit-specific image tag as well as `latest`.

## Stage 6 — Configure AWS

Create or use an AWS account that has permission to manage the resources required by the project.

Configure the AWS CLI using an approved authentication method. Do not commit credentials to Git.

Verify authentication:

```powershell
aws sts get-caller-identity
```

If this command fails, fix authentication and permissions before continuing.

### Provision infrastructure with Terraform

Open the Terraform directory:

```powershell
cd terraform
```

Initialize Terraform:

```powershell
terraform init
```

Validate the configuration:

```powershell
terraform validate
```

Review the planned changes:

```powershell
terraform plan
```

Read the plan carefully. Only apply it if it targets the intended AWS account and resources:

```powershell
terraform apply
```

Review the outputs:

```powershell
terraform output
```

Return to the project root:

```powershell
cd ..
```

**Warning:** Do not create duplicate infrastructure blindly. If the EC2 instance already exists, determine whether Terraform manages it before attempting to provision another one.

If AWS reports an explicit Organizations policy denial, resolve the account-level restriction with the account administrator or AWS support as appropriate. Changing an ordinary IAM policy cannot override an explicit Service Control Policy denial.

## Stage 7 — Connect to the EC2 server

Obtain the EC2 public IP address and the correct private SSH key.

Connect from PowerShell:

```powershell
ssh -i "C:\path\to\your-key.pem" ubuntu@YOUR_EC2_PUBLIC_IP
```

Replace the key path and public IP with your actual values.

The EC2 security group must allow SSH from your trusted public IP address.

Once connected, check the server:

```bash
whoami
hostname
free -h
df -h
```

Check K3s:

```bash
sudo systemctl status k3s --no-pager
```

Check the Kubernetes node:

```bash
sudo k3s kubectl get nodes
```

The node should be `Ready`.

If K3s is not installed, follow the official K3s installation instructions and ensure that the EC2 instance has sufficient resources before deploying the application.

## Stage 8 — Configure Kubernetes and Helm

Check Helm:

```bash
sudo helm version
```

Check the namespace:

```bash
sudo k3s kubectl get namespaces
```

The project namespace is expected to be `voting-app`.

If it does not exist:

```bash
sudo k3s kubectl create namespace voting-app
```

If it already exists, leave it in place.

### Validate the Helm chart

From the repository root, the chart should be located at:

```text
helm/voting-app/
```

Run:

```bash
sudo helm lint ./helm/voting-app
```

Render the chart to inspect the resources:

```bash
sudo helm template nationalvote ./helm/voting-app \
  --namespace voting-app
```

Resolve template errors before deploying.

## Stage 9 — Configure PostgreSQL

The application requires a reachable PostgreSQL database if database functionality is enabled.

The expected Kubernetes Service name is:

```text
voting-postgres
```

From inside the Kubernetes cluster, the application should connect to the database Service rather than its own `localhost`.

The connection string has this general format:

```text
postgresql+psycopg://DB_USER:DB_PASSWORD@voting-postgres:5432/DB_NAME
```

Use the actual credentials and database name configured for PostgreSQL.

Configure credentials through Kubernetes Secrets or another appropriate secret-management mechanism. Do not place production credentials directly in a committed Helm values file.

Before deploying the application, verify that:

- The PostgreSQL pod is running and ready.
- The `voting-postgres` Service exists.
- The database credentials match the database configuration.
- The application receives the correct `DATABASE_URL`.
- The database uses persistent storage if data must survive pod replacement.

Check database resources:

```bash
sudo k3s kubectl get pods,services -n voting-app
```

If PostgreSQL is already running, do not delete its pod, namespace, or storage during routine troubleshooting.

## Stage 10 — Deploy the application with Helm

Run the deployment from the directory containing the Helm chart, or provide the correct chart path.

```bash
sudo helm upgrade --install nationalvote ./helm/voting-app \
  --namespace voting-app \
  --wait \
  --timeout 5m
```

Check the release:

```bash
sudo helm --kubeconfig /etc/rancher/k3s/k3s.yaml \
  list -n voting-app
```

Check the pods:

```bash
sudo k3s kubectl get pods -n voting-app -o wide
```

Check the deployments:

```bash
sudo k3s kubectl get deployments -n voting-app
```

Check the services:

```bash
sudo k3s kubectl get services -n voting-app
```

The expected application Service uses NodePort `30080`, if that is what the current chart specifies.

A successful Helm command does not guarantee that the application can connect to its database. Inspect the pod status and logs.

## Stage 11 — Test the deployed application

On the EC2 server, run:

```bash
curl -i --max-time 10 http://127.0.0.1:30080
```

A successful home-page request should normally return `HTTP/1.1 200 OK`.

If the local test succeeds, open the application in your browser:

`http://YOUR_EC2_PUBLIC_IP:30080`

The EC2 security group must allow inbound TCP traffic on port `30080` for direct external access. Restrict this access appropriately.

Test the following features where implemented:

- Home page and candidate display.
- Voting submission.
- Vote count updates.
- Results display.
- Persistence of votes after an application restart.

Use demonstration data only. Do not represent test votes as official election results.

## Stage 12 — Configure GitHub Actions CI/CD

Open the GitHub repository and navigate to:

**Settings → Secrets and variables → Actions**

Configure the secrets required by the workflow file. Common examples are:

| Secret | Purpose |
|---|---|
| `DOCKERHUB_USERNAME` | Docker Hub username |
| `DOCKERHUB_TOKEN` | Docker Hub access token |
| `EC2_HOST` | EC2 public IP or hostname |
| `EC2_SSH_PRIVATE_KEY` | Private key for SSH deployment |
| `AWS_ACCESS_KEY_ID` | AWS access key, if required by the workflow |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key, if required by the workflow |

Secret names must match the actual workflow YAML. Add an AWS region or image repository variable if the workflow expects one.

The pipeline should perform the following tasks:

1. Check out the source code.
2. Install dependencies and run tests.
3. Build the Docker image.
4. Push the image to Docker Hub.
5. Connect to EC2.
6. Deploy the new image using Helm.
7. Check the deployment result.

Commit and push a change to the configured branch to trigger the workflow.

Open **GitHub → Actions**, inspect the run, and investigate any failed step.

After a successful workflow run, independently check the EC2 pods and test the website. A green workflow indicator alone does not prove that the deployed application works.

## Stage 13 — Configure monitoring

If Prometheus and Grafana are part of the deployment, verify that they are installed and configured.

On EC2:

```bash
sudo k3s kubectl get pods -A | grep -Ei 'grafana|prometheus'
```

List the services:

```bash
sudo k3s kubectl get services -A
```

If Grafana is deployed in the `monitoring` namespace and its Service is named `monitoring-grafana`, port-forward it:

```bash
sudo k3s kubectl port-forward \
  -n monitoring service/monitoring-grafana 3000:80
```

Keep the command running and open `http://127.0.0.1:3000` on the same machine where the port-forward is running.

Use the actual Service name and namespace shown by Kubernetes if they differ.

Confirm that the dashboard displays real collected metrics before presenting it as working monitoring.

## Stage 14 — Troubleshoot common errors

### Kubernetes cluster unreachable

Use the K3s kubeconfig explicitly with Helm:

```bash
sudo helm --kubeconfig /etc/rancher/k3s/k3s.yaml \
  list -n voting-app
```

### Application pod is restarting

```bash
sudo k3s kubectl logs deployment/nationalvote \
  -n voting-app --tail=100
```

For the previous container instance:

```bash
sudo k3s kubectl logs deployment/nationalvote \
  -n voting-app --previous --tail=100
```

### Database connection refused

Check:

- `DATABASE_URL` is configured.
- The database hostname is `voting-postgres`, if that is the configured Service name.
- PostgreSQL is ready.
- Credentials and database names match.
- Network connectivity between the pods works.

### ImagePullBackOff

Verify the image and tag in the Deployment:

```bash
sudo k3s kubectl get deployment nationalvote \
  -n voting-app \
  -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
```

Check that the image exists in Docker Hub and is accessible to the cluster.

### Website unavailable

```bash
sudo k3s kubectl get pods,services -n voting-app
```

```bash
curl -i --max-time 10 http://127.0.0.1:30080
```

If the local request works but the external request fails, inspect the EC2 security group and network configuration.

### Terraform fails

Check AWS authentication, IAM permissions, account restrictions, Terraform state, and the plan before making additional changes.

## Stage 15 — Record evidence for submission

Create an evidence directory on EC2:

```bash
mkdir -p ~/NationalVote_Evidence
```

Save deployment status:

```bash
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

Take screenshots of:

1. Kubernetes node status.
2. Application and database pods.
3. Kubernetes Services.
4. Deployment replicas.
5. Helm release status.
6. Successful HTTP response.
7. Application logs.
8. Voting website.
9. Voting results.
10. Successful GitHub Actions run.
11. Docker Hub image tags.
12. Grafana dashboard, if configured.
13. Terraform validation or reviewed plan.

On Windows, press `Windows + Shift + S` to capture screenshots and save them with descriptive filenames.

Do not describe failed or unverified components as successful.

## Final Checklist

Before submitting the project, confirm the following:

- [ ] The source code is available in GitHub.
- [ ] The application runs locally.
- [ ] The Docker image builds successfully.
- [ ] The image is published to Docker Hub.
- [ ] AWS infrastructure is configured.
- [ ] The K3s node is Ready.
- [ ] The PostgreSQL database is reachable.
- [ ] The application pod is Ready.
- [ ] Helm reports the intended release as deployed.
- [ ] The website responds successfully.
- [ ] Voting and results functionality have been tested.
- [ ] GitHub Actions has completed successfully.
- [ ] Monitoring has been verified, if included.
- [ ] Screenshots and deployment records are saved.
- [ ] No secrets or private keys are committed.

## Conclusion

This guide provides the complete sequence for reproducing the NationalVote DevOps deployment. The precise commands and resource names must match the actual repository configuration. Verify each stage before moving forward, and document any components that remain incomplete.
