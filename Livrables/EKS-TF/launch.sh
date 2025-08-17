#!/bin/bash

#aws eks update-kubeconfig --region us-east-1 --name fall-project-cluster --profile eks_admin_role

export ARGO_PWD=`kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`

echo $ARGO_PWD

#export ARGOCD_SERVER=`kubectl get ingress argocd-server -n argocd -o json | jq --raw-output '.status.loadBalancer.ingress[0].hostname'`

export ARGOCD_SERVER='argocd-fall-project.olivierrey.cloudns.ph'

argocd login $ARGOCD_SERVER --username admin --password $ARGO_PWD --insecure

argocd repo rm git@github.com:CashNowMobile/fall-project-k8s.git

argocd repo add git@github.com:CashNowMobile/fall-project-k8s.git --ssh-private-key-path ~/.ssh/id_rsa_fall-project

argocd app create fall-project --repo git@github.com:CashNowMobile/fall-project-k8s.git --path helm/fall-project --revision main --values values.aws.yaml --dest-server https://kubernetes.default.svc --dest-namespace fall-project --sync-policy automated --self-heal

# TO delete app
#kubectl patch app -n argocd fall-project -p '{"metadata": {"finalizers": null}}' --type merge
#kubectl patch crd -n argocd fall-project -p '{"metadata": {"finalizers": null}}' --type merge
