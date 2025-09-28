#!/bin/bash

CONTAINER_NAME="${1:-traefik-container}"

echo "Creating Traefik container: $CONTAINER_NAME"

# Install the profile using the helper script
./install.bash profiles/applications/traefik.profile.yaml

# Launch the container
lxc launch ubuntu:lts -p default -p traefik "$CONTAINER_NAME"

# Wait for cloud-init
echo "Waiting for cloud-init to complete..."
lxc exec "$CONTAINER_NAME" -- cloud-init status --wait

echo "Traefik container '$CONTAINER_NAME' is ready!"
echo "Access with: lxc shell $CONTAINER_NAME"
