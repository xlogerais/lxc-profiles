#!/bin/bash

CONTAINER_NAME="${1:-microk8s-container}"

echo "Creating microk8s container: $CONTAINER_NAME"

# Install the profile using the helper script
./install.bash profiles/containerization/microk8s.profile.yaml

# Launch the container
lxc launch ubuntu:lts -p default -p microk8s "$CONTAINER_NAME"

# Wait for cloud-init
echo "Waiting for cloud-init to complete..."
lxc exec "$CONTAINER_NAME" -- cloud-init status --wait

echo "microk8s container '$CONTAINER_NAME' is ready!"
echo "Access with: lxc shell $CONTAINER_NAME"
