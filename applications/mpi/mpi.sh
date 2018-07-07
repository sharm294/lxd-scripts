#!/bin/bash

sudo lxc exec $1:$2 -- apt-get update
sudo lxc exec $1:$2 -- apt-get -qq install mpich
sudo lxc exec $1:$2 -- ssh-keygen -f /home/$3/.ssh/id_rsa -t rsa -N ''
