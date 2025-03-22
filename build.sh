#!/bin/bash
set -e

# Variables
REPO_URL="https://github.com/Gayathri2103/projecttest2.git"
IMAGE_NAME="webserver_image"
CONTAINER_NAME="new-websrv"
PORT=9090
WORKSPACE="/var/lib/jenkins/workspace/projecttest2"
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

echo "$TIMESTAMP: 🔄 Setting up Jenkins workspace..."

# Ensure Jenkins workspace exists
mkdir -p "$WORKSPACE"

# Navigate to Jenkins workspace
cd "$WORKSPACE" || { echo "$TIMESTAMP: ❌ ERROR: Failed to access Jenkins workspace"; exit 1; }

# Clone or update repository
if [ -d "$WORKSPACE/.git" ]; then
    echo "$TIMESTAMP: 🔄 Repository exists. Fetching latest changes..."
    git fetch origin
    git reset --hard origin/master
    git pull origin master || { echo "$TIMESTAMP: ❌ ERROR: Failed to pull repository"; exit 1; }
else
    echo "$TIMESTAMP: 📥 Cloning repository from $REPO_URL"
    git clone "$REPO_URL" "$WORKSPACE" || { echo "$TIMESTAMP: ❌ ERROR: Failed to clone repository"; exit 1; }
fi

# Locate the Dockerfile
if [ -f "$WORKSPACE/Dockerfile" ]; then
    DOCKERFILE_PATH="$WORKSPACE/Dockerfile"
elif [ -f "$WORKSPACE/docker/Dockerfile" ]; then
    DOCKERFILE_PATH="$WORKSPACE/docker/Dockerfile"
else
    echo "$TIMESTAMP: ❌ ERROR: Dockerfile not found in repository!"
    exit 1
fi

# Build Docker image
echo "$TIMESTAMP: 🐳 Building Docker image..."
docker build -f "$DOCKERFILE_PATH" -t "$IMAGE_NAME" "$WORKSPACE" || { echo "$TIMESTAMP: ❌ ERROR: Docker build failed"; exit 1; }

# Stop and remove existing container if it exists
if docker ps -a --format "{{.Names}}" | grep -q "^$CONTAINER_NAME$"; then
    echo "$TIMESTAMP: 🛑 Stopping and removing existing container: $CONTAINER_NAME"
    docker stop "$CONTAINER_NAME" || true
    docker rm "$CONTAINER_NAME" || true
fi

# Run the new container
echo "$TIMESTAMP: 🚀 Running new container: $CONTAINER_NAME on port $PORT"
docker run -d -p "$PORT:80" --name "$CONTAINER_NAME" "$IMAGE_NAME"

# Wait for a few seconds to let the container start
sleep 5

# Check if the container is running
if ! docker ps --format "{{Names}}" | grep -q "^$CONTAINER_NAME$"; then
    echo "$TIMESTAMP: ❌ ERROR: Container failed to start!"
    docker logs "$CONTAINER_NAME"
    exit 1
fi

# Display running containers
echo "$TIMESTAMP: 📋 Listing running Docker containers..."
docker ps

# Test if Apache (httpd) is running inside the container
echo "$TIMESTAMP: 🌐 Checking if Apache (httpd) is running inside the container..."
if docker exec "$CONTAINER_NAME" pgrep httpd > /dev/null; then
    echo "$TIMESTAMP: ✅ Apache (httpd) is running successfully inside the container!"
else
    echo "$TIMESTAMP: ❌ ERROR: Apache (httpd) is NOT running inside the container!"
    docker logs "$CONTAINER_NAME"
    exit 1
fi

#Remove old images.
echo "$TIMESTAMP: cleaning up old images"
docker image prune -a -f

