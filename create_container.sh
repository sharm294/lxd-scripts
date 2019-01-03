#!/usr/bin/env bash
# This script can be used to deploy containers on an agent. It will create the 
# container, add a user account (and make them sudo optionally), set up the IP 
# address, and set up the permissions on the jumpbox for access. It accepts 4 or
# 5 arguments:
#   AGENT - the hostname of the remote server that will host the container
#   CONTAINER_NAME - name of the container to add
#   USERNAME - name of a user to add
#   USER_KEY - name of the user's public key (.pub is added automatically)
#   SCRIPT - Optional: path to a script to run after the user has been added.

# Assumptions
# - Temporary files are created in the local directory

# PREAMBLE ---------------------------------------------------------------------

# the configuration file specifies the global parameters
root_dir=$(dirname "$0")
source $root_dir/lxd.conf

agent=$1
container=$2
username=$3
user_key=$4
if [[ $# == 5 ]]; then
    postscript=$5
fi

#input validation
if [[ "$#" != 4 && "$#" != 5 ]]; then 
    echo "Syntax: script AGENT CONTAINER_NAME USERNAME USER_KEY [SCRIPT]"
    echo "e.g. create_container.sh agent-7 cont_a1 sharmava0 sharmava0.pub"
    exit 1
fi

#check if the key for the agent exists
if [ ! -f $KEY_PATH/$agent.pub ]; then
    echo "$agent.pub not found"
    exit 1
fi

if [ ! -f $KEY_PATH/jumpbox.pub ]; then
    echo "jumpbox.pub not found at $KEY_PATH"
    exit 1
fi

if [ ! -f $JUMP_TEMPLATE_PATH ]; then
    echo "jumpbox template not found"
    exit 1
fi

if [ ! -f $KEY_PATH/$user_key ]; then
    echo "User key $KEY_PATH/$user_key not found"
    exit 1
fi

if [[ "$container" =~ [^a-zA-z0-9-] ]]; then
    echo "Invalid container name: can only contain letters, numbers and dashes"
    exit 1
fi

# Main -------------------------------------------------------------------------

# launch container
ssh -t $agent "lxc launch $IMAGE $container"

# setup container
lxc exec $agent:$container -- ifconfig eth0 mtu 1300 #needed for ssh tunneling bug

# get the container IP address
unset IP
while [[ -z $IP ]]; do
    echo "Waiting for IP..."
    sleep 1
    IP=$(lxc info $agent:$container | grep -Eo '10.84.[0-9]{1,3}.[0-9]{1,3}')
done

# set up a static IP for the container
ip_addr=$IP
ssh agent-9 'echo "dhcp-host='$container','$ip_addr'" | sudo tee --append /etc/default/'$DNS_FILE

# install default apps
lxc exec $agent:$container -- apt-get -qq update
lxc exec $agent:$container -- apt-get -qq install $(cat $DEFAULT_APPS)

if [ "$#" -eq 5 ]
then
    ./$postscript $agent $container $username $user_key
fi
