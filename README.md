# C.R.O.P. Cloud Infrastructure

Cloud infrastructure and delivery pipeline for a data platform built for an agricultural nonprofit partner through Purdue's Data Mine corporate partners program. Presented at the 2026 Corporate Partners Symposium.

This repo documents my contribution. The partner's code, data, and credentials are private and are not included.

## My role
* Built and maintained AWS infrastructure as code with Terraform
* Worked in a team of 8 across three environments
* Helped set up CI/CD with unit tests, linting, and integration tests
* Wrote handoff documentation for the next team

## Architecture
* Containers on AWS ECS Fargate, with images stored in ECR
* RDS for the database
* Secrets Manager for credentials
* Three environments with separate configuration

![Architecture diagram](architecture.png)

## Decisions I worked on
* Moved from EKS to ECS Fargate to reduce operational overhead
* Replaced a NAT Gateway with VPC interface endpoints to lower cost

## Skills shown
AWS, Terraform, Docker, CI/CD, cloud cost optimization, technical documentation

## Notes
This repo contains no keys, state files, account IDs, or partner data.

Connect with me on LinkedIn: https://www.linkedin.com/in/ethan-perdieu-1438271b8
