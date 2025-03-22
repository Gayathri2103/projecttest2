#!/bin/bash

# Set variables
REPO_URL="https://github.com/Gayathri2103/latesttest.git"
IMAGE_NAME="httpd"
CONTAINER_NAME="new-websrv"
PORT=9090
WORKSPACE="/var/lib/jenkins/workspace/projecttest1"

# Navigate to Jenkins workspace
cd "$WORKSPACE" || { echo "❌ ERROR: Failed to access Jenkins workspace"; exit 1; }

# Clone or update the repository
if [ ! -d "$WORKSPACE/.git" ]; then
    echo "📥 Cloning repository from $REPO_URL"
    git clone "$REPO_URL" .
else
    echo "🔄 Pulling latest changes from $REPO_URL"
    git pull origin master  # Change 'master' to 'main' if needed
fi

# Build the Docker image
echo "🐳 Building Docker image: $IMAGE_NAME"
docker build -t "$IMAGE_NAME" . || { echo "❌ ERROR: Docker build failed"; exit 1; }

# Stop and remove any existing container
if docker ps -q --filter "name=$CONTAINER_NAME" | grep -q .; then
    echo "🛑 Stopping existing container: $CONTAINER_NAME"
    docker stop "$CONTAINER_NAME"
    docker rm "$CONTAINER_NAME"
fi

# Run the new Docker container
echo "🚀 Running new container: $CONTAINER_NAME on port $PORT"
docker run -d -p "$PORT":80 --name "$CONTAINER_NAME" "$IMAGE_NAME" || { echo "❌ ERROR: Docker container failed to start"; exit 1; }

# Display running containers
echo "📋 Listing running containers..."
docker ps

