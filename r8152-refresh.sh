#!/bin/bash

# originally sourced from: https://askubuntu.com/questions/1029250/ubuntu-18-04-ethernet-disconnected-after-suspend
# goes into /lib/systemd/system-sleep/r8152-refresh:

PROGNAME=$(basename "$0")
state=$1
action=$2

function log {
    logger -i -t "$PROGNAME" "$*"
}

log "Running $action $state"

if [[ $state == post ]]; then
    modprobe -r r8152 \
    && log "Removed r8152" \
    && modprobe -i r8152 \
    && log "Inserted r8152"
fi