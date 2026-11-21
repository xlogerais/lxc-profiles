# shellcheck shell=bash
# Hidden preamble of the Docker demos (autocast), sourced from the repository root.
#   source demo/docker/setup.sh install  # nothing in LXD, fresh clone in a temporary directory
#   source demo/docker/setup.sh usage    # instance "docker" ready (created if missing)
# demo_cleanup (epilogue) removes what the demo created.
eval "$(mise activate bash)"
DEMO_INSTANCE=docker
DEMO_PROFILE=docker-unprivileged
DEMO_REPO=$PWD
DEMO_CREATED=

# Root shell of the instance, made recordable: its prompt ends with the marker
# autocast waits for, and its input is not echoed twice (no readline, no tty echo)
demo_instance_shell() {
  lxc exec "$DEMO_INSTANCE" -- sh -c "cat >> /root/.bashrc" <<'RC'
PS1='\[\e[1;32m\]root@docker\[\e[0m\]:\w# AUTOCAST_PROMPT'
set +o emacs; stty -echo
RC
}

case "$1" in
  install)
    if lxc info "$DEMO_INSTANCE" >/dev/null 2>&1 || lxc profile show "$DEMO_PROFILE" >/dev/null 2>&1; then
      echo "Instance $DEMO_INSTANCE or profile $DEMO_PROFILE already exists in LXD: the demo would remove them" >&2
      exit 1
    fi
    DEMO_CREATED=yes
    DEMO_TMP=$(mktemp -d)
    cd "$DEMO_TMP" || exit 1
    ;;
  usage)
    if ! lxc info "$DEMO_INSTANCE" >/dev/null 2>&1; then
      DEMO_CREATED=yes
      mise run install --yes "$DEMO_PROFILE" >/dev/null
      lxc launch ubuntu:lts "$DEMO_INSTANCE" --profile default --profile "$DEMO_PROFILE" >/dev/null
      lxc exec "$DEMO_INSTANCE" -- cloud-init status --wait >/dev/null
    fi
    demo_instance_shell
    ;;
esac

demo_cleanup() {
  cd "$DEMO_REPO" || return
  if [ -n "$DEMO_TMP" ]; then
    mise trust --untrust "$DEMO_TMP/lxd-profiles" >/dev/null 2>&1
    rm -rf "$DEMO_TMP"
  fi
  if [ -n "$DEMO_CREATED" ]; then
    lxc delete --force "$DEMO_INSTANCE" >/dev/null 2>&1
    lxc profile delete "$DEMO_PROFILE" >/dev/null 2>&1
  fi
}
