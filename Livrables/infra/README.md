# AWS EKS Infrastructure with SonarQube

This Terraform configuration creates a complete AWS infrastructure including:
- EKS cluster with ArgoCD, Prometheus, and Grafana
- EC2 instance with SonarQube pre-installed
- VPC with public and private subnets
- All necessary IAM roles and security groups

## Directory Structure

```
.
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
└── modules/
    ├── vpc/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── eks/
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── kubeconfig.tpl
    ├── helm/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── sonarqube/
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        └── sonarqube-install.sh
```

## Prerequisites

1. AWS CLI configured with appropriate permissions
2. Terraform installed (>= 1.0)
3. kubectl installed
4. helm installed
5. An existing EC2 key pair in your AWS region

## Required AWS Permissions

Your AWS user/role needs the following permissions:
- EC2 full access
- EKS full access
- IAM full access
- VPC full access
- Route53 (optional, for DNS)

## Deployment Steps

### 1. Clone and Configure

```bash
# Copy terraform.tfvars.example to terraform.tfvars
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your specific values
vim terraform.tfvars
```

### 2. Initialize and Deploy

```bash
# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply
```

### 3. Configure kubectl

```bash
# Update kubeconfig
aws eks update-kubeconfig --region <your-region> --name <cluster-name>

# Verify cluster access
kubectl get nodes
```

### 4. Access Services

#### ArgoCD
```bash
# Get ArgoCD admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Port forward to access ArgoCD UI
# Port-forward with HTTPS (secure mode)
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Port-forward with HTTP (insecure mode) - When running Locally
kubectl -n argocd port-forward svc/argocd-server 8080:80

# Access at: https://localhost:8080
# Username: admin
# Password: (from the command above)
```

#### Grafana
```bash
# Port forward to access Grafana
kubectl port-forward svc/prometheus-grafana -n monitoring 3000:80

# Access at: http://localhost:3000
# Username: admin
# Password: admin123 (or check values in helm chart)
```

#### Prometheus
```bash
# Port forward to access Prometheus
kubectl port-forward svc/prometheus-kube-prometheus-prometheus -n monitoring 9090:9090

# Access at: http://localhost:9090
```

#### SonarQube
SonarQube will be accessible directly via the public IP:
```
http://<sonarqube-public-ip>:9000
```
Default credentials: admin/admin

## Important Notes

### Security Considerations
1. **Change default passwords** immediately after deployment
2. **Restrict CIDR blocks** in terraform.tfvars for SonarQube access
3. **Use proper SSL certificates** for production deployments
4. **Enable network policies** in Kubernetes for additional security

### Cost Optimization
- The default configuration uses `t3.medium` instances
- Consider using spot instances for development environments
- Monitor EBS volume usage and adjust sizes accordingly

### Monitoring and Logging
- Prometheus will automatically discover and monitor cluster resources
- Grafana comes pre-configured with Prometheus as a data source
- EKS control plane logs are enabled for audit and troubleshooting

## Customization

### Adding More Helm Charts
Add additional charts in `modules/helm/main.tf`:

```hcl
resource "helm_release" "my_app" {
  name       = "my-app"
  repository = "https://charts.example.com"
  chart      = "my-app"
  namespace  = "default"
}
```

### Scaling Node Groups
Modify the `node_groups` variable in terraform.tfvars:

```hcl
node_groups = {
  main = {
    instance_types = ["t3.large"]
    scaling_config = {
      desired_size = 3
      max_size     = 6
      min_size     = 2
    }
    disk_size     = 100
    ami_type      = "AL2_x86_64"
    capacity_type = "SPOT"  # Use spot instances
  }
}
```

## Troubleshooting

### EKS Issues
```bash
# Check cluster status
aws eks describe-cluster --name <cluster-name>

# Check node group status
aws eks describe-nodegroup --cluster-name <cluster-name> --nodegroup-name main
```

### SonarQube Issues
```bash
# Check SonarQube logs
ssh -i <your-key>.pem ubuntu@<sonarqube-ip>
sudo journalctl -u sonarqube -f
```

### Helm Issues
```bash
# List helm releases
helm list --all-namespaces

# Check release status
helm status <release-name> -n <namespace>
```

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

**Warning**: This will delete all resources including data stored in EBS volumes.

## Support

For issues or questions:
1. Check AWS CloudTrail for API errors
2. Review Terraform state for resource status
3. Check application logs in CloudWatch
4. Verify security group and IAM permissions