#!/bin/bash

# $1 - agent
# $2 - container
# $3 - username

ssh -t $1 "lxc config device remove $2 cloud"
ssh -t $1 "sudo umount -t nfs ~/nfs/$3"
