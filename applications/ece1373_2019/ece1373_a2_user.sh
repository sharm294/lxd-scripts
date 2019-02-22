#!/usr/bin/env bash

agent=$1
container=$2
username=$3

homeDir=/home/$username

lxc exec $agent:$container -- git clone https://github.com/UofT-HPRC/ECE1373_assignment2.git $homeDir/ECE1373_assignment2/
lxc file push tarballs/static_routed_v1.dcp $agent:${container}$homeDir/ECE1373_assignment2/8v3_shell/
lxc file push tarballs/v1_clear.bit $agent:${container}/opt/util/program/
lxc exec $agent:$container -- chown -R root:$DEFAULT_NON_SUDO_GROUP /opt/util/
lxc exec $agent:$container -- chown -R root:$DEFAULT_NON_SUDO_GROUP /opt/caffe
lxc exec $agent:$container -- chown -R $username:$username $homeDir/
lxc exec $agent:$container -- chmod -R o-rx $homeDir/
