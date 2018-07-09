#!/bin/bash

#input validation
if [[ "$#" != 4 ]]; then 
    echo "Syntax: script CONTAINER_NAME USERNAME INDEX ORCH_FILE"
    echo "e.g. orchestrate.sh mpi eskandarin 0 orchestrate.conf"
    exit 1
fi

CONTAINER_BASE=$1
USER_BASE=$2
ORCH_INDEX=$3
ORCH_FILE=$4

readarray -t agents < "$ORCH_FILE"
INDEX=$ORCH_INDEX
for agent in "${agents[@]}"; do
    CONTAINER=${CONTAINER_BASE}_${INDEX}
    USER=${USER_BASE}_${INDEX}
    ./remove_container.sh $agent $CONTAINER $USER
    INDEX=$((INDEX + 1))
done
