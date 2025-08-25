# Day 5  Push Docker Images to a Registry

## Overview
Automate pushing Docker images from CI to a container registry. Supports Docker Hub and GitHub Container Registry (GHCR).

## Registry Options
- Docker Hub (free tier, widely used)
- GHCR (integrated with GitHub; uses GITHUB_TOKEN)

## GitHub Actions (already configured)
Workflow: `.github/workflows/ci-tests.yml`
- Builds image in `docker_build` job
- Pushes to Docker Hub if `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` are set
- Otherwise pushes to GHCR using `GITHUB_TOKEN`

### Docker Hub Secrets (required for Docker Hub path)
Add in GitHub  Settings  Secrets and variables  Actions:
- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN` (create a Docker Hub access token)

### Image Names
- Docker Hub: `${DOCKERHUB_USERNAME}/sample-app:latest`
- GHCR: `ghcr.io/<org-or-user>/sample-app:latest`

## Local Testing
```bash
# Build
docker build -t sample-app Day4_Docker

# Run tests in the container (default CMD runs pytest)
docker run --rm sample-app
```

## Pull and Run (after CI push)
Docker Hub:
```bash
docker pull <username>/sample-app:latest
docker run --rm <username>/sample-app:latest
```
GHCR:
```bash
docker pull ghcr.io/<owner>/sample-app:latest
docker run --rm ghcr.io/<owner>/sample-app:latest
```

## Troubleshooting
- Auth failures: ensure secrets are set and not blank
- Build failures: check `Day4_Docker/Dockerfile` and context path
- Rate limits: prefer GHCR on public repos

