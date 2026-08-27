#!/bin/sh
set -eu

# Named volumes are created as root:root after the image chown layer.
# Repair the SQLite and uploads mounts, then start as node.
mkdir -p /opt/app/.tmp /opt/app/public/uploads

if [ "$(id -u)" = "0" ]; then
  chown -R node:node /opt/app/.tmp /opt/app/public/uploads
  exec su-exec node "$@"
fi

exec "$@"
