#!/bin/bash

#input validation
if [[ "$#" != 8 ]]; then 
    echo "Syntax: script CONTAINER_NAME USERNAME INDEX USER_KEY ORCH_FILE MPI_SCRIPT NFS_ADDR NFS_USER"
    echo "e.g. orchestrate_mpi_mount.sh mpi eskandarin 0 eskandarin0.pub '10.10.14.102' /home/savi/cloud/ nariman /opt/cloud/"
    exit 1
fi

CONTAINER_BASE=$1
USER_BASE=$2
INDEX=$3
USER_KEY=$4
NFS_ADDR=$5
NFS_MASTER_PATH=$6
NFS_USER=$7
NFS_SLAVE_PATH=$8

./orchestrate.sh $CONTAINER_BASE $USER_BASE $INDEX $USER_KEY orchestrate.conf applications/mpi.sh

readarray -t agents < "orchestrate.conf"
for agent in "${agents[@]}"; do
	CONTAINER=${CONTAINER_BASE}${INDEX}
    USER=${USER_BASE}${INDEX}
    ./applications/mount/mount.sh $agent $CONTAINER $NFS_ADDR $NFS_MASTER_PATH $NFS_USER $NFS_SLAVE_PATH
    INDEX=$((INDEX + 1))
done
