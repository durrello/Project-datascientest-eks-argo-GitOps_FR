# Deploying Your Reddit Clone to the Infrastructure

## Prerequisites
1. Your Terraform infrastructure is deployed and running
2. Docker image of your Reddit clone application
3. kubectl configured to connect to your EKS cluster
4. AWS CLI configured

# Get your AWS account ID
```bash
aws sts get-caller-identity --query Account --output text
```

## Step 1: Configure kubectl for EKS

```bash
# Update kubeconfig
aws eks update-kubeconfig --region us-east-1 --name my-eks-cluster

# Verify connection
kubectl get nodes
```

## Step 2: Build and Push Your Docker Image

```bash
# Build docker image
docker build -t reddit-clone-app .

# Tag your Reddit clone image
docker tag reddit-clone-app:latest <aws-account-id>.dkr.ecr.us-east-1.amazonaws.com/reddit-clone:latest

# Create ECR repository (if not exists)
aws ecr create-repository --repository-name reddit-clone --region us-east-1

# Get login token and login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <aws-account-id>.dkr.ecr.us-east-1.amazonaws.com

# Push the image
docker push <aws-account-id>.dkr.ecr.us-east-1.amazonaws.com/reddit-clone:latest
```

## Step 3: Access ArgoCD

```bash
# Get ArgoCD admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Port forward to access ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Access ArgoCD at https://localhost:8080
# Username: admin
# Password: (from the command above)
```

## Step 4: Access Monitoring

```bash
# Port forward Grafana
kubectl port-forward svc/prometheus-grafana -n monitoring 3000:80

# Get Grafana admin password
kubectl get secret --namespace monitoring prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode

# Access Grafana at http://localhost:3000
# Username: admin
# Password: (from the command above)

# Port forward Prometheus (optional)
kubectl port-forward svc/prometheus-kube-prometheus-prometheus -n monitoring 9090:9090
```

## Step 5: Code Quality with SonarQube

Your SonarQube instance is running at the IP address shown in Terraform outputs:

```bash
# Get SonarQube URL from Terraform outputs
terraform output sonarqube_url

# Default credentials:
# Username: admin
# Password: admin (change on first login)
```

## Integration Workflow

### 1. GitOps with ArgoCD
- Store your Kubernetes manifests in a Git repository
- Configure ArgoCD to monitor your Git repository
- ArgoCD will automatically deploy changes when you push to Git

### 2. CI/CD Pipeline Integration
Here's how to integrate everything:

```yaml
# .github/workflows/ci-cd.yml example
name: CI/CD Pipeline

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  sonar-analysis:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: SonarQube Scan
        uses: sonarqube-quality-gate-action@master
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
          SONAR_HOST_URL: http://YOUR_SONARQUBE_IP:9000

  build-and-deploy:
    needs: sonar-analysis
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      
      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v1
      
      - name: Build and push Docker image
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          ECR_REPOSITORY: reddit-clone
          IMAGE_TAG: ${{ github.sha }}
        run: |
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG .
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
      
      - name: Update Kubernetes manifests
        run: |
          # Update your Kubernetes manifests with new image tag
          sed -i 's|image: .*|image: $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG|' k8s/deployment.yaml
          # Commit and push to trigger ArgoCD deployment
```

## Next Steps

1. **Set up your Git repository structure**:
```
your-reddit-clone/
├── src/                    # Your Node.js application code
├── Dockerfile             # Docker configuration
├── k8s/                   # Kubernetes manifests
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   └── configmap.yaml
├── .github/workflows/     # CI/CD pipelines
└── README.md
```

2. **Configure ArgoCD Application** to point to your Git repository
3. **Set up monitoring dashboards** in Grafana for your application
4. **Configure SonarQube** quality gates for your project
5. **Set up alerting** in Prometheus for application health

## Monitoring Your Application

- **Logs**: `kubectl logs -f deployment/reddit-clone -n default`
- **Metrics**: Available in Grafana dashboards
- **Health**: Monitor through Prometheus alerts
- **Code Quality**: Track in SonarQube dashboard

## Scaling Your Application

```bash
# Scale your application
kubectl scale deployment reddit-clone --replicas=5

# Set up Horizontal Pod Autoscaler
kubectl autoscale deployment reddit-clone --cpu-percent=70 --min=2 --max=10
```