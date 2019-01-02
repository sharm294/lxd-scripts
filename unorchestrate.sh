#!/usr/bin/env bash
# This script unorchestrates a set of containers. Based on orchestration.conf, 
# containers are removed on the listed agents. It accepts 3 arguments:
#   CONTAINER_BASE - base name of the containers
#   USER_BASE - base name of the users to create
#   INDEX - Index at which to begin numbering containers and users

# PREAMBLE ---------------------------------------------------------------------

# the configuration file specifies the global parameters
root_dir=$(dirname "$0")
source $root_dir/lxd.conf

# input validation
if [[ "$#" != 4 && "$#" != 1 ]]; then 
    echo "Syntax: script CONTAINER_BASE USER_BASE INDEX ORCH_FILE"
    echo "Syntax: script ORCH_FILE (for ORCHESTRATION_MODE = 1)"
    echo "e.g. unorchestrate.sh mpi eskandarin 0 orchestration.conf"
    exit 1
fi

if [[ $# == 4 ]]; then
    container_base=$1
    user_base=$2
    orch_index=$3
    orch_file=$4
else
    orch_file=$1
    orch_index=0
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
    fi
    ./remove_container.sh $agent $container $user
    index=$((index + 1))
done
