#!/usr/bin/env sh
set -e

# Ensure $TFTPBOOT exists when starting
if [ ! -d "${TFTPBOOT}" ]; then
  mkdir -p -m 0755 "${TFTPBOOT}"
fi

exec "$@"
