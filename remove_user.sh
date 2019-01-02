#!/usr/bin/env bash
# This script will remove a user. Removal can be soft or hard. Soft removal 
# refers to deleting a user's jumpbox credentials but maintains their account on  
# the container. This mode would be used, for example, if the container is also 
# about to be deleted. Hard removal also deletes the user from the container. 
# The script accepts 1 or 3 arguments:
#   AGENT - the hostname of the remote server hosting the container
#   CONTAINER_NAME - name of the container where the user is
#   USERNAME - name of the user to delete
# One argument (just the username) indicates soft removal. Three arguments 
# indicates hard removal.

# PREAMBLE ---------------------------------------------------------------------

# the configuration file specifies the global parameters
root_dir=$(dirname "$0")
source $root_dir/lxd.conf

# input validation
if [[ "$#" !=  3 && "$#" != 1 ]]; then
    echo "syntax: script [AGENT] [CONTAINER_NAME] USERNAME"
    echo "e.g. remove_user.sh agent-7 cont_a1 sharmava0"
    echo "e.g. remove_user.sh sharmava0"
    exit 1
fi

agent=$1
container=$2
username=$3

if lxc info $agent:$container 2>&1 | grep -q 'error'; then
    echo "Container $agent:$container not found"
    exit 1
fi

# MAIN -------------------------------------------------------------------------

if [[ "$#" == 3 ]]; then
    homeDir=$(lxc exec $agent:$container -- awk -F: '$1 == '"\"$username\""' {print $6}' /etc/passwd)
    lxc exec $agent:$container -- userdel -r $username
    lxc exec $agent:$container -- rm -rf $homeDir
fi

ssh -p 9999 -t root@localhost "userdel -r $username && rm ~/jumpkeys/$username"
