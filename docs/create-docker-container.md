# Create Docker Container

## Install Profile

Install the docker profile :

```bash
lxc profile create docker
curl https://gitea.cloud.logerais.com/cloud.logerais.com/lxd-profiles/raw/branch/main/profiles/containerization/docker.profile.yaml | lxc profile edit docker
```

Or use the local profile:

```bash
./install.bash profiles/containerization/docker.profile.yaml
```

## Launch Container

Create and start a Docker container:

```bash
lxc launch ubuntu:lts -p default -p docker docker-container
```

### Fix IP Address (Optional)

To assign a static IP address:

```bash
lxc network attach lxdbr0 docker-container eth0 eth0
lxc config device set docker-container eth0 ipv4.address 10.0.1.10
```

## Use the Container

Access the container and verify Docker installation:

```bash
# Wait for cloud-init to complete
lxc exec docker-container -- cloud-init status --wait

# Access the container
lxc shell docker-container

# Inside the container - verify Docker is running
docker --version
docker run hello-world
```

Your Docker container is now ready for use with Docker already installed and configured.
