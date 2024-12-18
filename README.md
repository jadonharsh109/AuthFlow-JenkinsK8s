# **AuthFlow-JenkinsK8s**  
[![Terraform](https://img.shields.io/badge/IaC-Terraform-623CE4?logo=terraform)](https://www.terraform.io/)  
Automating Kubernetes infrastructure with Jenkins CI/CD pipelines, centralized logging, monitoring, and cloud-native integrations using AWS and Terraform.

---

## **Table of Contents**  
- [Project Overview](#project-overview)  
- [Features](#features)  
- [Infrastructure Architecture](#infrastructure-architecture)  
- [Technologies Used](#technologies-used)  
- [Setup Guide](#setup-guide)  
  - [Prerequisites](#prerequisites)  
  - [Installation](#installation)  
- [Modules and Components](#modules-and-components)    
- [Contributing](#contributing)  
- [License](#license)  

---

## **Project Overview**  

**AuthFlow-JenkinsK8s** is a cloud-native infrastructure project designed to:  
- Deploy Jenkins in a Kubernetes cluster for CI/CD workflows.  
- Enable centralized logging and monitoring using Prometheus, Grafana, Elasticsearch, Kibana, and Fluentbit.  
- Leverage AWS Elastic Kubernetes Service (EKS) for scalability and reliability.  
- Automate provisioning using Terraform to ensure consistent, repeatable, and efficient infrastructure management.  

---

## **Features**  

- **Automated Infrastructure**: Provision EKS, IAM roles, namespaces, and storage dynamically using Terraform.  
- **CI/CD with Jenkins**: Fully configured Jenkins deployment with persistent storage and LoadBalancer service.  
- **Observability**: Monitoring with Prometheus and Grafana for Kubernetes cluster metrics and dashboards.  
- **Centralized Logging**: Elasticsearch, Kibana, and Fluentbit integrated for log aggregation and visualization.  
- **Scalable Storage**: AWS EBS CSI driver integration for dynamic persistent volume provisioning.  
- **Secure Role Management**: OIDC-based IAM roles for service accounts, enabling secure access to AWS resources.  

---

## **Infrastructure Architecture**  

### **Architecture Diagram**  

> *(Add an architecture diagram here if available)*  

### **High-Level Overview**  
1. **Compute**: AWS EKS cluster hosting Kubernetes workloads.  
2. **CI/CD**: Jenkins deployed in Kubernetes with persistent storage and LoadBalancer service.  
3. **Logging**: Logs aggregated by Fluentbit, stored in Elasticsearch, and visualized via Kibana.  
4. **Monitoring**: Prometheus collects cluster and application metrics, displayed in Grafana dashboards.  
5. **Storage**: Dynamic volume provisioning using AWS EBS CSI.  

---

## **Technologies Used**  

- **Infrastructure as Code (IaC)**: Terraform  
- **Cloud Provider**: AWS (EKS, IAM, VPC, EC2, EBS, Route 53)  
- **Container Orchestration**: Kubernetes  
- **CI/CD**: Jenkins  
- **Monitoring**: Prometheus, Grafana  
- **Logging**: Elasticsearch, Kibana, Fluentbit  
- **Storage**: AWS EBS (Elastic Block Store)  

---

## **Setup Guide**  

### **Prerequisites**  
- Terraform (>= 1.0)  
- AWS CLI configured with proper access keys  
- Helm (>= 3.0)  
- Kubectl configured for the EKS cluster  
- A valid domain for exposing services  

### **Installation**  

1. **Clone the Repository**:  
   ```bash  
   git clone https://github.com/jadonharsh109/AuthFlow-JenkinsK8s.git  
   cd AuthFlow-JenkinsK8s/infra/eks 
2. **Initialize Terraform**: 
    ```bash
    terraform init
3. **Provision Infrastructure**:  
    ```bash
    terraform apply  
4. **Verify Deployments**:    
    ```bash
    kubectl get all -A
5. **Access Jenkins, Grafana, and Kibana via their LoadBalancer IPs.**

## **Modules and Components**  

### **Namespaces**  
- **jenkins**: For CI/CD workflows.  
- **monitoring**: For Prometheus and Grafana deployments.  
- **logging**: For Elasticsearch, Kibana, and Fluentbit deployments.  

### **Helm Releases**  
- **Jenkins**: Configured with persistent storage and LoadBalancer.  
- **Prometheus & Grafana**: Persistent storage for metrics and monitoring dashboards.  
- **Elasticsearch, Kibana, Fluentbit**: Centralized logging stack for Kubernetes logs.  

### **Storage**  
- **AWS EBS CSI driver**: Dynamic volume provisioning for persistent storage needs.  

### **IAM Roles**  
- **OIDC-based roles**: Scoped permissions for Kubernetes service accounts to securely interact with AWS resources.  

## **Contributing**  

We welcome contributions! If you find bugs, have feature requests, or want to contribute, please follow these steps:  

1. **Fork the repository.**  
2. **Create a new branch:** ``git checkout -b feature-name``
3. **Commit your changes** ``git commit -m "Added feature" ``
4. **Push to your branch**:``
    git push origin feature-name``  
5. **Open a pull request.**

## **License**
This project is licensed under the **MIT License**.

## Contact

For any queries or support, feel free to open an issue or contact me at jadonharsh109.work@gmail.com.



