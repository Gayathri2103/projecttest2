#!/bin/bash
set -e  # Exit if any command fails

# Set variables
REPO_URL="https://github.com/Gayathri2103/latesttest.git"
IMAGE_NAME="httpd"
CONTAINER_NAME="new-websrv"
PORT=9090
WORKSPACE="/var/lib/jenkins/workspace/projecttest1"

# Ensure Jenkins workspace exists
mkdir -p "$WORKSPACE"

# Navigate to Jenkins workspace
cd "$WORKSPACE" || { echo "❌ ERROR: Failed to access Jenkins workspace"; exit 1; }

# Check if repository is already cloned
if [ -d "$WORKSPACE/.git" ]; then
    echo "🔄 Repository exists. Pulling latest changes..."
    git reset --hard origin/master
    git pull origin master
else
    echo "📥 Cloning repository from $REPO_URL"
    git clone "$REPO_URL" "$WORKSPACE" || { echo "❌ ERROR: Failed to clone repository"; exit 1; }
fi

# Check if Dockerfile exists (root or inside "docker" folder)
if [ -f "$WORKSPACE/Dockerfile" ]; then
    DOCKERFILE_PATH="$WORKSPACE/Dockerfile"
elif [ -f "$WORKSPACE/docker/Dockerfile" ]; then
    DOCKERFILE_PATH="$WORKSPACE/docker/Dockerfile"
else
    echo "❌ ERROR: Dockerfile not found in repository!"
    exit 1
fi

# Build the Docker image using the detected Dockerfile
echo "🐳 Building Docker image: $IMAGE_NAME using $DOCKERFILE_PATH"
docker build -f "$DOCKERFILE_PATH" -t "$IMAGE_NAME" "$WORKSPACE" || { echo "❌ ERROR: Docker build failed"; exit 1; }

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

