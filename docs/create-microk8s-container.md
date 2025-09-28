# Create MicroK8s Container

## Install Profile

Install the microk8s profile :

```bash
lxc profile create microk8s
curl https://gitea.cloud.logerais.com/cloud.logerais.com/lxd-profiles/raw/branch/main/profiles/containerization/microk8s.profile.yaml | lxc profile edit microk8s
```

Or use the local profile:

```bash
./install.bash profiles/containerization/microk8s.profile.yaml
```

## Launch Container

Import the base image and create the container:

```bash
# Create and start the container
lxc launch ubuntu:lts -p default -p microk8s microk8s-container
```

### Fix IP Address (Optional)

To assign a static IP address:

```bash
lxc network attach lxdbr0 microk8s-container eth0 eth0
lxc config device set microk8s-container eth0 ipv4.address 10.0.2.10
```

## Use the Container

Access the container and verify MicroK8s installation:

```bash
# Wait for cloud-init to complete
lxc exec microk8s-container -- cloud-init status --wait

# Access the container
lxc shell microk8s-container

# Inside the container - MicroK8s is already installed via the profile
microk8s status --wait-ready
microk8s kubectl get nodes
```

Your MicroK8s container is now ready for Kubernetes workloads. The profile handles the MicroK8s installation automatically.
