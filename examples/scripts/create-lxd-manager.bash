#!/bin/bash

CONTAINER_NAME="${1:-lxd-manager}"

echo "Creating LXD manager container: $CONTAINER_NAME"

# Install the profile using the helper script
./install.bash profiles/containerization/lxd-host-socket.profile.yaml

# Launch the container
lxc launch ubuntu:lts -p default -p lxd-host-socket "$CONTAINER_NAME"

# Wait for cloud-init
echo "Waiting for cloud-init to complete..."
lxc exec "$CONTAINER_NAME" -- cloud-init status --wait

echo "LXD manager container '$CONTAINER_NAME' is ready!"
echo "Access with: lxc shell $CONTAINER_NAME"
echo "WARNING: This container has full access to host LXD daemon"