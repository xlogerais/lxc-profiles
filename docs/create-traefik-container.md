# Create Traefik Container

## Install Profile

Install the traefik profile :

```bash
lxc profile create traefik
curl https://gitea.cloud.logerais.com/cloud.logerais.com/lxd-profiles/raw/branch/main/profiles/applications/traefik.profile.yaml | lxc profile edit traefik
```

Or use the local profile:

```bash
./install.bash profiles/applications/traefik.profile.yaml
```

## Launch Container

Create the container with required profiles:

```bash
# Create the container (without starting)
lxc init ubuntu:lts -p default -p traefik traefik-container

# Or with additional profiles for production use:
# lxc init ubuntu:lts -p default -p zfs -p net-front -p traefik -p traefik-volume-config traefik-container
```

### Fix IP Address (Optional)

To assign a static IP address:

```bash
lxc network attach lxdbr0 traefik-container eth0 eth0
lxc config device set traefik-container eth0 ipv4.address 10.0.3.10
```

## Start and Use the Container

Start the container and verify the setup:

```bash
# Start the container
lxc start traefik-container

# Wait for cloud-init to complete
lxc exec traefik-container -- cloud-init status --wait

# Access the container
lxc shell traefik-container

# Inside the container - Traefik is configured via the profile
# Check if Traefik service is running
systemctl status traefik
```

Your Traefik container is now ready to serve as a reverse proxy. The profile handles the Traefik installation and basic configuration automatically.
