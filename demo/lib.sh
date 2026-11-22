# shellcheck shell=bash
# Helpers shared by the hidden preambles of the tutorial demos (demo/*/setup.sh).

# Root shell of an instance, made recordable: its prompt (root@<instance>) ends
# with the marker autocast waits for, and its input is not echoed twice (no
# readline, no tty echo). Only for instances created by the demo.
demo_instance_shell() {
  lxc exec "$1" -- sh -c "cat >> /root/.bashrc" <<RC
PS1='\[\e[1;32m\]root@$1\[\e[0m\]:\w# AUTOCAST_PROMPT'
set +o emacs; stty -echo
RC
}

# Wait for the end of cloud-init in an instance (quietly)
demo_wait_cloud_init() {
  lxc exec "$1" -- cloud-init status --wait >/dev/null
}
