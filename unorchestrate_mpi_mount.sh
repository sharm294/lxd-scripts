#!/bin/bash

INDEX=0
CONTAINER_BASE=mpi
USER_BASE=eskandarin

readarray -t agents < "orchestrate.conf"
for agent in "${agents[@]}"; do
	CONTAINER=${CONTAINER_BASE}_${INDEX}
    USER=${USER_BASE}_${INDEX}
    ./applications/mount/unmount.sh $agent $CONTAINER nariman
done

./unorchestrate.sh $CONTAINER_BASE $USER_BASE $INDEX orchestrate.conf
