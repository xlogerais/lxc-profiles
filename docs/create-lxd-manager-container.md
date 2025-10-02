# Create LXD Manager Container

## Install Profile

Install the lxd-host-socket profile :

```bash
lxc profile create lxd-host-socket
curl https://gitea.cloud.logerais.com/cloud.logerais.com/lxd-profiles/raw/branch/main/profiles/containerization/lxd-host-socket.profile.yaml | lxc profile edit lxd-host-socket
```

Or use the local profile:

```bash
./install.bash profiles/containerization/lxd-host-socket.profile.yaml
```

## Launch Container

Create and start an LXD manager container:

```bash
lxc launch ubuntu:lts -p default -p lxd-host-socket lxd-manager
```

### Fix IP Address (Optional)

To assign a static IP address:

```bash
lxc network attach lxdbr0 lxd-manager eth0 eth0
lxc config device set lxd-manager eth0 ipv4.address 10.0.1.20
```

## Use the Container

Access the container and manage host LXD:

```bash
# Wait for cloud-init to complete
lxc exec lxd-manager -- cloud-init status --wait

# Access the container
lxc shell lxd-manager

# Inside the container - verify LXD client is installed
lxc version

# List containers on the host
lxc list

# Create a new container from the manager
lxc launch ubuntu:22.04 test-container

# Manage the new container
lxc info test-container
lxc stop test-container
lxc delete test-container
```

## Security Warning

⚠️ **This container has full access to the host LXD daemon**. Use only in trusted environments and limit access to this management container.

Your LXD manager container is now ready for centralized container management.