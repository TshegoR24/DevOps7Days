# Day 4  Docker Containerization

## Overview
This folder contains a Dockerized Python app that can run in containers.

## Files
- `Dockerfile`: Multi-stage build for the Python app
- `.dockerignore`: Excludes unnecessary files from the build context
- `requirements.txt`: Python dependencies
- `app.py` & `test_app.py`: The application and tests

## Local Development
```bash
# Build the image
docker build -t sample-app .

# Run tests in container
docker run --rm sample-app

# Run with custom command
docker run --rm sample-app python -c "from app import add; print(add(2,3))"
```

## CI/CD Integration
The GitHub Actions workflow includes a Docker build step that:
- Builds the image on every push/PR
- Runs tests in the container
- Can be extended to push to a registry

## Next Steps
- Push to Docker Hub or GitHub Container Registry
- Add multi-stage builds for production
- Implement health checks
- Add Docker Compose for local development

