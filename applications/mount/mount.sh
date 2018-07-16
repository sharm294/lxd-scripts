#!/bin/bash

################################################################################
#
# This script, as the name suggests, mounts a directory and adds it to a local
# container as a bind mount. The appropriate packages must already be installed 
# and the directory must already be exported on the master because this script 
# doesn't check that.
#
# Arguments
#	$1 - the agent to mount the directory on
#	$2 - the container to bind mount this directory to
#	$3 - IP address of the NFS master where the master directory is located
#	$4 - the full path of the directory to mount
#	$5 - the directory will be mounted at ~/nfs/$5 on this agent
#	$6 - the full path of the directory where it should be on the container
#
# Todo
#	- Make the mounted directory path more general?
#
################################################################################

#input validation
if [[ "$#" != 6 ]]; then 
    echo "Syntax: script AGENT CONTAINER MASTER_IP MASTER_ADDR USERNAME CONT_ADDR"
    echo "e.g. mount.sh agent-7 cont_a1 10.10.14.102 /home/savi/cloud/ nariman /opt/cloud/"
    exit 1
fi

ssh -t $1 "sudo mount -t nfs $3:$4 ~/nfs/$5"
ssh -t $1 "lxc config device add $2 cloud disk path=$6 source=~/nfs/$5/ optional=true"
