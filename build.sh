#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

# Set variables
REPO_URL="https://github.com/Gayathri2103/latesttest.git"
IMAGE_NAME="httpd"
CONTAINER_NAME="new-websrv"
PORT=9090
WORKSPACE="/var/lib/jenkins/workspace/projecttest1"
USE_PODMAN=true  # Set to false to use Docker instead

echo "🔄 Setting up Jenkins workspace..."

# Ensure Jenkins workspace exists
mkdir -p "$WORKSPACE"

# Navigate to Jenkins workspace
cd "$WORKSPACE" || { echo "❌ ERROR: Failed to access Jenkins workspace"; exit 1; }

# Clone or update repository
if [ -d "$WORKSPACE/.git" ]; then
    echo "🔄 Repository exists. Pulling latest changes..."
    git reset --hard origin/master
    git pull origin master
else
    echo "📥 Cloning repository from $REPO_URL"
    git clone "$REPO_URL" "$WORKSPACE" || { echo "❌ ERROR: Failed to clone repository"; exit 1; }
fi

# Check if Dockerfile exists
if [ -f "$WORKSPACE/Dockerfile" ]; then
    DOCKERFILE_PATH="$WORKSPACE/Dockerfile"
elif [ -f "$WORKSPACE/docker/Dockerfile" ]; then
    DOCKERFILE_PATH="$WORKSPACE/docker/Dockerfile"
else
    echo "❌ ERROR: Dockerfile not found in repository!"
    exit 1
fi

# Choose Docker or Podman
if [ "$USE_PODMAN" = true ]; then
    echo "🐳 Building Docker image using Podman..."
    podman build --privileged --security-opt label=disable -f "$DOCKERFILE_PATH" -t "$IMAGE_NAME" "$WORKSPACE" || { echo "❌ ERROR: Podman build failed"; exit 1; }
else
    echo "🐳 Building Docker image using Docker..."
    docker build -f "$DOCKERFILE_PATH" -t "$IMAGE_NAME" "$WORKSPACE" || { echo "❌ ERROR: Docker build failed"; exit 1; }
fi

# Stop and remove any existing container
if docker ps -q --filter "name=$CONTAINER_NAME" | grep -q .; then
    echo "🛑 Stopping existing container: $CONTAINER_NAME"
    docker stop "$CONTAINER_NAME"
    docker rm "$CONTAINER_NAME"
fi

# Run the new container using the selected runtime
if [ "$USE_PODMAN" = true ]; then
    echo "🚀 Running new container with Podman: $CONTAINER_NAME on port $PORT"
    podman run -d -p "$PORT":80 --name "$CONTAINER_NAME" "$IMAGE_NAME" || { echo "❌ ERROR: Podman container failed to start"; exit 1; }
else
    echo "🚀 Running new container with Docker: $CONTAINER_NAME on port $PORT"
    docker run -d -p "$PORT":80 --name "$CONTAINER_NAME" "$IMAGE_NAME" || { echo "❌ ERROR: Docker container failed to start"; exit 1; }
fi

# Display running containers
echo "📋 Listing running containers..."
docker ps || podman ps  # Show containers for both Docker and Podman

