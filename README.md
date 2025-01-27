# lxc-profiles

## Create a traefik instance

### Create container

lxc init ubuntu:lts -p default -p storage-zfs -p net-front -p app-traefik -p volume-letsencrypt traefik

### Fix the ip address

lxc network attach net-front traefik eth0 eth0
lxc config device set traefik eth0 ipv4.address 10.112.16.10

### Start it

lxc start traefik

### Wait for installation

lxc exec traefik -- cloud-init status --wait
lxc exec traefik -- cloud-init status --long

### Connect to it

lxc shell traefik
