# Deployment Notes

How we containerized the CROP frontend and backend and prepared them for CI/CD to AWS.

## Overview
1. Define the services with Docker (one Dockerfile per service, plus a Compose file for local runs)
2. Build and test the images locally
3. Use GitHub Actions to build the images and push them to Amazon ECR
4. Run the containers on ECS Fargate

The frontend and backend are two separate images. They need the right ports open so they can talk to each other.

## Local setup (Windows)
1. Install Docker Desktop
2. Update Windows Subsystem for Linux: `wsl --update`
3. Create a Dockerfile inside the frontend folder
4. Run `docker init` to generate a starting point. It defaulted to a production build server, so I changed it to run the Vite dev server instead
5. Expose the Vite dev server port (5173)

Build and run the frontend:

```
docker build -t my-frontend .
docker run -p 5173:5173 my-frontend
```

## What Docker does
* **Packaging:** an image bundles an app and its dependencies into a read only template
* **Containers:** a container is a running instance of an image
* **Isolation:** containers do not interfere with each other or the host
* **Portability:** the same image behaves the same on a laptop, a test server, and production
* **Efficiency:** containers share the host kernel, so they are lighter and start faster than virtual machines

## Backend image
The backend image starts from a Node base image and sets the working directory before installing dependencies and copying the source.

## Secrets
Credentials are never stored in the repo, the Dockerfiles, or the Compose file. In AWS they come from Secrets Manager. Locally they come from an untracked environment file that is listed in `.gitignore`.
