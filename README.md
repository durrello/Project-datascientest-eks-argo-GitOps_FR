# Deploying Your Reddit Clone to the Infrastructure locally and via gitlab

# Local Deployment of the infrastructure
## Prerequisites
1. Local environment(vagrant or others)/AWS EC2 instance with Docker installed
2. Docker image of your Reddit clone application [How to build the reddit-clone-app image](src/app/README.md)
3. AWS CLI configured
4. kubectl configured to connect to your EKS cluster

## Get your AWS account ID
```bash
aws sts get-caller-identity --query Account --output text
```
## Step 0: Build the infrastructure
Follow this to build your infrastructure: [Link to infra setup](src/infra/README.md)

## Step 1: Configure kubectl for EKS
```bash
# Update kubeconfig
aws eks update-kubeconfig --region <region> --name <cluster-name>

# Verify connection
kubectl get nodes
```

## Step 3: Access Services | Done in Step 0

### ArgoCD
```bash
# Get ArgoCD admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Port forward to access ArgoCD UI
# Port-forward with HTTPS (secure mode)
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Port-forward with HTTP (insecure mode) - When running Locally
kubectl -n argocd port-forward svc/argocd-server 8080:80

# Access at: https://127.0.0.1:8080
# Username: admin
# Password: (from the command above)
```

### Access Monitoring - Prometheus and Grafana

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

## Step 2: Build and Push Your Image
Follow this to build your image and push to either docker hub or aws elastic container registry: [Link to infra setup](src/app/README.md)

## Integration Workflow

### 1. GitOps with ArgoCD
- Store your Kubernetes [manifests](src/k8s/) in a Git repository
- Configure ArgoCD to monitor your Git repository
- ArgoCD will automatically deploy changes when you push to Git

# Deployment with GitLab CI/CD Pipeline Integration
Here's how to integrate everything:

Using gitlab CICD we have 3 files responsible for building the application image and the infrastructure 

[.gitlab-ci.yml](.gitlab-ci.yml) is responsible for nested child triggers

[.gitlab-ci-app.yml](.gitlab-ci-app.yml) this will trigger a build for image based on the code from src/app directory 

[.gitlab-ci-app.yml](.gitlab-ci-app.yml) this will trigger a create or destroy on the infrastructure.

## Step 0 | Prerequisite 

### Image needed for the infratructure pipeline
Build and push custom image needed for the infrastructure pipeline 
[Here is how to build and push](src/dockerimage/README.md)

### Image needed for the application
Build and push the app image to the registry, ECR or Docker
[Here is how to build and push](src/app/README.md)

## Step 1
Setup environment variables on gitlab for the pipeline to run succesfully

## Step 2
Access the cluster 
```bash
# Update kubeconfig
aws eks update-kubeconfig --region us-east-1 --name my-eks-cluster

# Verify connection
kubectl get nodes
```

## Step 3 access service UI's
Get the Load balancer endpoint for argocd
```bash
kubectl get svc -n argocd
```
Look for the EXTERNAL-IP. This is your ArgoCD dashboard URL.

Expose via LoadBalancer
```bash
kubectl patch svc prometheus-grafana -n monitoring \
  -p '{"spec": {"type": "LoadBalancer"}}'
```
Then:
```bash
kubectl get svc prometheus-grafana -n monitoring
```
Look for the EXTERNAL-IP, then access: http://<EXTERNAL-IP>


## Next Steps
1. **Set up your Git repository structure**:
2. **Configure ArgoCD Application** to point to your Git repository
3. **Set up monitoring dashboards** in Grafana for your application
4. **Configure SonarQube** quality gates for your project
5. **Set up alerting** in Prometheus for application health

## Monitoring Your Application

- **Metrics**: Available in Grafana dashboards
- **Health**: Monitor through Prometheus alerts
- **Code Quality**: Track in SonarQube dashboard

## Scaling Your Application

```bash
# Scale your application
kubectl scale deployment reddit-clone-app --replicas=5

# Set up Horizontal Pod Autoscaler
kubectl autoscale deployment reddit-clone-app --cpu-percent=70 --min=2 --max=10
```