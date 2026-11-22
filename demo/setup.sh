# shellcheck shell=bash
# Hidden preamble of the demos (autocast), sourced from the repository root:
# mise activated, delta as git pager, demo profile absent from LXD.
eval "$(mise activate bash)"
export GIT_PAGER="delta --paging=never"
DEMO_PROFILE=unattended-upgrades
DEMO_FILE=profiles/system/unattended-upgrades.profile.yaml
if lxc profile show "$DEMO_PROFILE" >/dev/null 2>&1; then
  echo "Profile $DEMO_PROFILE is already installed in LXD: the demo would modify it" >&2
  exit 1
fi
# Demo epilogue: restore the repository file as it was before the demo
# (uncommitted changes included) and remove the demo profile
DEMO_BACKUP=$(mktemp)
cp "$DEMO_FILE" "$DEMO_BACKUP"
demo_cleanup() {
  cp "$DEMO_BACKUP" "$DEMO_FILE" && rm -f "$DEMO_BACKUP"
  lxc profile delete "$DEMO_PROFILE" >/dev/null 2>&1 </dev/null
}
