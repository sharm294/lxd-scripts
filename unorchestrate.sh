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
if [[ "$#" != 3 ]]; then 
    echo "Syntax: script CONTAINER_BASE USER_BASE INDEX"
    echo "e.g. unorchestrate.sh mpi eskandarin 0"
    exit 1
fi

container_base=$1
user_base=$2
orch_index=$3

# MAIN -------------------------------------------------------------------------

readarray -t agents < "orchestrate.conf"
index=$orch_index
for agent in "${agents[@]}"; do
    container=${container_base}${index}
    user=${user_base}${index}
    ./remove_container.sh $agent $container $user
    index=$((index + 1))
done
