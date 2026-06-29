End-to-End CI/CD Pipeline

![CI/CD Pipeline](https://img.shields.io/badge/CI%2FCD-Jenkins-red?style=for-the-badge&logo=jenkins)
![Kubernetes](https://img.shields.io/badge/Kubernetes-EKS-blue?style=for-the-badge&logo=kubernetes)
![Terraform](https://img.shields.io/badge/IaC-Terraform-purple?style=for-the-badge&logo=terraform)
![Docker](https://img.shields.io/badge/Container-Docker-blue?style=for-the-badge&logo=docker)
![AWS](https://img.shields.io/badge/Cloud-AWS-orange?style=for-the-badge&logo=amazonaws)
![SonarCloud](https://img.shields.io/badge/Code%20Quality-SonarCloud-orange?style=for-the-badge&logo=sonarcloud)
![JFrog](https://img.shields.io/badge/Artifacts-JFrog-green?style=for-the-badge&logo=jfrog)
![Grafana](https://img.shields.io/badge/Monitoring-Grafana-orange?style=for-the-badge&logo=grafana)

---

## Project Overview

This project demonstrates the design and implementation of a **complete production-grade CI/CD pipeline** using industry-standard DevOps tools. A Spring Boot Java application is automatically built, tested, analyzed, containerized, and deployed to AWS EKS Kubernetes cluster — all triggered by a single `git push`.

### Application
A Spring Boot REST API (Java 8) that serves as the target application for the entire pipeline.

---

## Architecture

```
Developer
    │
    │  git push
    ▼
┌─────────────┐
│   GitHub    │ ──── Webhook ────►  Jenkins Master
│    Repo     │                          │
└─────────────┘                          │ delegates to
                                         ▼
                                  Jenkins Agent (Maven)
                                         │
                    ┌────────────────────┼────────────────────┐
                    │                    │                    │
                    ▼                    ▼                    ▼
              Build & Test         SonarCloud           JFrog Artifactory
              (Maven 3.9)        Code Analysis         JAR + Docker Image
                                                              │
                                                             ▼
                                                      AWS EKS Cluster
                                                      (Kubernetes 1.35)
                                                             │
                                                    ┌────────┴────────┐
                                                    │   Spring Boot   │
                                                    │   Application   │
                                                    │  (LoadBalancer) │
                                                    └────────┬────────┘
                                                             │
                                                    ┌────────┴────────┐
                                                    │   Monitoring    │
                                                    │  Prometheus +   │
                                                    │    Grafana      │
                                                    └─────────────────┘
```

---

## Tools & Technologies

| Category | Tool | Purpose |
|---|---|---|
| **Cloud** | AWS | Cloud infrastructure provider |
| **IaC** | Terraform | Provision VPC, EC2, EKS infrastructure |
| **Config Management** | Ansible | Install and configure Jenkins, Maven, Docker |
| **Source Control** | GitHub | Code repository and webhook triggers |
| **CI/CD** | Jenkins | Automated build and deployment pipeline |
| **Code Quality** | SonarCloud | Static code analysis and quality gates |
| **Artifact Registry** | JFrog Artifactory | Store JAR files and Docker images |
| **Containerization** | Docker | Build and run application containers |
| **Orchestration** | AWS EKS | Managed Kubernetes cluster |
| **Package Manager** | Helm | Deploy Prometheus and Grafana |
| **Monitoring** | Prometheus | Collect cluster and app metrics |
| **Visualization** | Grafana | Display metrics dashboards |

---

## Repository Structure

```
end-to-end-cicd-pipeline/
│
├── Jenkinsfile                  # Complete CI/CD pipeline definition
├── Dockerfile                   # Container image definition
├── pom.xml                      # Maven build configuration
├── sonar-project.properties     # SonarCloud configuration
│
├── k8s/                         # Kubernetes manifests
│   ├── deployment.yaml             # App deployment (1 replica)
│   └── service.yaml                # LoadBalancer service (port 80→8000)
│
└── src/                         # Spring Boot application source code
    └── main/java/com/satish/demo/
```

```
devops-project06-infra/
│
├── jenkins-infra/               # Jenkins infrastructure Terraform
│   ├── provider.tf
│   ├── variables.tf
│   ├── vpc.tf                      # VPC, Subnet, Internet Gateway
│   ├── security-group.tf           # Firewall rules
│   ├── ec2-instances.tf            # Jenkins Master + Agent EC2s
│   └── outputs.tf
│
├── eks-infra/                   # EKS cluster Terraform
│   ├── provider.tf
│   ├── variables.tf
│   ├── eks-cluster.tf              # EKS cluster + node group + IAM roles
│   └── outputs.tf
│
└── ansible/                     # Ansible playbooks
    ├── inventory.ini               # Jenkins Master + Agent hosts
    ├── jenkins-master.yml          # Install Java + Jenkins
    └── jenkins-agent.yml           # Install Java + Maven + Docker
```

---

## Pipeline Stages

```
git push
    │
    ▼
┌─────────────────────────────────────────────────────────────┐
│                    JENKINS PIPELINE                         │
│                                                             │
│  Stage 1: Build                                             │
│  └── mvn clean deploy -Dmaven.test.skip=true                │
│      └── Compiles code, creates JAR in jarstaging/          │
│                                                             │
│  Stage 2: Test                                              │
│  └── mvn surefire-report:report                             │
│      └── Runs JUnit tests, generates coverage report        │
│                                                             │
│  Stage 3: SonarQube Analysis                                │
│  └── sonar-scanner                                          │
│      └── Sends code to SonarCloud for analysis              │
│                                                             │
│  Stage 4: Quality Gate                                      │
│  └── Checks SonarCloud analysis result                      │
│      └── Pipeline stops if quality gate fails               │
│                                                             │
│  Stage 5: Jar Publish                                       │
│  └── curl PUT to JFrog Artifactory                          │
│      └── Uploads JAR to maven-libs-release-local            │
│                                                             │
│  Stage 6: Docker Build                                      │
│  └── docker build -t jfrog.io/repo/demo-workshop:2.1.2     │
│      └── Creates container image from Dockerfile            │
│                                                             │
│  Stage 7: Docker Publish                                    │
│  └── docker push to JFrog Docker registry                   │
│      └── Image stored in nandini-docker-local               │
│                                                             │
│  Stage 8: Deploy to EKS                                     │
│  └── kubectl apply -f k8s/                                  │
│      └── Updates pods on EKS cluster                        │
└─────────────────────────────────────────────────────────────┘
```

---

## Infrastructure Details

### Jenkins Infrastructure (AWS)

| Resource | Specification |
|---|---|
| VPC | 10.0.0.0/16 |
| Subnet | 10.0.1.0/24 (us-east-1a) |
| Jenkins Master | t2.medium, Ubuntu 22.04 |
| Jenkins Agent | t2.medium, Ubuntu 22.04 |
| Jenkins Version | 2.555.3 LTS |
| Java | OpenJDK 11 |
| Maven | 3.9.16 |

### EKS Cluster

| Resource | Specification |
|---|---|
| Cluster Name | demo-workshop-eks |
| Kubernetes Version | 1.35 |
| Node Instance Type | t3.medium |
| Node Count | 1-3 (auto scaling) |
| Region | us-east-1 |
| Subnets | us-east-1a + us-east-1b |

### Application

| Property | Value |
|---|---|
| Framework | Spring Boot 2.x |
| Java Version | 1.8 |
| GroupId | com.satish |
| ArtifactId | demo-workshop |
| Version | 2.1.2 |
| Port | 8000 |

## 🔑 Jenkins Credentials Required

| Credential ID | Type | Purpose |
|---|---|---|
| `github-cred` | Username + Password | GitHub PAT for repo access |
| `jfrog_cred` | Username + Password | JFrog Artifactory access |
| `sonar-token` | Secret Text | SonarCloud analysis token |
| `jenkins-agent-ssh` | SSH Private Key | Master → Agent connection |


## Monitoring

### Prometheus
- URL: `http://PROMETHEUS_ELB_URL:9090`
- Scrapes metrics from all pods and nodes every 15 seconds

### Grafana
- URL: `http://GRAFANA_ELB_URL`
- Username: `admin`
- Pre-built dashboards:
  - Kubernetes / Cluster
  - Kubernetes / Nodes
  - Kubernetes / Pods
  - Kubernetes / Workloads

---

## AWS Cost Estimate

| Resource | Hourly Cost |
|---|---|
| EKS Control Plane | $0.10/hr |
| t3.medium Node | ~$0.042/hr |
| t2.medium Jenkins Master | ~$0.046/hr |
| t2.medium Jenkins Agent | ~$0.046/hr |
| Load Balancers (3x) | ~$0.025/hr each |
| **Total Estimate** | **~$0.31/hr** |

> Always destroy resources when not in use to avoid charges:
> ```bash
> cd eks-infra && terraform destroy
> cd jenkins-infra && terraform destroy
> ```

---

## Common Issues and Fixes

| Issue | Cause | Fix |
|---|---|---|
| Agent connection refused | Wrong IP after EC2 restart | Update Host field in Jenkins node config with current IP |
| `openjdk:8` not found | Removed from Docker Hub | Use `eclipse-temurin:8-jre` instead |
| `Artifactory` property missing | Old plugin API | Use `curl PUT` to upload to JFrog REST API |
| Quality Gate returns NONE | No SonarCloud webhook | Skip `waitForQualityGate()` on free plan |
| EKS nodes not joining | Subnets not public | Enable `map_public_ip_on_launch` on subnets |
| kubectl credentials error | Different IAM users | Add node IAM user to `aws-auth` ConfigMap |
| App not accessible via ELB | Wrong container port | Check app logs for actual port (was 8000 not 8080) |

---

## 👩‍💻 Author

**Nandini Bansal**

[![GitHub](https://img.shields.io/badge/GitHub-NandiniBansal16-black?style=flat&logo=github)](https://github.com/NandiniBansal16)

## ⭐ Acknowledgements

Project structure inspired by [NotHarshhaa/DevOps-Projects](https://github.com/NotHarshhaa/DevOps-Projects) — DevOps Project 06.
