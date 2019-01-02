#!/usr/bin/env bash
# This script undos orchestrate_mpi_mount.sh. First, based on 
# orchestration.conf, a remote NFS directory is unmounted on each container, 
# after which, the containers themselves are unorchestrated. It accepts 4 
# arguments:
#   CONTAINER_BASE - Base name of the created containers (appended with INDEX)
#   USER_BASE - Base name of users (appended with INDEX)
#   INDEX - Index at which to begin numbering containers and users
#   NFS_USER - Username for NFS (drive is mounted at ~/nfs/NFS_USER)

# PREAMBLE ---------------------------------------------------------------------

# the configuration file specifies the global parameters
root_dir=$(dirname "$0")
source $root_dir/lxd.conf

# input validation
if [[ "$#" != 4 ]]; then 
    echo "Syntax: script CONTAINER_BASE USER_BASE INDEX NFS_USER"
    echo "e.g. unorchestrate_mpi_mount.sh mpi eskandarin 2 nariman"
    exit 1
fi

container_base=$1
user_base=$2
index=$3
nfs_user=$4

# MAIN -------------------------------------------------------------------------

readarray -t agents < "orchestrate.conf"
for agent in "${agents[@]}"; do
	container=${container_base}${index}
    ./applications/mount/unmount.sh $agent $container $nfs_user
    index=$((index + 1))
done

# call unorchestrate with the original index argument ($3) instead
./unorchestrate.sh $container_base $user_base $3
