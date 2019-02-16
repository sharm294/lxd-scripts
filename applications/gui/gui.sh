#!/usr/bin/env bash
# This script will set up VNC for a container and a user. 
# The script requires at least 3 arguments:
#   AGENT - the hostname of the remote server hosting the container
#   CONTAINER_NAME - name of the container where the user is
#   USERNAME - name of the user to setup
#	RUN_USER - run the gui_user.sh script afterwards

# PREAMBLE ---------------------------------------------------------------------

if [[ -z $ROOT_PATH ]]; then
	file_dir=$(dirname "$0")
	source $file_dir/../../lxd.conf
fi

agent=$1
container=$2
username=$3

# MAIN -------------------------------------------------------------------------

userHome=/home/

lxc file push $ROOT_PATH/packages/tigervncserver_1.8.0-1ubuntu1_amd64.deb $agent:${container}${userHome}/
lxc exec $agent:$container -- apt-get -qq install xorg openbox xfce4 firefox xfce4-goodies
lxc exec $agent:$container -- dpkg -i $userHome/tigervncserver_1.8.0-1ubuntu1_amd64.deb
lxc exec $agent:$container -- apt-get -f -qq install
lxc exec $agent:$container -- rm $userHome/tigervncserver_1.8.0-1ubuntu1_amd64.deb

if [[ $# == 4 ]]; then
	$ROOT_PATH/applications/gui/gui_user.sh $agent $container $username
fi
