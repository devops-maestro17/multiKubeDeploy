# Multi-Cluster Application Deployment with Argo CD and ApplicationSets

![diagram-export-3-31-2024-11_41_34-AM](https://github.com/devops-maestro17/clusterHub/assets/148553140/ef28d3cb-1078-4d82-ade4-1d5e6fc82bcd)


## Overview 
This project aims to automathe the deployment of a guestbook application to multiple Google Kubernetes Engine (GKE) clusters using ApplicationSets in ArgoCD. ArgoCD is utilized to manage multiple clusters via a hub-spoke architecture, where a centralized hub cluster hosts the ArgoCD instance responsible for managing resources across multiple spoke clusters. The Kubernetes manifests of the application are packaged using Helm charts, and the Kubernetes clusters are provisioned using Terraform within a custom Virtual Private Cloud (VPC). The application is deployed across various Kubernetes clusters, including development (dev), quality assurance (qa), and production (prod) environments. The project's structure enables the use of a single Helm chart to deploy the application to multiple environments, each with its own set of values.yaml files. The Terraform folder contains infrastructure code for provisioning resources on Google Cloud Platform (GCP), including modules for creating a custom VPC and configuring GKE, capable of dynamically creating multiple clusters.

## Features
- **Hub-Spoke Architecture**: Utilizes a central hub cluster to manage resources across multiple spoke clusters efficiently.
- **ArgoCD ApplicationSets Integration**: Leverages ArgoCD for continuous delivery and automated deployment of Kubernetes manifests and ApplicationSets for declarative, cluster-level management, allowing for the efficient deployment of applications across multiple clusters.
- **Dynamic Cluster Creation using Terraform**: Infrastructure as Code (IaC) approach using Terraform to provision multiple GKE clusters within a custom VPC.
- **Multi-Environment Deployment using Helm Charts**: Packages Kubernetes manifests of the application into Helm charts for easy management and deployment across multiple environments (dev, qa, prod) using separate values.yaml files for each environment.

## Project Structure

The project is structured in the following way to manage multiple environments using a single Helm chart. The values for respective environment are present in the `values-dev.yaml`, `values-qa.yaml` and `values-prod.yaml`. The Terraform configuration, located within the `terraform` folder, provisions the infrastructure on GCP. It includes modules for creating the custom VPC and configuring GKE clusters. Notably, the Terraform setup is designed to dynamically create multiple clusters, ensuring scalability and flexibility. The application set file is present under `helm-charts/application-set` folder.

```bash

├── helm-charts
│   ├── Chart.yaml
│   ├── application-set
│   │   └── appset.yml
│   ├── argo-app.yml
│   ├── charts
│   ├── templates
│   │   ├── _helpers.tpl
│   │   ├── deploy.yaml
│   │   ├── hpa.yaml
│   │   └── service.yaml
│   ├── values-dev.yaml
│   ├── values-prod.yaml
│   └── values-qa.yaml
└── terraform
    ├── main.tf
    ├── modules
    │   ├── gke
    │   │   ├── main.tf
    │   │   └── variables.tf
    │   └── vpc
    │       ├── main.tf
    │       ├── outputs.tf
    │       └── variables.tf
    ├── terraform.tfvars
    └── variables.tf

```

## Getting Started
To deploy the application to multiple GKE clusters using ArgoCD, follow these steps:

### Configuring GCP project and activating Cloud Shell

 Create an account in Google Cloud Platform to make use of the free credits it offers for creation of multiple Kubernetes clusters. Go to the Cloud Shell and configure the project using the below command:
 
 ```bash
 gcloud config set project [PROJECT_ID]
 ```

### Verify the installation of required tools

 By default, Cloud Shell comes with Terraform and kubectl installed so there is no need of installing them. To verify whether terraform is installed, use:

 ```bash
 terraform --version
 ```

### Clone the repository

Use the command `git clone https://github.com/devops-maestro17/clusterHub.git` to clone the repository

### Setting up the infrastructure

Before setting up the infrastructure make sure that the Kubernetes Engine API is enabled. Visit this URL to enable the API: https://console.cloud.google.com/apis/library/container.googleapis.com

Navigate to the `terraform/environments` directory and configure environment-specific variables in the respective `.tfvars` file such as the project ID, VPC region, VPC name and the cluster names

Run the below Terraform commands to provision the custom VPC and the GKE clusters:

```bash
terraform init
terraform plan
terraform apply
# Enter "yes" after reviewing the plan
```

### Connect to the Hub cluster and set up ArgoCD

Once the clusters are provisioned, connect to the hub cluster using the following command:

```bash
gcloud container clusters get-credentials <hub cluster name> --zone <zone name> --project <project ID>
```

To install ArgoCD, run the following commands:

```bash
# Install ArgoCD and ArgoCD CLI
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Install ArgoCD CLI
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64
```

Verify the installation by running `kubectl get all -n argocd`
Once the Services are up and running, use the below command to expose the **argocd-server** in order to access the ArgoCD UI

```bash
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```

Use `kubectl get svc -n argocd` command to fetch the LoadBalancer IP address which is present under the *External IP* section

## Access the ArgoCD UI
Hit the LoadBalancer IP in a new tab to access the ArgoCD dashboard. To get the password follow the below steps:

```bash
kubectl edit secret argocd-initial-admin-secret -n argocd
```
Fetch the value from `data.password` and decode it using below command:

```bash
echo <password> | base64 --decode
```
Use the decoded value as the password and login to the ArgoCD dashboad using *Username: admin*

## Login to the ArgoCD CLI and add the kubernetes clusters
Run the following command to login to the ArgoCD CLI:

```bash
argocd login <external ip address of the argocd-server>
# Provide username: admin and the password to login
```

In order to connect the spoke clusters (*dev, qa* and *prod* clusters) to the hub cluster, run the following commands:

```bash
# Connect the clusters to the Cloud shell
gcloud container clusters get-credentials <dev cluster name> --zone <zone of dev cluster> --project <project id>
gcloud container clusters get-credentials <qa cluster name> --zone <zone of qa cluster> --project <project id>
gcloud container clusters get-credentials <prod cluster name> --zone <zone of prod cluster> --project <project id>

# Get the context of the clusters
kubectl config get-contexts

# Add the clusters to ArgoCD
argocd cluster add <paste the dev cluster context>
argocd cluster add <paste the qa cluster context>
argocd cluster add <paste the prod cluster context>
```

In order to verify whether the clusters are added, navigate to ArgoCD Settings > Clusters

<img width="960" alt="image" src="https://github.com/devops-maestro17/clusterHub/assets/148553140/de686dae-3163-4d6d-82f5-9ef4d53602e9">

## COnfigure the URLs in the ApplicationSet file


