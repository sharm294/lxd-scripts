#!/bin/bash

#input validation
if [[ "$#" != 4 ]]; then 
    echo "Syntax: script CONTAINER_NAME USERNAME INDEX MOUNT_USER"
    echo "e.g. unorchestrate_mpi_mount.sh mpi eskandarin 2 nariman"
    exit 1
fi

CONTAINER_BASE=$1
USER_BASE=$2
INDEX=$3
MOUNT_USER=$4

readarray -t agents < "orchestrate.conf"
for agent in "${agents[@]}"; do
	CONTAINER=${CONTAINER_BASE}${INDEX}
    USER=${USER_BASE}${INDEX}
    ./applications/mount/unmount.sh $agent $CONTAINER $MOUNT_USER
    INDEX=$((INDEX + 1))
done

./unorchestrate.sh $CONTAINER_BASE $USER_BASE $3
