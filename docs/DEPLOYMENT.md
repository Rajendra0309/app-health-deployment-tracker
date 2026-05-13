# Deployment Report (README Version)

## Overview
This document captures the end-to-end deployment workflow for the App Health Tracker using Docker, Kubernetes (local and AWS EKS), and Terraform.

## Stack
- App: Node.js + Express
- Container: Docker
- Local K8s: Minikube
- Cloud: AWS EKS + ECR
- IaC: Terraform

---

## Docker (Local)

### Steps
1. Build the Docker image.
2. Run the container locally.
3. Verify the app endpoints.

### Commands
```powershell
docker build -t app-health-tracker:1.0.0 .
docker run -d -p 3000:3000 --name app-health-tracker \
	-e APP_VERSION=1.0.0 \
	-e ENVIRONMENT=local \
	-e DEPLOYED_AT=local \
	app-health-tracker:1.0.0
curl http://localhost:3000/
curl http://localhost:3000/health
```

### Screenshot placeholders
- ![Docker build](screenshots/01-docker-build.png)
- ![Docker run](screenshots/02-docker-run.png)
- ![Docker ps](screenshots/03-docker-ps.png)
- ![Local app response / (terminal)](screenshots/04-docker-root-terminal.png)
- ![Local app response / (web)](screenshots/04-docker-root-webpage.png)
- ![Local app response /health (terminal)](screenshots/05-docker-health-terminal.png)
- ![Local app response /health (web)](screenshots/05-docker-health-webpage.png)

## Local Kubernetes (Minikube)

### Steps
1. Start Minikube and point Docker to Minikube.
2. Build the image locally.
3. Apply the local K8s manifests.
4. Access the service URL.

### Commands
```powershell
minikube start
minikube docker-env --shell powershell | Invoke-Expression
docker build -t app-health-tracker:1.0.0 .
kubectl apply -f k8s\local\configmap.yaml
kubectl apply -f k8s\local\deployment.yaml
kubectl apply -f k8s\local\service.yaml
minikube service app-health-tracker --url
```

### Screenshot placeholders
- ![Minikube status](screenshots/06-minikube-status.png)
- ![Local service URL](screenshots/07-minikube-service-url.png)
- ![Local app response /](screenshots/08-local-root.png)
- ![Local app response /health](screenshots/09-local-health.png)

---

## Terraform (AWS EKS)

### Steps
1. Initialize Terraform.
2. Apply infrastructure (VPC, subnets, IAM, EKS).
3. Capture outputs.

### Commands
```powershell
cd terraform
terraform init
terraform plan -out=tfplan
terraform apply tfplan
terraform output
```

### Screenshot placeholders
- ![Terraform plan](screenshots/10-terraform-plan.png)
- ![Terraform apply complete](screenshots/11-terraform-apply.png)
- ![Terraform outputs](screenshots/12-terraform-output.png)

---

## ECR Image Push

### Steps
1. Build Docker image locally.
2. Create ECR repo.
3. Login to ECR and push image.

### Commands
```powershell
$ACCOUNT = (aws sts get-caller-identity --query Account --output text)
$REGION = "us-east-1"
$REPO = "app-health-tracker"
$TAG = "1.0.0"
$URI = "$ACCOUNT.dkr.ecr.$REGION.amazonaws.com/${REPO}:${TAG}"

docker build -t app-health-tracker:1.0.0 .
aws ecr create-repository --repository-name $REPO --region $REGION
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin "$ACCOUNT.dkr.ecr.$REGION.amazonaws.com"
docker tag app-health-tracker:1.0.0 $URI
docker push $URI
```

### Screenshot placeholders
- ![ECR repository](screenshots/13-ecr-repo.png)
- ![Docker push](screenshots/14-docker-push.png)

---

## Kubernetes (Production - AWS EKS)

### Steps
1. Update kubeconfig to use EKS.
2. Apply prod manifests.
3. Verify rollout and service.

### Commands
```powershell
aws eks update-kubeconfig --name app-health-tracker-eks --region us-east-1
kubectl get nodes

kubectl apply -f k8s\prod\configmap.yaml
kubectl apply -f k8s\prod\deployment.yaml
kubectl apply -f k8s\prod\service.yaml
kubectl rollout status deployment app-health-tracker
kubectl get svc app-health-tracker
```

### Screenshot placeholders
- ![EKS nodes](screenshots/15-eks-nodes.png)
- ![Kubernetes rollout](screenshots/16-eks-rollout.png)
- ![Service external IP](screenshots/17-eks-service.png)
- ![Prod app response /](screenshots/18-eks-root.png)
- ![Prod app response /health](screenshots/19-eks-health.png)

---

## EC2 Docker Deployment (GitHub Actions)

### Steps
1. Push code to main to trigger the workflow.
2. GitHub Actions connects to EC2 via SSH.
3. EC2 pulls the repo, builds the Docker image, and runs the container.
4. Verify the service on the EC2 host.

### Commands (Manual EC2 SSH)
```bash
ssh -i <PATH_TO_EC2_SSH_KEY> ec2-user@<EC2_PUBLIC_IP>

# On EC2
sudo yum update -y
sudo yum install git docker -y
sudo service docker start
sudo usermod -aG docker ec2-user

git clone https://github.com/Rajendra0309/app-health-deployment-tracker.git
cd app-health-deployment-tracker
docker build -t app-health-tracker .
docker run -d --name app-health-tracker -p 3000:3000 \
	-e APP_VERSION=manual \
	-e ENVIRONMENT=production \
	-e DEPLOYED_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ") \
	app-health-tracker
curl http://localhost:3000/health
```

### Screenshot placeholders
- ![GitHub Actions run](screenshots/20-ec2-actions.png)
- ![EC2 container running](screenshots/21-ec2-container.png)
- ![EC2 app response](screenshots/22-ec2-health.png)
- ![EC2 SSH session (1)](screenshots/23-ec2-ssh-1.png)
- ![EC2 SSH session (2)](screenshots/23-ec2-ssh-2.png)
- ![EC2 docker run](screenshots/24-ec2-docker-run.png)
- ![EC2 curl health](screenshots/25-ec2-curl-health.png)

---

## Cleanup (Avoid Charges)

### Commands
```powershell
kubectl delete -f k8s\prod\service.yaml
kubectl delete -f k8s\prod\deployment.yaml
kubectl delete -f k8s\prod\configmap.yaml
aws ecr delete-repository --repository-name app-health-tracker --region us-east-1 --force
cd terraform
terraform destroy
```

### Screenshot placeholders
- ![Terraform destroy](screenshots/26-terraform-destroy.png)

---