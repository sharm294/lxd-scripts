#!/usr/bin/env bash
# This script executes a script on a set of containers based on
# orchestration.conf. It accepts 2 or 5 arguments:
#   CONTAINER_BASE - base name of the containers
#   USER_BASE - base name of the users to create
#   INDEX - Index at which to begin numbering containers and users
#   ORCH_FILE - path to orchestration.conf
#   SCRIPT - Path to a script to run
# If ORCHESTRATION_MODE is set to 1 in lxd.conf, then only the latter two args
# must be provided. The called script cannot use variables defined in this 
# script with the exception of $user, which has the username

# PREAMBLE ---------------------------------------------------------------------

# the configuration file specifies the global parameters
root_dir=$(dirname "$0")
source $root_dir/lxd.conf

# input validation
if [[ "$#" != 6 && "$#" != 3 ]]; then 
    echo "Syntax: script CONTAINER_BASE USERNAME INDEX ORCH_FILE SCRIPT MODE"
    echo "Syntax: script ORCH_FILE SCRIPT MODE (for ORCHESTRATION_MODE = 1)"
    echo "e.g. orchestrate.sh mpi eskandarin 0 orchestrate.conf test.sh"
    echo "MODE: 0 - script accepts no args and executes within each container"
    echo "MODE: 1 - script accepts agent, container, and username as args"
    exit 1
fi

if [[ "$#" == 5 ]]; then
    if [[ $ORCHESTRATION_MODE != 0 ]]; then
        echo "Error in number of arguments and value of orchestration mode in execute.sh"
        exit 1
    fi
    container_base=$1
    user_base=$2
    orch_index=$3
    orch_file=$4
    user_script=$5
    mode=$6
else
    if [[ $ORCHESTRATION_MODE != 1 ]]; then
        echo "Error in number of arguments and value of orchestration mode in orchestrate.sh"
        exit 1
    fi
    orch_file=$1
    user_script=$2
    mode=$3
fi

# MAIN -------------------------------------------------------------------------

readarray -t agents < "$orch_file"
readarray -t script < "$user_script"
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
    if [[ $mode == 0 ]]; then
        for comm in "${script[@]}"; do
            comm="${comm//\$user/$user}" # replace all $user with the value of $user
            lxc exec $agent:$container -- $comm
        done
    else
        $script $agent $container $user
    fi
done
