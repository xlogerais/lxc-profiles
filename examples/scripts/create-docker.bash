#!/bin/bash

CONTAINER_NAME="${1:-docker-container}"

echo "Creating Docker container: $CONTAINER_NAME"

# Install the profile using the helper script
./install.bash profiles/containerization/docker.profile.yaml

# Launch the container
lxc launch ubuntu:lts -p default -p docker "$CONTAINER_NAME"

# Wait for cloud-init
echo "Waiting for cloud-init to complete..."
lxc exec "$CONTAINER_NAME" -- cloud-init status --wait

echo "Docker container '$CONTAINER_NAME' is ready!"
echo "Access with: lxc shell $CONTAINER_NAME"
