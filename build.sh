#!/bin/bash
set -e  # Exit on any error

# Set variables
REPO_URL="https://github.com/Gayathri2103/latesttest.git"
IMAGE_NAME="httpd"
CONTAINER_NAME="new-websrv"
PORT=9090
WORKSPACE="/var/lib/jenkins/workspace/projecttest1"

echo "🔄 Setting up Jenkins workspace..."

# Ensure Jenkins workspace exists
mkdir -p "$WORKSPACE"

# Navigate to Jenkins workspace
cd "$WORKSPACE" || { echo "❌ ERROR: Failed to access Jenkins workspace"; exit 1; }

# Clone or update repository
if [ -d "$WORKSPACE/.git" ]; then
    echo "🔄 Repository exists. Pulling latest changes..."
    git fetch origin master
    git reset --hard origin/master
    git pull origin master || { echo "❌ ERROR: Failed to pull repository"; exit 1; }
else
    echo "📥 Cloning repository from $REPO_URL"
    git clone "$REPO_URL" "$WORKSPACE" || { echo "❌ ERROR: Failed to clone repository"; exit 1; }
fi

# Locate the Dockerfile
if [ -f "$WORKSPACE/Dockerfile" ]; then
    DOCKERFILE_PATH="$WORKSPACE/Dockerfile"
elif [ -f "$WORKSPACE/docker/Dockerfile" ]; then
    DOCKERFILE_PATH="$WORKSPACE/docker/Dockerfile"
else
    echo "❌ ERROR: Dockerfile not found in repository!"
    exit 1
fi

# Build Docker image
echo "🐳 Building Docker image..."
docker build -f "$DOCKERFILE_PATH" -t "$IMAGE_NAME" "$WORKSPACE" || { echo "❌ ERROR: Docker build failed"; exit 1; }

# Stop and remove any existing container
if docker ps -a --format "{{.Names}}" | grep -q "^$CONTAINER_NAME$"; then
    echo "🛑 Stopping and removing existing container: $CONTAINER_NAME"
    docker stop "$CONTAINER_NAME" || true
    docker rm "$CONTAINER_NAME" || true
fi

# Run the new container
echo "🚀 Running new container: $CONTAINER_NAME on port $PORT"
docker run -d -p "$PORT":80 --name "$CONTAINER_NAME" "$IMAGE_NAME" || { echo "❌ ERROR: Docker container failed to start"; exit 1; }

# Display running containers
echo "📋 Listing running Docker containers..."
docker ps

