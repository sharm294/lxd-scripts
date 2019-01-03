#!/usr/bin/env bash
# This script orchestrates a set of containers. Based on orchestration.conf, 
# containers are set up on the listed agents. It accepts 1-2 or 5-6 arguments:
#   CONTAINER_BASE - base name of the containers
#   USER_BASE - base name of the users to create
#   INDEX - Index at which to begin numbering containers and users
#   USER_KEY - Public key of the user
#   ORCH_FILE - path to orchestration.conf
#   SCRIPT - Optional. Path to a script to run after a container has been set up
# If ORCHESTRATION_MODE is set to 1 in lxd.conf, then only the latter two args
# must be provided.

# PREAMBLE ---------------------------------------------------------------------

# the configuration file specifies the global parameters
root_dir=$(dirname "$0")
source $root_dir/lxd.conf

# input validation
if [[ "$#" != 5 && "$#" != 6 && "$#" != 1 && "$#" != 2 ]]; then 
    echo "Syntax: script CONTAINER_BASE USERNAME INDEX USER_KEY ORCH_FILE [SCRIPT]"
    echo "Syntax: script ORCH_FILE [SCRIPT] (for ORCHESTRATION_MODE = 1)"
    echo "e.g. orchestrate.sh mpi eskandarin 0 eskandarin0.pub orchestrate.conf"
    exit 1
fi

if [[ "$#" > 2 ]]; then
    if [[ $ORCHESTRATION_MODE != 0 ]]; then
        echo "Error in number of arguments and value of orchestration mode in orchestrate.sh"
        exit 1
    fi
    container_base=$1
    user_base=$2
    orch_index=$3
    user_key=$4
    orch_file=$5
    if [[ "$#" > 5 ]]; then
        user_script=$6
    else
        user_script=""
    fi
else
    if [[ $ORCHESTRATION_MODE != 1 ]]; then
        echo "Error in number of arguments and value of orchestration mode in orchestrate.sh"
        exit 1
    fi
    orch_file=$1
    if [[ "$#" > 1 ]]; then
        user_script=$2
    else
        user_script=""
    fi
fi

# MAIN -------------------------------------------------------------------------

readarray -t agents < "$orch_file"
index=$orch_index
for row in "${agents[@]}"; do
    row_array=(${row})
    agent=${row_array[0]}
    if [[ $ORCHESTRATION_MODE == 0 ]]; then
        container=${container_base}${index}
        user=${user_base}${index}
    else
        container=${row_array[1]}
        user=${row_array[2]}
        user_key=${row_array[3]}
    fi
    ./create_container.sh $agent $container $user $user_key $user_script
    if [[ $SETUP_SSH == 1 ]]; then
        # do this once the first iteration
        if [[ $index == $orch_index ]]; then
            mkdir ./tmp
            touch ./tmp/keys
            lxc file pull $agent:$container/etc/hosts ./tmp/
            sudo chown -R savi:savi ./tmp/
            echo "" >> ./tmp/hosts
        fi
        lxc file pull $agent:$container/home/$user/.ssh/id_rsa.pub ./tmp/
        cat ./tmp/id_rsa.pub >> ./tmp/keys
        IP=$(lxc info $agent:$container | grep -Eo '10.84.[0-9]{1,3}.[0-9]{1,3}')
        echo "$IP $container" >> ./tmp/hosts
        if [[ $ENABLE_ETH3 == 1 ]]; then
            IP_BASE=$((ETH3_IP+index))
            echo "$ETH3_IP_SUBNET.$IP_BASE ${container}_eth3" >> ./tmp/hosts
        fi
    fi
    index=$((index + 1))
done

if [[ $SETUP_SSH == 1 ]]; then
    index=$orch_index
    for row in "${agents[@]}"; do
        row_array=(${row})
        agent=${row_array[0]}
        if [[ $ORCHESTRATION_MODE == 0 ]]; then
            container=${container_base}${index}
            user=${user_base}${index}
        else
            container=${row_array[1]}
            user=${row_array[2]}
        fi
        lxc file pull $agent:$container/home/$user/.ssh/authorized_keys ./tmp/
        cat ./tmp/keys >> ./tmp/authorized_keys
        lxc file push ./tmp/authorized_keys $agent:$container/home/$user/.ssh/
        #lxc exec $agent:$container -- chown -R $user:$user /home/$user/.ssh
        lxc file push ./tmp/hosts $agent:$container/etc/
        lxc exec $agent:$container -- chown root:root /etc/hosts
        index=$((index + 1))
    done

    rm -r ./tmp

    index=$orch_index
    for row in "${agents[@]}"; do
        row_array=(${row})
        agent=${row_array[0]}
        if [[ $ORCHESTRATION_MODE == 0 ]]; then
            container=${container_base}${index}
            user=${user_base}${index}
        else
            container=${row_array[1]}
            user=${row_array[2]}
        fi
        index2=$orch_index
        for row2 in "${agents[@]}"; do
            row_array2=(${row2})
            agent2=${row_array2[0]}
            if [[ $ORCHESTRATION_MODE == 0 ]]; then
                container2=${container_base}${index}
            else
                container2=${row_array[1]}
            fi
            if [[ $container != $container2 ]]; then
                lxc exec $agent:$container -- su $user -c "ssh-keyscan -H $container2 >> ~/.ssh/known_hosts"
                lxc exec $agent:$container -- su $user -c "ssh-keyscan -H ${container2}_eth3 >> ~/.ssh/known_hosts"
            fi
            index2=$((index2 + 1))
        done
        index=$((index + 1))
    done
fi
