# shellcheck shell=bash
# Hidden preamble of the Backrest demos (autocast), sourced from the repository root.
#   source demo/backrest/setup.sh install  # only the data to protect: instance "app" and its volume app-data
#   source demo/backrest/setup.sh ui       # backrest instance launched, not configured (screenshots.sh)
#   source demo/backrest/setup.sh restore  # everything ready: backrest configured, one snapshot taken
# demo_cleanup (epilogue) removes what the demo created.
eval "$(mise activate bash)"
source demo/lib.sh
DEMO_PROFILE=app-backrest
DEMO_REPO_PASSWORD=demo-repo-password
DEMO_CREATED=

demo_exists() {
  lxc info backrest >/dev/null 2>&1 || lxc info app >/dev/null 2>&1 \
    || lxc profile show "$DEMO_PROFILE" >/dev/null 2>&1 \
    || lxc storage volume show default backups >/dev/null 2>&1 \
    || lxc storage volume show default app-data >/dev/null 2>&1
}

# The data to protect: an "app" instance writing in its app-data volume
demo_app() {
  lxc storage volume create default app-data size=5GiB >/dev/null
  lxc launch ubuntu:lts app >/dev/null
  lxc storage volume attach default app-data app /srv/app
  lxc exec app -- sh -c 'mkdir -p /srv/app/documents && cp -r /usr/share/doc/bash /usr/share/common-licenses /srv/app/documents/ && echo "Hello from app" > /srv/app/notes.txt'
}

# What the install demo does: the backrest instance with its two volumes
demo_backrest_instance() {
  mise run install --yes "$DEMO_PROFILE" >/dev/null
  lxc storage volume create default backups size=20GiB >/dev/null
  lxc launch ubuntu:lts backrest --profile default --profile "$DEMO_PROFILE" >/dev/null
  lxc config device add backrest backups disk pool=default source=backups path=/backups >/dev/null
  lxc config device add backrest app-data disk pool=default source=app-data path=/backup/app-data readonly=true >/dev/null
  demo_wait_cloud_init backrest
}

# What is done in the web UI: repository and plan, here from a configuration
# file, then one snapshot taken as backrest would
demo_backrest_config() {
  lxc exec backrest -- sh -c "cat > /etc/backrest/config.json" <<JSON
{"version": 6, "instance": "backrest",
 "repos": [{"id": "local", "uri": "/backups/restic", "password": "$DEMO_REPO_PASSWORD", "autoInitialize": true}],
 "plans": [{"id": "app-data", "repo": "local", "paths": ["/backup/app-data"],
            "schedule": {"cron": "0 3 * * *", "clock": "CLOCK_LOCAL"},
            "retention": {"policyTimeBucketed": {"daily": 30, "monthly": 12}}}],
 "auth": {"disabled": true}}
JSON
  lxc exec backrest -- systemctl restart backrest
  until lxc exec backrest -- test -f /backups/restic/config; do sleep 1; done
  lxc exec backrest --env RESTIC_PASSWORD="$DEMO_REPO_PASSWORD" -- restic --repo /backups/restic --quiet \
    backup /backup/app-data --host backrest --tag plan:app-data --tag created-by:backrest >/dev/null
}

if demo_exists && [ "$1" != restore ]; then
  echo "Instance backrest or app, profile $DEMO_PROFILE or volume backups or app-data already exists in LXD: the demo would remove them" >&2
  exit 1
fi
case "$1" in
  install)
    DEMO_CREATED=yes
    demo_app
    ;;
  ui)
    DEMO_CREATED=yes
    demo_app
    demo_backrest_instance
    ;;
  restore)
    if ! demo_exists; then
      DEMO_CREATED=yes
      demo_app
      demo_backrest_instance
      demo_backrest_config
    fi
    demo_instance_shell backrest
    ;;
esac

demo_cleanup() {
  if [ -n "$DEMO_CREATED" ]; then
    lxc delete --force backrest app >/dev/null 2>&1
    lxc storage volume delete default backups >/dev/null 2>&1
    lxc storage volume delete default app-data >/dev/null 2>&1
    lxc profile delete "$DEMO_PROFILE" >/dev/null 2>&1
  fi
}
