# AuthFlow-JenkinsK8s

Enable smooth AWS IAM authentication workflows for Jenkins running inside Kubernetes, securing cloud pipelines.

## Table of Contents

- [Introduction](#introduction)
- [Technologies Used](#technologies-used)
- [Key Features](#key-features)
- [Configuration Management](#configuration-management)
- [Security](#security)
- [Scalability](#scalability)
- [Monitoring and Logging](#monitoring-and-logging)
- [Installation](#installation)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Introduction

AuthFlow-JenkinsK8s is a project designed to enable secure AWS IAM authentication workflows for Jenkins running inside Kubernetes. It aims to secure cloud pipelines by integrating various technologies and tools.

## Technologies Used

- **Kubernetes**: For container orchestration.
- **Helm**: For managing Kubernetes applications.
- **Terraform**: For infrastructure as code.
- **Jenkins**: For continuous integration and continuous delivery (CI/CD).
- **AWS IAM**: For managing access to AWS services and resources securely.

## Key Features

- **AWS IAM Integration**: Secure authentication workflows for Jenkins.
- **Helm Charts**: Used for deploying and managing Kubernetes applications.
- **Terraform Scripts**: Used for provisioning and managing AWS infrastructure.
- **Kubernetes Deployments**: Includes various Kubernetes resources like Deployments, StatefulSets, Services, and Ingress.
- **CI/CD Pipelines**: Automated build, test, and deployment processes using Jenkins.

## Configuration Management

- **Helm Values Files**: Configuration for Helm charts.
- **Terraform Configuration Files**: Infrastructure setup and management.
- **Jenkins Configuration as Code**: Manage Jenkins configuration using code.

## Security

- **IAM Roles and Policies**: Custom IAM policies for managing AWS resources.
- **Network Policies**: Secure communication between Kubernetes pods.
- **Pod Security Contexts**: Secure pod configurations in Kubernetes.

## Scalability

- **Horizontal Pod Autoscaling**: Automatically scale Kubernetes pods based on resource usage.
- **Vertical Pod Autoscaling**: Adjust resource requests and limits for Kubernetes pods.

## Monitoring and Logging

- **Fluent Bit**: For log forwarding and aggregation.
- **Prometheus**: For monitoring and alerting.

## Installation

### Prerequisites

- Kubernetes cluster
- Helm
- Terraform
- AWS CLI

### Steps

1. **Clone the repository**:

   ```sh
   git clone https://github.com/jadonharsh109/AuthFlow-JenkinsK8s
   cd AuthFlow-JenkinsK8s
   ```

2. **Provision Infrastructure**:
   Navigate to the [eks](http://_vscodecontentref_/6) directory and run Terraform scripts:

   ```sh
   cd infra/eks
   terraform init
   terraform apply
   ```

3. **Deploy Helm Charts**:
   Navigate to the [time-management](http://_vscodecontentref_/7) directory and deploy the Helm chart:
   ```sh
   cd helm/time-management
   helm install time-management .
   ```

## Usage

- **Jenkins**: Access Jenkins through the Kubernetes service endpoint.
- **AWS IAM**: Ensure IAM roles and policies are correctly configured for secure access.

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](http://_vscodecontentref_/8) file for details.
