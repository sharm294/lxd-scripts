#!/usr/bin/env bash
# This script orchestrates a set of containers and sets them up for MPI. First,
# based on orchestration.conf, a container is set up on the listed agents with
# MPI. Then, a local directory from one agent is NFS mounted to all the containers
# so they all have access to the same source directory. It accepts 8 arguments:
#   CONTAINER_BASE - Base name of the created containers (appended with INDEX)
#   USER_BASE - Base name of users (appended with INDEX)
#   INDEX - Index at which to begin numbering containers and users
#   USER_KEY - Public key of the user
#   NFS_ADDR - IP address or hostname where the source NFS folder is
#   NFS_MASTER_PATH - Full path on NFS_ADDR where the source NFS folder is
#   NFS_USER - Username on NFS_ADDR (drive is mounted at ~/nfs/NFS_USER)
#   NFS_SLAVE_PATH - Full path where the mounted folder should be placed

# PREAMBLE ---------------------------------------------------------------------

# the configuration file specifies the global parameters
root_dir=$(dirname "$0")
source $root_dir/lxd.conf

# input validation
if [[ "$#" != 8 ]]; then 
    echo "Syntax: script CONTAINER_BASE USER_BASE INDEX USER_KEY NFS_ADDR NFS_MASTER_PATH NFS_USER NFS_SLAVE_PATH"
    echo "e.g. orchestrate_mpi_mount.sh mpi eskandarin 0 eskandarin0.pub '10.10.14.102' /home/savi/cloud/ nariman /opt/cloud/"
    exit 1
fi

container_base=$1
user_base=$2
index=$3
user_key=$4
nfs_addr=$5
nfs_master_path=$6
nfs_user=$7
nfs_slave_path=$8

# MAIN -------------------------------------------------------------------------

./orchestrate.sh $container_base $user_base $index $user_key orchestrate.conf $ROOT_PATH/applications/mpi.sh

readarray -t agents < "orchestrate.conf"
for agent in "${agents[@]}"; do
	container=${container_base}${index}
    USER=${user_base}${index}
    $ROOT_PATH/applications/mount/mount.sh $agent $container $nfs_addr $nfs_master_path $nfs_user $nfs_slave_path
    index=$((index + 1))
done
