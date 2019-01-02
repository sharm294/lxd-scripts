#!/usr/bin/env bash
# This script will add a user account to an existing container. It accepts 4 or
# 5 arguments:
#   AGENT - the hostname of the remote server hosting the container
#   CONTAINER_NAME - name of the container to add the user to
#   USERNAME - name of the user to add
#   USER_KEY - name of the user's public key (.pub is added automatically)
#   SCRIPT - Optional: path to a script to run after the user has been added.
#
# Assumptions
# - Temporary files are created in the local directory

# PREAMBLE ---------------------------------------------------------------------

# the configuration file specifies the global parameters
root_dir=$(dirname "$0")
source $root_dir/lxd.conf

# input validation
if [[ "$#" !=  4 ]] && [[ "$#" != 5 ]]; then
    echo "syntax: script AGENT CONTAINER_NAME USERNAME USER_KEY [SCRIPT]"
    echo "e.g. add_user.sh agent-7 cont_a1 sharmava0 sharmava0 gui_user.sh"
    exit 1
fi

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

# MAIN -------------------------------------------------------------------------

# create authorized_keys file for new container
cp $KEY_PATH/$agent.pub authorized_keys
chmod 600 authorized_keys
cat $KEY_PATH/jumpbox.pub >> authorized_keys
cat $KEY_PATH/controller.pub >> authorized_keys

# create user and make them sudo if requested
lxc exec $agent:$container -- adduser --disabled-password --gecos "" $username &> /dev/null
if [ "$MAKE_SUDO" == "TRUE" ]
then
    lxc exec $agent:$container -- usermod -aG sudo $username
    lxc exec $agent:$container -- passwd -d $username # sets empty sudo password
else
    # otherwise add the user to a default non-sudo group
    if ! lxc exec $agent:$container -- grep -q "^${DEFAULT_NON_SUDO_GROUP}:" /etc/group; then
        lxc exec $agent:$container -- groupadd $DEFAULT_NON_SUDO_GROUP
    fi
    lxc exec $agent:$container -- usermod -aG $DEFAULT_NON_SUDO_GROUP $username
fi

# container setup
lxc exec $agent:$container -- mkdir /home/$username/.ssh
lxc exec $agent:$container -- chmod 700 /home/$username/.ssh
lxc file push authorized_keys $agent:$container/home/$username/.ssh/
rm authorized_keys
lxc exec $agent:$container -- chown -R $username:$username /home/$username/.ssh

# get the container IP address
[ -s "./IP" ]
while [ $? -gt 0 ]
do
    echo "Waiting for IP..."
    sleep 1
    lxc info $agent:$container | grep -Eo '10.84.[0-9]{1,3}.[0-9]{1,3}' > IP
    [ -s "./IP" ]
done

# set up a static IP for the container
ip_addr=$(<IP)

# set up the jumpkey configuration file
cp $JUMP_TEMPLATE_PATH $username
sed -i "s/$JUMP_USER/$username/g" $username
sed -i "s/$JUMP_IP/$ip_addr/" $username
key=$(<$KEY_PATH/$user_key)
sed -i "s|$JUMP_KEY|$key|" $username

# push the jumpkey
scp -P9999 $username root@localhost:~/jumpkeys
ssh -p 9999 -t root@localhost "adduser --disabled-password --gecos \"\" $username"
rm $username
rm IP

if [ "$#" -eq 5 ]
then
    ./$script $agent $container $username $user_key
fi
