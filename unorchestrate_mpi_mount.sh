#!/bin/bash

#input validation
if [[ "$#" < 5 && "$#" > 7 ]]; then 
    echo "Syntax: script CONTAINER_NAME USERNAME INDEX ORCH_FILE"
    echo "e.g. orchestrate.sh mpi eskandarin 0 orchestrate.conf"
    exit 1
fi

INDEX=0
CONTAINER_BASE=mpi
USER_BASE=eskandarin

readarray -t agents < "orchestrate.conf"
for agent in "${agents[@]}"; do
	CONTAINER=${CONTAINER_BASE}_${INDEX}
    USER=${USER_BASE}_${INDEX}
    ./applications/unmount.sh $agent $CONTAINER nariman
done

./orchestrate.sh $CONTAINER_BASE $USER_BASE $INDEX orchestrate.conf
