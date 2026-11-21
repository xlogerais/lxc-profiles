#!/usr/bin/env bash
# Screenshots of the Backrest web UI for the tutorial (demo/backrest/*.png), from
# the repository root: a backrest instance as at the end of the install demo, and
# a Debian instance with Chromium driven by Playwright. Everything is removed at
# the end. Prerequisites: LXD, mise, nothing named as in setup.sh, no "browser" instance.
set -euo pipefail
source demo/backrest/setup.sh ui
trap 'lxc delete --force browser >/dev/null 2>&1; demo_cleanup' EXIT

lxc launch images:debian/13 browser >/dev/null
until lxc exec browser -- test -e /run/systemd/resolve/stub-resolv.conf -o -s /etc/resolv.conf; do sleep 1; done
sleep 5
lxc exec browser -- sh -c 'apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -y -qq chromium nodejs npm fonts-dejavu >/dev/null 2>&1'
lxc exec browser -- sh -c 'mkdir -p /pw /shots && cd /pw && npm init -y >/dev/null && npm install --silent playwright-core@1.65.1'
lxc file push demo/backrest/screenshots.mjs browser/pw/screenshots.mjs >/dev/null
until curl --silent --output /dev/null "http://$(lxc list backrest --columns 4 --format csv | grep -o '^[0-9.]*'):9898/"; do sleep 1; done
lxc exec browser -- node /pw/screenshots.mjs "http://$(lxc list backrest --columns 4 --format csv | grep -o '^[0-9.]*'):9898/" /shots
for shot in settings repo plan plan-schedule backup snapshot; do
  lxc file pull "browser/shots/$shot.png" "demo/backrest/$shot.png"
done
