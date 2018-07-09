#!/bin/bash

#input validation
if [[ "$#" != 4 ]]; then 
    echo "Syntax: script CONTAINER_NAME USERNAME INDEX"
    echo "e.g. unorchestrate.sh mpi eskandarin 0"
    exit 1
fi

CONTAINER_BASE=$1
USER_BASE=$2
ORCH_INDEX=$3

readarray -t agents < "orchestrate.conf"
INDEX=$ORCH_INDEX
for agent in "${agents[@]}"; do
    CONTAINER=${CONTAINER_BASE}${INDEX}
    USER=${USER_BASE}${INDEX}
    ./remove_container.sh $agent $CONTAINER $USER
    INDEX=$((INDEX + 1))
done
