#!/usr/bin/bash
# -*- mode: shell-script; fill-column: 80; -*-
#
# Copyright (c) 2013 Joyent Inc., All rights reserved.
#

#set -o xtrace
set -o pipefail

PATH=$PATH:/opt/local/sdc/bin

: ${MANTA_USER:?"MANTA_USER environment variable is missing"}
: ${MANTA_URL:?"MANTA_URL environment variable is missing"}
: ${MANTA_KEY_ID:?"MANTA_KEY_ID environment variable is missing"}

MINECRAFT_LOCATION="/opt/minecraft/server"
MANTA_PREFIX="/$MANTA_USER/public/minecraft"
SERVER_NAME=$(mdata-get sdc:tags.minecraft)
MANTA_LOCATION="$MANTA_PREFIX/$SERVER_NAME"
REMOTE_FILE="$MANTA_LOCATION/server/world.tar.gz"
MAP_BASE="$MANTA_LOCATION/map/view"
SERVER_FLAVOR=${SERVER_PREFERRED:-minecraft}
: ${JAVA_OPTS:=-d64 -Xincgc -Djava.security.egd=/dev/./urandom -XX:-UseVMInterruptibleIO -XX:+UseConcMarkSweepGC -XX:+CMSIncrementalPacing -XX:ParallelGCThreads=4 -XX:+AggressiveOpts}

case ${SERVER_FLAVOR} in
  minecraft*)
    SERVER_JAR="minecraft_server.jar"
  ;;
  craftbukkit*)
    SERVER_JAR="craftbukkit.jar"
  ;;
  ftb-ultimate*)
    SERVER_JAR="ftbserver.jar"
  ;;
  voltz*)
    SERVER_JAR="minecraft_server.jar"
  ;;
  *)
    echo "Undefined Minecraft server flavor!"
    exit 1
  ;;
esac

function fatal {
    echo "$(basename $0): fatal error: $*" >&2
    exit 1
}

function console {
    local CONSOLE_CMD=$1
    sudo -u minecraft tmux send -t minecraft c-m "$CONSOLE_CMD" c-m
    if [[ $? -ne 0 ]]; then
	fatal "Failed to execute $CONSOLE_CMD"
    fi
}
