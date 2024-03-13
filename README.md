# lxc-profiles

## Create  traefik instance

### Create container
lxc init ubuntu:lts -p default -p zfs -p front -p traefik -p letsencrypt traefik

### Fix ip address
lxc network attach front traefik eth0 eth0
lxc config device set traefik eth0 ipv4.address 10.112.16.10

### Start it
lxc start traefik

### Check it
lxc exec traefik -- cloud-init status --wait
lxc shell traefik
