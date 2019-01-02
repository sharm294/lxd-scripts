#!/usr/bin/env bash
# This script will set up for a user on a container.
# The script requires at least 3 arguments:
#   AGENT - the hostname of the remote server hosting the container
#   CONTAINER_NAME - name of the container where the user is
#   USERNAME - name of the user to setup

# PREAMBLE ---------------------------------------------------------------------

if [[ -z $ROOT_PATH ]]; then
	file_dir=$(dirname "$0")
	source $file_dir/../../lxd.conf
fi

agent=$1
container=$2
username=$3

# MAIN -------------------------------------------------------------------------

userHome=/home/$username

lxc exec $agent:$container -- mkdir -p $username/.vnc 
lxc file push $ROOT_PATH/applications/gui/xstartup_xfce $agent:${container}${username}/.vnc/
lxc exec $agent:$container -- chown $3:$3 $username/.vnc
