#!/bin/bash

#input validation
if [[ "$#" < 5 && "$#" > 7 ]]; then 
    echo "Syntax: script CONTAINER_NAME USERNAME INDEX USER_KEY ORCH_FILE [SCRIPT] [ORCH_SCRIPT] "
    echo "e.g. orchestrate.sh mpi eskandarin 0 eskandarin0.pub orchestrate.conf"
    exit 1
fi

INDEX=0
CONTAINER_BASE=mpi
USER_BASE=eskandarin

./orchestrate.sh $CONTAINER_BASE $USER_BASE $INDEX eskandari0.pub orchestrate.conf ./applications/mpi/mpi.sh

readarray -t agents < "orchestrate.conf"
for agent in "${agents[@]}"; do
	CONTAINER=${CONTAINER_BASE}_${INDEX}
    USER=${USER_BASE}_${INDEX}
    ./applications/mount.sh $agent $CONTAINER 10.10.14.102 /home/savi/cloud/jacobi/ nariman /home/$USER/cloud/
done
