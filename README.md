# The Architect's Gauntlet: A Global-Scale Creator Platform
This project is the backend for a global-scale creator platform, designed to support features inspired by YouTube, Twitch, and Patreon. It's built from the ground up to handle millions of concurrent users, petabyte-scale media storage, and complex asynchronous workflows, all while adhering to modern cloud-native architectural principles.

This repository is a living document of that process, showcasing production-grade infrastructure, code, and design patterns.

## Core Architectural Principles
This system is built with a specific engineering philosophy. The key principles guiding its construction are:

- Infrastructure as Code (IaC): All cloud infrastructure is defined declaratively using Terraform. There is no manual "click-ops" configuration. This ensures our environment is repeatable, version-controlled, and auditable.

- Principle of Least Privilege: Every component, from IAM roles to security group rules, is granted only the absolute minimum permissions required to perform its function. This minimizes the "blast radius" of any potential security vulnerability.

- Decoupled Control & Data Planes: Services on the control plane (e.g., API Gateway, Lambda) handle lightweight authorization and orchestration. The heavy lifting of the data plane (e.g., video uploads) is offloaded directly to specialized services like AWS S3.

- Serverless First: We prioritize using managed, serverless components (API Gateway, Lambda, S3, Cognito) to reduce operational overhead, improve scalability, and optimize costs.

## Current Status & Features
The platform is currently in Phase 1: The Front Door.

### Implemented Features:

✅ Secure Content Ingestion: A secure API endpoint that provides authenticated users with a time-limited, single-use S3 presigned URL for direct video uploads.

## Architecture Diagram
This diagram shows the flow for the currently implemented Secure Content Ingestion feature.

## Code snippet

sequenceDiagram
    participant Client
    participant API Gateway
    participant Lambda
    participant AWS IAM
    participant AWS S3

    Client->>API Gateway: GET /get-upload-url (with JWT)
    API Gateway->>AWS IAM: Verify JWT
    AWS IAM-->>API Gateway: Token Valid
    API Gateway->>Lambda: Invoke function with user data
    Lambda->>AWS S3: Generate Presigned URL for user's key
    AWS S3-->>Lambda: Return Presigned URL
    Lambda-->>API Gateway: Return URL in response
    API Gateway-->>Client: 200 OK { "uploadURL": "..." }
    Client->>AWS S3: PUT video data to Presigned URL
    AWS S3-->>Client: 200 OK

## Getting Started

### Prerequisites
- Go (v1.21+)
- Terraform (v1.5+)

## AWS CLI

- Deployment
Clone the repository:

```
git clone <your-repo-url>
cd architects-gauntlet
```

- Configure AWS Credentials:
  Ensure your AWS CLI is configured with credentials that have permission to create the necessary resources.

```
aws configure
```

- Deploy the Infrastructure:
  Use Terraform to provision all the necessary cloud resources.

```
terraform init
terraform apply
```

## Features

* **Terraform Configuration:** Defines cloud infrastructure for AWS resources using HCL (HashiCorp Configuration Language).
* **Go Microservice:** A simple `user-service` written in Go, designed to be deployed onto the provisioned infrastructure.
* **PostgreSQL Database:** Provisions a managed PostgreSQL database instance via Terraform.
* **Database Migrations:** Includes SQL migration files (`*.up.sql`) to manage the schema evolution of the `user-service` database.
* **Makefile Automation:** Uses a `Makefile` to simplify common tasks like running Terraform commands (`init`, `plan`, `apply`) .
* **Detailed Documentation:** Extensive running notes and reading notes documenting the learning process are available in the `/docs` directory.

## Technical Deep Dive: Defining Infrastructure with Terraform

Terraform allows infrastructure to be defined declaratively. For example, provisioning a managed PostgreSQL database might look like this (conceptual - replace with actual code if available):

```terraform
# Example from database.tf (Replace with your actual code)

variable "db_password" {
  description = "Password for the RDS database"
  type        = string
  sensitive   = true
}

resource "aws_db_instance" "user_service_db" {
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "14.6"
  instance_class       = "db.t3.micro"
  db_name              = "userservicedb"
  username             = "admin"
  password             = var.db_password
  parameter_group_name = "default.postgres14"
  skip_final_snapshot  = true
  # ... other configuration like VPC, security groups ...
}

output "db_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = aws_db_instance.user_service_db.endpoint
}
```
This code defines the desired state (a specific type of Postgres instance), and Terraform handles the API calls to the cloud provider to create or update it.
