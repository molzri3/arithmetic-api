#!/bin/bash

# Configuration
IMAGE_NAME="arithmetic-api"
CONTAINER_NAME="arithmetic-api-container"
PORT=5000
FILES_TO_WATCH="app.py requirements.txt Dockerfile"

# Function to get file checksums
get_checksums() {
    md5sum $FILES_TO_WATCH 2>/dev/null | sort
}

# Function to build Docker image
build_image() {
    echo "[$(date)] Building Docker image..."
    docker build -t $IMAGE_NAME:latest .
    if [ $? -eq 0 ]; then
        echo "[$(date)] Image built successfully"
        return 0
    else
        echo "[$(date)] Image build failed"
        return 1
    fi
}

# Function to stop and remove existing container
stop_container() {
    if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
        echo "[$(date)] Stopping existing container..."
        docker stop $CONTAINER_NAME
    fi
    if [ "$(docker ps -aq -f name=$CONTAINER_NAME)" ]; then
        echo "[$(date)] Removing existing container..."
        docker rm $CONTAINER_NAME
    fi
}

# Function to deploy container
deploy_container() {
    echo "[$(date)] Deploying container..."
    docker run -d --name $CONTAINER_NAME -p $PORT:5000 $IMAGE_NAME:latest
    if [ $? -eq 0 ]; then
        echo "[$(date)] Container deployed successfully on port $PORT"
        return 0
    else
        echo "[$(date)] Container deployment failed"
        return 1
    fi
}

# Initial build and deployment
echo "[$(date)] Starting initial build and deployment..."
build_image
if [ $? -eq 0 ]; then
    stop_container
    deploy_container
fi

# Store initial checksums
LAST_CHECKSUMS=$(get_checksums)

echo "[$(date)] Starting file monitoring..."
echo "Monitoring files: $FILES_TO_WATCH"

# Main monitoring loop
while true; do
    sleep 5
    
    CURRENT_CHECKSUMS=$(get_checksums)
    
    if [ "$CURRENT_CHECKSUMS" != "$LAST_CHECKSUMS" ]; then
        echo "[$(date)] Changes detected!"
        
        build_image
        if [ $? -eq 0 ]; then
            stop_container
            deploy_container
        fi
        
        LAST_CHECKSUMS=$CURRENT_CHECKSUMS
    fi
done
