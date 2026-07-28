# Automated High-Availability AWS Infrastructure with Terraform

This repository contains the Terraform Infrastructure as Code (IaC) configuration for deploying a multi-AZ, highly available, secure, and scalable cloud architecture on AWS.

---

## 📐 Architecture Overview

```text
===================================================================================
                  TERRAFORM HIGH-AVAILABILITY AWS INFRASTRUCTURE
===================================================================================

                    +------------------------------------+
                    |       Terraform Configuration      |
                    |     (Local / CI/CD Pipeline)       |
                    +------------------------------------+
                                      |
                                      v
                    +------------------------------------+
                    |       Terraform Remote State       |
                    |           (AWS S3 Bucket)          |
                    +------------------------------------+
                                      |
                                      v
                     AWS Cloud (Virtual Private Cloud)
+----------------------------------------------------------------------------------+
|                                                                                  |
|                              Internet Gateway (IGW)                              |
|                                        |                                         |
|        +-------------------------------+-------------------------------+         |
|        |                                                               |         |
|        v                                                               v         |
|  [ Availability Zone 1 ]                                 [ Availability Zone 2 ] |
|  +-------------------------------------+                 +---------------------+ |
|  | PUBLIC SUBNET                       |                 | PUBLIC SUBNET       | |
|  | - Route Table (172.16.x.x)        |                 | - Route Table       | |
|  | - VPC NAT Gateway                   |                 | - VPC NAT Gateway   | |
|  |                                     |                 | - Bastion Host Sec  | |
|  |                                     |                 |   Group (Jump Host) | |
|  +-------------------------------------+                 +---------------------+ |
|                    |                                                |            |
|                    v                                                v            |
|  +-------------------------------------+                 +---------------------+ |
|  | PRIVATE SUBNET                      |                 | PRIVATE SUBNET      | |
|  | - App Server (Amazon EC2)           |                 | - App Server (EC2)  | |
|  | - MySQL DB Instance                 |                 | - Cache Node        | |
|  +-------------------------------------+                 +---------------------+ |
|                                                                                  |
+----------------------------------------------------------------------------------+
```
The infrastructure provisions a multi-tier AWS Virtual Private Cloud (VPC) spanning across **two Availability Zones (AZs)** for high availability and fault tolerance.

### Core Architecture Components:

1. **Remote State Management:**
   - **S3 Bucket:** Secure remote backend for storing Terraform state files (`.tfstate`) with encryption and state locking support.

2. **Networking & VPC Design:**
   - **AWS Virtual Private Cloud (VPC):** Custom CIDR block partitioned into public and private subnets across two AZs (AZ1 and AZ2).
   - **Internet Gateway (IGW):** Enables public subnets to connect to and receive traffic from the internet.
   - **NAT Gateways:** Deployed in both AZ1 and AZ2 public subnets to allow outbound internet access for private subnet resources (for software updates, patches, etc.) while keeping them inaccessible from external inbound traffic.
   - **Route Tables:** Dedicated route tables for managing traffic routing between public subnets, NAT gateways, and private subnets.

3. **Compute & Security:**
   - **Bastion Host / Jump Server:** Provisioned in the AZ2 Public Subnet with strict Security Group rules to allow safe administrative SSH access into private instances.
   - **Amazon EC2 Application Servers:** Workload instances deployed in private subnets across AZ1 and AZ2 for redundancy and load isolation.

4. **Database & Caching Layer:**
   - **MySQL Database Instance:** Managed MySQL DB (RDS) residing in AZ1 Private Subnet, safe from direct public exposure.
   - **Cache Node (ElastiCache):** In-memory caching node deployed in AZ2 Private Subnet to optimize application database read performance and reduce latency.

---

## 📁 Repository Structure

```text
.
├── spring-project/         # Spring Boot application source code
├── templates/              # Script templates
│   └── db-deploy.tmpl      # Database initialization / deployment template
├── .terraform.lock.hcl     # Terraform dependency lock file
├── backend-services.tf     # Database (RDS) & Cache backend infrastructure
├── backend.tf              # Terraform remote backend configuration (S3)
├── bastion-host.tf         # Bastion host provisioning & security configuration
├── bean-app.tf             # AWS Elastic Beanstalk Application definition
├── bean-env.tf             # AWS Elastic Beanstalk Environment configuration
├── iam.tf                  # IAM roles, policies, and instance profiles
├── keypairs.tf             # Key pair resource configurations
├── outputs.tf              # Terraform deployment output definitions
├── providers.tf            # AWS Provider setup & version constraints
├── secgrp.tf               # Security Groups definitions (EC2, RDS, ElastiCache, Bastion)
├── vars.tf                 # Terraform input variables
├── vpc.tf                  # VPC, Subnets, Gateways, and Route Tables setup
├── vprofilekey             # SSH Private Key (Ensure added to .gitignore!)
└── vprofilekey.pub         # SSH Public Key
```

---

## 🛠 Prerequisites

Before deploying this infrastructure, ensure you have the following installed and configured:

1. [Terraform](https://developer.hashicorp.com/terraform/downloads) (>= v1.0.0)
2. [AWS CLI](https://aws.amazon.com/cli/) installed and configured with valid credentials (`aws configure`)
3. An active AWS Account with sufficient privileges to create VPC, EC2, RDS, and ElastiCache resources.
4. An existing S3 bucket created for Terraform remote state backend.

---

## 🚀 Quick Start & Deployment Guide

### Step 1: Clone the Repository
```bash
git clone https://github.com/Neeraj16102004/terraform-aws-project.git
cd terraform-aws-project
```

### Step 2: Configure Environment Variables
Copy the example `terraform.tfvars.example` to `terraform.tfvars` and customize your configuration (e.g., region, subnet CIDRs, key pair names, DB passwords):
```bash
cp terraform.tfvars.example terraform.tfvars
```

### Step 3: Initialize Terraform
Initialize the working directory and configure the S3 remote backend:
```bash
terraform init
```

### Step 4: Validate and Plan
Validate the syntax of your configuration files and check the proposed execution plan:
```bash
terraform validate
terraform plan
```

### Step 5: Apply Configuration
Provision the AWS infrastructure:
```bash
terraform apply
```
*Type `yes` when prompted to confirm deployment.*

---

## 🔒 Security Best Practices Implemented

- **Private Subnet Isolation:** Compute, Database, and Cache resources are placed inside private subnets without public IP exposure.
- **Bastion Host Access:** Admin access to private EC2 instances is strictly routed through a Bastion Host with designated Security Group inbound rules.
- **Least Privilege Access Control:** Security Groups and Network ACLs strictly restrict traffic to required ports only (SSH, MySQL port 3306, Cache port 6379/11211).
- **Remote State Protection:** State stored centrally in S3 with encryption at rest and state locking via DynamoDB.

---

## 🧹 Teardown / Cleanup

To avoid incurring unnecessary AWS charges, destroy all provisioned infrastructure when no longer needed:

```bash
terraform destroy
```
*Type `yes` when prompted to confirm teardown.*

---
