#!/bin/bash

# See https://microk8s.io/docs/install-lxd

lxc profile create microk8s
curl https://raw.githubusercontent.com/ubuntu/microk8s/master/tests/lxc/microk8s.profile | lxc profile edit microk8s

# Import the baseimage
lxc image copy ubuntu:lts local: --auto-update --copy-aliases

# Create an instance
lxc launch -p default -p microk8s ubuntu:lts microk8s

# Fix the ip address
lxc network attach lxdbr0 microk8s eth0 eth0
lxc config device set microk8s eth0 ipv4.address 10.162.242.10

# Install microk8s inside the container
lxc exec microk8s -- sudo snap install microk8s --classic
