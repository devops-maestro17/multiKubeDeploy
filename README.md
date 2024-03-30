# Multi-Cluster Application Deployment with Argo CD and ApplicationSets

This project demonstrates the deployment of an application across multiple Google Kubernetes Engine (GKE) clusters using Argo CD and its ApplicationSets feature. The application is packaged using Helm charts, and the Kubernetes clusters are created within a custom VPC using Terraform.

Overview
The application is deployed across three environments: development (dev), quality assurance (qa), and production (prod). Each environment has its own dedicated GKE cluster, and the deployment process is managed by Argo CD, a popular continuous delivery tool for Kubernetes.
