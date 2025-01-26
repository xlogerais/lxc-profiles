# See (https://documentation.ubuntu.com/lxd/en/stable-5.0/howto/network_bridge_resolved/)

# Alternative : systemd-resolve --interface <network_bridge> --set-domain ~<dns_domain> --set-dns <dns_address>

```
[Unit]
Description=LXD per-link DNS configuration for <network_bridge>
BindsTo=sys-subsystem-net-devices-<network_bridge>.device
After=sys-subsystem-net-devices-<network_bridge>.device

[Service]
Type=oneshot
Environment=BRIDGE_NAME="lxdbr0"
Environment=BRIDGE_ADDR="10.162.242.1"
Environment=BRIDGE_DOMAIN="lxd"
ExecStart=/usr/bin/resolvectl dns lxdbr0 10.162.242.1
ExecStart=/usr/bin/resolvectl domain lxdbr0 '~lxd'
ExecStopPost=/usr/bin/resolvectl revert lxdbr0
RemainAfterExit=yes

[Install]
WantedBy=sys-subsystem-net-devices-<network_bridge>.device

```
