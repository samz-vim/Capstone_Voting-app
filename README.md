# NationalVote — Voting App Ship It (DevOps Capstone)

A from-scratch, three-candidate voting **demo** built with Flask, PostgreSQL, Docker, Terraform, AWS ECR/EKS, GitHub Actions, Kubernetes, and Helm.

## Candidate options
- Bola Ahmed Tinubu
- Peter Obi
- Atiku Abubakar

**Important:** This is an educational demonstration only. It is not an official election system, is not affiliated with any candidate or election authority, and does not provide election-grade identity checks, fraud prevention, auditability, or one-person-one-vote guarantees. Votes can be submitted repeatedly.

## Local prerequisites
- Docker Desktop running on Windows
- Git
- A GitHub account (for CI/CD)
- AWS CLI and Terraform only when you reach the cloud stage

## Run locally (PowerShell)
```powershell
docker compose -f compose.yaml config
docker compose -f compose.yaml up --build -d
docker compose -f compose.yaml ps
Invoke-RestMethod http://localhost:5000/health
Invoke-RestMethod http://localhost:5000/api/results
```
Open http://localhost:5000 in a browser. Submit demo votes and watch results refresh automatically.

Stop containers while preserving the local database volume:
```powershell
docker compose down
```
To delete the local database volume and all local demo votes:
```powershell
docker compose down -v
```

## Run tests locally
Use Python 3.12 if available:
```powershell
py -3.12 -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install -r requirements.txt pytest
pytest -v
```
The tests use SQLite in memory and do not need the local PostgreSQL container.

## Push to GitHub
Create an empty GitHub repository named `voting-app-ship-it`, then:
```powershell
git init
git add .
git commit -m "Build NationalVote voting app demo"
git branch -M main
git remote add origin https://github.com/YOUR_GITHUB_USERNAME/voting-app-ship-it.git
git push -u origin main
```
Replace `YOUR_GITHUB_USERNAME` with your GitHub username.

## Cloud deployment order
1. Run and test locally.
2. Push to GitHub; confirm the CI workflow passes.
3. Configure AWS credentials locally and set `terraform/terraform.tfvars`.
4. Run Terraform format, init, validate, plan; review the plan and costs before apply.
5. Apply Terraform to create the VPC, ECR repository, EKS cluster, node group, and GitHub OIDC role.
6. Set repository Actions variables/secrets as described below.
7. The Terraform GitHub workflow checks formatting, initialization, and validation. Apply infrastructure locally after reviewing the plan; do not use ephemeral GitHub runner storage for Terraform state.
8. Push to `main` to trigger the image build/push and Helm deployment workflow.

### Terraform local commands
```powershell
Copy-Item terraform/terraform.tfvars.example terraform/terraform.tfvars
# Edit terraform.tfvars with your GitHub owner and repo values.
cd terraform
terraform fmt -recursive
terraform init
terraform validate
terraform plan
# Only after reviewing estimated charges and the plan:
terraform apply
terraform output
cd ..
```

### GitHub repository configuration
Repository **Settings → Secrets and variables → Actions**:
- Secret `AWS_ROLE_ARN`: value from `terraform output -raw github_actions_role_arn`
- Variable `AWS_REGION`: same region as Terraform (for example `eu-west-1`)
- Variable `EKS_CLUSTER_NAME`: value from `terraform output -raw eks_cluster_name`
- Variable `ECR_REPOSITORY`: `voting-app` (or your configured `project_name`)

The role in this educational starter uses `AdministratorAccess` to simplify a first demo. This is broad access and is not suitable for production; replace it with least-privilege IAM policies before any real use. The role trust is restricted to the repository and branch entered in `terraform.tfvars`.

## Database warning for cloud
The included Helm PostgreSQL deployment uses `emptyDir` storage, which is temporary and can lose data when its pod is replaced. It is only a learning shortcut. For a persistent cloud deployment, use Amazon RDS for PostgreSQL or a properly configured persistent-volume-backed PostgreSQL installation, store credentials in Kubernetes Secrets/AWS Secrets Manager, and enable backups before treating the data as durable.

## Costs and cleanup
EKS clusters, EC2 worker nodes, NAT gateways, load balancers, ECR storage, and other AWS services can incur charges. Do not apply Terraform until you understand the plan and costs.

When finished and after saving any outputs you need:
```powershell
cd terraform
terraform destroy
```
Review the destroy plan before confirming. This removes the infrastructure managed by this Terraform configuration, but check for any resources or data created outside it.
