# reddit-clone-app Docker Image and AWS ECR image

This repository contains the Dockerfile and instructions to build and push the Docker image for the Reddit Clone App to both Amazon Elastic Container Registry (ECR) and Docker Hub.

## Prerequisites

- Docker installed on your local machine
- AWS CLI installed and configured with permission to access ECR
- AWS account with an ECR repository created or permissions to create one
- Docker Hub account for pushing images
- Docker Hub login credentials

## Build the Docker Image

Clone the repository containing the app source:

```
git clone hhttps://gitlab.com/durrell.gemuh.a-group/end-to-end-gitops.git
cd Livrables/app
```

Build the Docker image locally using the Dockerfile:

```
docker build -t reddit-clone-app:latest .
```

## Tag the Docker Image

Tag the image with your Docker Hub username and repository name:

```
docker tag reddit-clone-app:latest <dockerhub-username>/reddit-clone-app:latest
```

Replace `<dockerhub-username>` with your Docker Hub username.

## Log in to Docker Hub

Authenticate Docker CLI with Docker Hub:

```
docker login
```

Enter your Docker Hub username and password when prompted.

## Push the Image to Docker Hub

Push the tagged image to your Docker Hub repository:

```
docker push <dockerhub-username>/reddit-clone-app:latest
```

## Pull and Run the Image

To run the image from Docker Hub on any machine:

```
docker pull <dockerhub-username>/reddit-clone-app:latest
docker run -d -p 3000:3000 <dockerhub-username>/reddit-clone-app:latest
```

This exposes the application on port 3000.

---

For more detailed information on Docker usage, visit the [Docker official documentation](https://docs.docker.com/).



## Push to Amazon ECR
1. Authenticate Docker to your AWS ECR registry:

# Create ECR repository (if not exists)
aws ecr create-repository --repository-name reddit-clone-app --region us-east-1

# Get login token and login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <aws-account-id>.dkr.ecr.us-east-1.amazonaws.com

2. Tag the Docker image for ECR:

docker tag reddit-clone-app:latest <aws-account-id>.dkr.ecr.<aws-region>.amazonaws.com/reddit-clone-app:latest

3. Push the image to the ECR repository:

docker push <aws-account-id>.dkr.ecr.<aws-region>.amazonaws.com/reddit-clone-app:latest

Replace `<aws-region>` and `<aws-account-id>` with your AWS region and account ID.

## References

- [Amazon ECR Documentation](https://docs.aws.amazon.com/AmazonECR/latest/userguide/what-is-ecr.html)
- [AWS CLI ECR Login](https://docs.aws.amazon.com/cli/latest/reference/ecr/get-login-password.html)
