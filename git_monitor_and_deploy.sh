#!/bin/bash

# Configuration
IMAGE_NAME="arithmetic-api"
CONTAINER_NAME="arithmetic-api-container"
PORT=5000
BRANCH="main"  # Change this to your branch name if different

# Function to get the latest commit hash
get_latest_commit() {
    git rev-parse HEAD 2>/dev/null
}

# Function to pull latest changes
pull_changes() {
    echo "[$(date)] Pulling latest changes from Git..."
    git pull origin $BRANCH
    return $?
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

# Check if we're in a Git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: Not a Git repository. Please run this script from your Git project directory."
    exit 1
fi

# Initial build and deployment
echo "[$(date)] Starting initial build and deployment..."
build_image
if [ $? -eq 0 ]; then
    stop_container
    deploy_container
fi

# Store initial commit hash
LAST_COMMIT=$(get_latest_commit)
echo "[$(date)] Current commit: $LAST_COMMIT"

echo "[$(date)] Starting Git repository monitoring..."
echo "Monitoring branch: $BRANCH"

# Main monitoring loop
while true; do
    sleep 10
    
    # Fetch latest commits from remote
    git fetch origin $BRANCH > /dev/null 2>&1
    
    # Get the remote commit hash
    REMOTE_COMMIT=$(git rev-parse origin/$BRANCH 2>/dev/null)
    
    if [ "$REMOTE_COMMIT" != "$LAST_COMMIT" ]; then
        echo "[$(date)] New commit detected on remote!"
        echo "[$(date)] Old commit: $LAST_COMMIT"
        echo "[$(date)] New commit: $REMOTE_COMMIT"
        
        pull_changes
        if [ $? -eq 0 ]; then
            build_image
            if [ $? -eq 0 ]; then
                stop_container
                deploy_container
            fi
        fi
        
        LAST_COMMIT=$(get_latest_commit)
    fi
done
