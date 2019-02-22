#!/usr/bin/env bash

# input validation
if [[ "$#" !=  4 ]] && [[ "$#" != 5 ]]; then
    echo "syntax: script AGENT CONTAINER_NAME USERNAME USER_KEY [SCRIPT]"
    echo "e.g. add_user.sh agent-7 cont_a1 sharmava0 sharmava0.pub gui_user.sh"
    exit 1
fi

source ./lxd.conf

agent=$1
container=$2
username=$3
user_key=$4
if [[ $# == 5 ]]; then
    postscript=$5
fi

if lxc info $agent:$container 2>&1 | grep -q 'error'; then
    echo "Container $agent:$container not found"
    exit 1
fi

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

./add_user $agent $container $username $user_key
./applications/gui_user.sh $agent $container $username
./applications/ece1373_a2_user.sh $agent $container $username
