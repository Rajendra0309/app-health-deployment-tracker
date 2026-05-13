# CI/CD Enabled Application Health & Deployment Tracker

This project demonstrates a real-world DevOps workflow by building and deploying a lightweight web application that exposes application health and deployment metadata, with fully automated CI/CD using GitHub Actions and Docker on AWS EC2, plus Kubernetes and Terraform on AWS EKS.

The focus of this project is not application complexity, but **deployment automation, versioning, and infrastructure understanding**, which are core DevOps responsibilities.

---

## Features

- Application health check endpoint (`/health`)
- Deployment metadata endpoint (`/`)
  - Application status
  - Environment (production)
  - Application version (Git commit hash)
  - Last deployment timestamp
- Containerized using Docker
- Automated CI/CD pipeline using GitHub Actions
- Deployment to AWS EC2 via SSH
- Local Kubernetes deployment on Minikube
- Production Kubernetes deployment on AWS EKS
- Infrastructure provisioning with Terraform
- Secure handling of credentials using GitHub Secrets

---

## Tech Stack

- **Backend:** Node.js, Express
- **Containerization:** Docker
- **CI/CD:** GitHub Actions
- **Cloud:** AWS EC2, AWS EKS
- **IaC:** Terraform
- **Version Control:** Git & GitHub
- **Monitoring (basic):** Application health endpoint

---

## Project Structure

```
app-health-deployment-tracker/
├── app.js
├── package.json
├── package-lock.json
├── Dockerfile
├── .dockerignore
├── .gitignore
├── k8s/
│   ├── local/
│   │   ├── configmap.yaml
│   │   ├── deployment.yaml
│   │   └── service.yaml
│   └── prod/
│       ├── configmap.yaml
│       ├── deployment.yaml
│       └── service.yaml
├── terraform/
│   ├── eks.tf
│   ├── iam.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── security-groups.tf
│   ├── terraform.tfvars
│   ├── variables.tf
│   └── vpc.tf
└── .github/
  └── workflows/
    └── deploy.yml
```

---

## Application Endpoints

| Endpoint | Description |
|----------|-------------|
| `/` | Shows app status, environment, version, and deployment time |
| `/health` | Health check endpoint |
| `/version` | Returns deployed app version |

Example response from `/`:

```json
{
  "status": "UP",
  "environment": "production",
  "version": "4b0d105",
  "deployedAt": "2026-02-08T09:41:08Z"
}
```

---

## Dockerization

The application is containerized using Docker for consistency across environments.

**Build image:**
```bash
docker build -t app-health-tracker .
```

**Run container:**
```bash
docker run -d \
  -p 3000:3000 \
  -e APP_VERSION=1.0.0 \
  -e ENVIRONMENT=production \
  -e DEPLOYED_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ") \
  app-health-tracker
```

---

## CI/CD Pipeline (GitHub Actions)

The CI/CD pipeline is triggered on every push to the main branch.

**What the pipeline does:**

1. Checks out source code
2. Generates deployment metadata:
   - Git commit hash as application version
   - Deployment timestamp
3. Connects to AWS EC2 using SSH
4. Pulls the latest code
5. Builds a new Docker image
6. Stops and removes the old container
7. Runs the updated container automatically

---

## Secrets Used

GitHub Secrets are used to securely store sensitive information:

| Secret Name | Description |
|-------------|-------------|
| `EC2_HOST` | Public IP of the EC2 instance |
| `EC2_SSH_KEY` | Private SSH key for EC2 access |

---

## Real-World Issue Faced & Fix

### Issue: CI/CD Deployment Failed with SSH Timeout

**Error observed in GitHub Actions:**
```
dial tcp <EC2_IP>:22: i/o timeout
```

### Root Cause

- SSH (port 22) was restricted in the EC2 Security Group
- GitHub Actions runners use dynamic IP addresses
- SSH access was allowed only from a local IP

### Fix Applied

Updated EC2 Security Group inbound rules:

```
Type: SSH
Port: 22
Source: 0.0.0.0/0
```

After this change, GitHub Actions was able to connect to EC2 and complete deployment successfully.

**This reflects a real-world cloud networking issue commonly faced in CI/CD pipelines.**

---

## Manual EC2 Bootstrap (One-Time)

For a new EC2 instance, the following setup was done manually once:

```bash
sudo yum update -y
sudo yum install git docker -y
sudo service docker start
sudo usermod -aG docker ec2-user
```

After this, all deployments are fully automated via CI/CD.

---

## Key DevOps Learnings

- Importance of Security Group configuration for CI/CD
- Handling dynamic IPs from GitHub Actions
- Using Git commit hashes for deployment versioning
- Separating one-time infrastructure setup from deployment automation
- Debugging real CI/CD failures in production-like environments

---

## Future Improvements

- Add Nginx reverse proxy
- Enable HTTPS using AWS ACM
- Integrate CloudWatch Logs
- Add blue-green deployment strategy

---

## Author

**Rajendra Guttedar**

- GitHub: [https://github.com/Rajendra0309](https://github.com/Rajendra0309)
- LinkedIn: [https://www.linkedin.com/in/rajendra0309](https://www.linkedin.com/in/rajendra0309)
- Portfolio: [http://rajendraguttedar.in/](http://rajendraguttedar.in/)

---

## Status

- Project successfully deployed
- CI/CD pipeline working
- Real-world DevOps issues identified and resolved

---

## Kubernetes (Local - Minikube)

Local manifests are in [k8s/local/deployment.yaml](k8s/local/deployment.yaml), [k8s/local/service.yaml](k8s/local/service.yaml), and [k8s/local/configmap.yaml](k8s/local/configmap.yaml).

### Steps

```powershell
minikube start
minikube docker-env --shell powershell | Invoke-Expression
docker build -t app-health-tracker:1.0.0 .
kubectl apply -f k8s\local\configmap.yaml
kubectl apply -f k8s\local\deployment.yaml
kubectl apply -f k8s\local\service.yaml
minikube service app-health-tracker --url
```

---

## Terraform (AWS EKS)

Terraform code is in [terraform](terraform) and provisions VPC, subnets, security groups, IAM roles, and EKS.

### Steps

```powershell
cd terraform
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

---

## Kubernetes (Production - AWS EKS)

Production manifests are in [k8s/prod/deployment.yaml](k8s/prod/deployment.yaml), [k8s/prod/service.yaml](k8s/prod/service.yaml), and [k8s/prod/configmap.yaml](k8s/prod/configmap.yaml).

### Steps

```powershell
aws eks update-kubeconfig --name app-health-tracker-eks --region us-east-1
kubectl get nodes

# Build and push to ECR (replace with your account id)
aws ecr create-repository --repository-name app-health-tracker --region us-east-1
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com
docker build -t app-health-tracker:1.0.0 .
docker tag app-health-tracker:1.0.0 <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/app-health-tracker:1.0.0
docker push <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/app-health-tracker:1.0.0

# Update image in prod deployment to your ECR URI, then apply
kubectl apply -f k8s\prod\configmap.yaml
kubectl apply -f k8s\prod\deployment.yaml
kubectl apply -f k8s\prod\service.yaml
kubectl get svc app-health-tracker
```

---

## Cleanup (Avoid Charges)

```powershell
kubectl delete -f k8s\prod\service.yaml
kubectl delete -f k8s\prod\deployment.yaml
kubectl delete -f k8s\prod\configmap.yaml
aws ecr delete-repository --repository-name app-health-tracker --region us-east-1 --force
cd terraform
terraform destroy
```

# Trigger