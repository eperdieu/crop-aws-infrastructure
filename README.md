# C.R.O.P. Cloud Infrastructure and Delivery Pipeline

Conservation & Revenue Opportunity Portal (CROP) is a farmer facing web platform built with the Indiana Soybean Alliance through Purdue's Data Mine corporate partners program. It brings conservation and incentive programs for Indiana corn and soybean farmers into one place, matched to each farmer's profile. Presented at the 2026 Corporate Partners Symposium.

This repo documents my contribution as the DevOps and cloud engineer on a team of 8. The partner's code, data, and credentials are private and are not included here.

## The problem
Indiana corn and soybean farmers face a large, confusing set of incentive programs that take a lot of time to navigate. CROP collects profile information from the farmer (kept private to that farmer), gathers program details through web scraping, uses OpenAI to help match programs to the farmer's profile and location, and shows eligibility, requirements, and financial returns in one interface.

Context: the project reflects the goals of the Indiana State Department of Agriculture and supports the aims of Indiana House Bill 1149 (March 2025) on centralized conservation and incentive programs. Earning farmers' trust with their data was a core design constraint.

## My role
* Built and maintained AWS infrastructure as code with Terraform
* Set up the CI/CD pipeline, including environment promotion, secret management, and tests (unit, linting, and integration)
* Added monitoring and log aggregation, and created backups with
