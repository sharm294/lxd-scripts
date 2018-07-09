#!/bin/bash

# $1 - agent
# $2 - container
# $3 - IP of master
# $4 - path of mount folder on master
# $5 - username
# $6 - path of mount folder on slave

ssh -t $1 "sudo mount -t nfs $3:$4 ~/nfs/$5"
ssh -t $1 "lxc config device add $2 cloud disk path=$6 source=~/nfs/$5/ optional=true"
