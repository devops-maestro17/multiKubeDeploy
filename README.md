# Multi-Cluster Application Deployment with Argo CD and ApplicationSets

![diagram-export-3-31-2024-11_41_34-AM](https://github.com/devops-maestro17/clusterHub/assets/148553140/ef28d3cb-1078-4d82-ade4-1d5e6fc82bcd)


### This project demonstrates the deployment of an application across multiple Google Kubernetes Engine (GKE) clusters using Argo CD and its ApplicationSets feature.

Argo CD's ApplicationSets feature provides a way to manage multiple Argo CD applications as a single unit. It allows you to define a template for your application and generate multiple instances of that application based on a list of parameters, such as cluster URLs or environment names. ApplicationSets solve the problem of managing multiple instances of an application across different environments or clusters. Instead of creating and maintaining separate Argo CD applications for each instance, you can define a single ApplicationSet that generates and manages all the required instances automatically.

## Overview
The application is a guestbook application which is packaged using Helm charts and is deployed across three environments: development (dev), quality assurance (qa), and production (prod). Each environment has its own dedicated GKE cluster, and the deployment process is managed by Argo CD. The GKE clusters for each environment are provisioned using Terraform within a custom VPC.

## Project Structure

The project is structured in the following way to manage multiple environments using a single Helm chart. The values for respective environment are present in the `values-dev.yaml`, `values-qa.yaml` and `values-prod.yaml`. The `terraform` folder contains the code to create the infrastructure in Google Cloud Platform (GCP). There are separate modules created for the custom VPC and the GKE to ensure that the configuration is flexible. The application set file is present under `helm-charts/application-set` folder.

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


