#!/bin/bash

source lxd.conf

#input validation
if [[ "$#" < 5 && "$#" > 7 ]]; then 
    echo "Syntax: script CONTAINER_NAME USERNAME INDEX USER_KEY ORCH_FILE [SCRIPT] [ORCH_SCRIPT]"
    echo "e.g. orchestrate.sh mpi eskandarin 0 eskandarin0.pub orchestrate.conf"
    exit 1
fi

CONTAINER_BASE=$1
USER_BASE=$2
ORCH_INDEX=$3
KEY=$4
ORCH_FILE=$5
if [[ "$# > 5" ]]; then
    USER_SCRIPT=$6
else
    USER_SCRIPT=""
fi
if [[ "$# > 6" ]]; then
    ORCH_SCRIPT=$7
else
    ORCH_SCRIPT=""
fi

readarray -t agents < "$ORCH_FILE"
INDEX=$ORCH_INDEX
for agent in "${agents[@]}"; do
    CONTAINER=${CONTAINER_BASE}_${INDEX}
    USER=${USER_BASE}_${INDEX}
    ./create_container.sh $agent $CONTAINER $USER $KEY $USER_SCRIPT
    if [[ $INDEX == $ORCH_INDEX ]]; then
        mkdir ./tmp
        touch ./tmp/keys
        lxc file pull $agent:$CONTAINER/etc/hosts ./tmp/
        sudo chown -R savi:savi ./tmp/
        echo "" >> ./tmp/hosts
    fi
    lxc file pull $agent:$CONTAINER/home/$USER/.ssh/id_rsa.pub ./tmp/
    cat ./tmp/id_rsa.pub >> ./tmp/keys
    IP=$(lxc info $agent:$CONTAINER | grep -Eo '10.84.[0-9]{1,3}.[0-9]{1,3}')
    echo "$IP $CONTAINER" >> ./tmp/hosts
    INDEX=$((INDEX + 1))
done

INDEX=$ORCH_INDEX
for agent in "${agents[@]}"; do
    CONTAINER=${CONTAINER_BASE}_${INDEX}
    USER=${USER_BASE}_${INDEX}
    lxc file pull $agent:$CONTAINER/home/$USER/.ssh/authorized_keys ./tmp/
    cat ./tmp/keys >> ./tmp/authorized_keys
    lxc file push ./tmp/authorized_keys $agent:$CONTAINER/home/$USER/.ssh/
    #lxc exec $agent:$CONTAINER -- chown -R $USER:$USER /home/$USER/.ssh
    lxc file push ./tmp/hosts $agent:$CONTAINER/etc/
	lxc exec $agent:$CONTAINER -- chown root:root /etc/hosts
	INDEX=$((INDEX + 1))
done

INDEX=$ORCH_INDEX
INDEX2=$ORCH_INDEX
for agent in "${agents[@]}"; do
    CONTAINER=${CONTAINER_BASE}_${INDEX}
    USER=${USER_BASE}_${INDEX}
    for agent2 in "${agents[@]}"; do
    	if [[ $INDEX != $INDEX2 ]]; then
			CONTAINER2=${CONTAINER_BASE}_${INDEX2}
			lxc exec $agent:$CONTAINER -- su $USER -c "ssh-keyscan -H $CONTAINER2 >> ~/.ssh/known_hosts"
		fi
	    INDEX2=$((INDEX2 + 1))
	done
    INDEX=$((INDEX + 1))
done
