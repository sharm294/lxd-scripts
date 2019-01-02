#!/usr/bin/env bash

agent=$1
container=$2
username=$3

homeDir=/home/$username

$ROOT_PATH/applications/gui/gui_user.sh $agent $container $username

lxc exec $agent:$container -- git clone https://github.com/UofT-HPRC/ECE1373_assignment2.git $homeDir/ECE1373_assignment2/
lxc exec $agent:$container -- chown -R $username:$username $homeDir/ECE1373_assignment2/

lxc exec $agent:$container -- mkdir $homeDir/.vnc
lxc file push xstartup $agent:${container}$homeDir/.vnc/
lxc exec $agent:$container -- chown $username:$username $homeDir/.vnc
