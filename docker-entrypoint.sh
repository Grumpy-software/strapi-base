#!/bin/sh
set -eu

# Named volumes are created as root:root after the image chown layer.
# Repair the SQLite and uploads mounts only when the mount root is not
# already owned by node, then start as node. An unconditional chown -R
# of uploads walks every asset on every restart.
mkdir -p /opt/app/.tmp /opt/app/public/uploads

if [ "$(id -u)" = "0" ]; then
  node_uid="$(id -u node)"

  # One-time root -> node migration. Later boots skip the tree walk.
  repair_owned_by_node() {
    if [ "$(stat -c '%u' "$1")" != "$node_uid" ]; then
      chown -R node:node "$1"
    fi
  }

  repair_owned_by_node /opt/app/.tmp
  repair_owned_by_node /opt/app/public/uploads

  exec su-exec node "$@"
fi

exec "$@"
