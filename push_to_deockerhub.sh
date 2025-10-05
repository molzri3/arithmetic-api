#!/bin/bash

# Configuration
DOCKERHUB_USERNAME="molzri3"  # Change this to your Docker Hub username
IMAGE_NAME="arithmetic-api"
VERSION_TAG="v1.0"

# Build the image
echo "Building Docker image..."
docker build -t $IMAGE_NAME:latest .

if [ $? -ne 0 ]; then
    echo "Error: Docker build failed"
    exit 1
fi

echo "Image built successfully"

# Tag the image with Docker Hub username
echo "Tagging image for Docker Hub..."
docker tag $IMAGE_NAME:latest $DOCKERHUB_USERNAME/$IMAGE_NAME:latest
docker tag $IMAGE_NAME:latest $DOCKERHUB_USERNAME/$IMAGE_NAME:$VERSION_TAG

# Login to Docker Hub
echo "Logging into Docker Hub..."
echo "Please enter your Docker Hub credentials:"
docker login

if [ $? -ne 0 ]; then
    echo "Error: Docker Hub login failed"
    exit 1
fi

# Push the images
echo "Pushing image to Docker Hub..."
docker push $DOCKERHUB_USERNAME/$IMAGE_NAME:latest
docker push $DOCKERHUB_USERNAME/$IMAGE_NAME:$VERSION_TAG

if [ $? -eq 0 ]; then
    echo "Successfully pushed images to Docker Hub!"
    echo "Image: $DOCKERHUB_USERNAME/$IMAGE_NAME:latest"
    echo "Image: $DOCKERHUB_USERNAME/$IMAGE_NAME:$VERSION_TAG"
else
    echo "Error: Failed to push images to Docker Hub"
    exit 1
fi
