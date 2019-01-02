#!/usr/bin/env bash
# This script will remove an active container. It accepts 3 arguments:
#   AGENT - the hostname of the remote server hosting the container
#   CONTAINER_NAME - name of the container to delete

# PREAMBLE ---------------------------------------------------------------------

# the configuration file specifies the global parameters
root_dir=$(dirname "$0")
source $root_dir/lxd.conf

# input validation
if [[ "$#" !=  3 ]]; then
    echo "syntax: script AGENT CONTAINER_NAME"
    echo "e.g. remove_container.sh agent-7 cont_a1"
    exit 1
fi

agent=$1
container=$2

# MAIN -------------------------------------------------------------------------

# get list of all users on the container
awk -F: '$3 >= 1000 {print $1}' /etc/passwd | while IFS=$'\n' read user; do
    # check if this user has login credentials on the jumpbox
    if ssh -q -p 9999 root@localhost [[ -f ~/jumpkeys/$user ]]; then 
        ssh -p 9999 -t root@localhost "userdel -r $user && rm ~/jumpkeys/$user"    
    fi
done

lxc stop $agent:$container
lxc delete $agent:$container
ssh -t $agent "sudo sed -i '/$container/d' /etc/default/$DNS_FILE"
