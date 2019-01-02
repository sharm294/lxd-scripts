#!/usr/bin/env bash

################################################################################
#
# This script, as the name suggests, unmounts the previously mounted directory,
# as well as removing it from the container it was bind-mounted on.
#
# Arguments
#	$1 - the agent the mounted directory is on
#	$2 - the container the directory is bind-mounted on
#	$3 - the mounted directory is assumed to be located at ~/nfs/$3
#
# Todo
#	- Make the mounted directory path more general?
#
################################################################################

#input validation
if [[ "$#" != 3 ]]; then 
    echo "Syntax: script AGENT CONTAINER_NAME USERNAME"
    echo "e.g. unmount.sh agent-7 cont_a1 nariman"
    exit 1
fi

ssh -t $1 "lxc config device remove $2 cloud"
ssh -t $1 "sudo umount -t nfs ~/nfs/$3"
