#!/bin/bash

source ../lxd.conf

lxc exec $1:$2 -- apt-get update
lxc exec $1:$2 -- apt-get -qq install mpich
lxc exec $1:$2 -- su $3 -c "ssh-keygen -f /home/$3/.ssh/id_rsa -t rsa -N ''"
lxc config device add $1:$2 eth3 nic name=eth3 nictype=macvlan parent=eth3
lxc stop $1:$2
lxc start $1:$2

#wait until container is up
[ -s "./IP" ]
while [ $? -gt 0 ]
do
    echo "Waiting for IP..."
    sleep 1
    sudo lxc info $1:$2 | grep -Eo '10.84.[0-9]{1,3}.[0-9]{1,3}' > IP
    [ -s "./IP" ]
done
rm ./IP

lxc exec $1:$2 -- sudo bash -c "echo '' >> /etc/network/interfaces"
lxc exec $1:$2 -- sudo bash -c "echo 'auto eth3' >> /etc/network/interfaces"
lxc exec $1:$2 -- sudo bash -c "echo 'iface eth3 inet static' >> /etc/network/interfaces"
IP_BASE=$ETH3_IP
INDEX=$(echo "$2" | tr -dc '0-9')
IP_BASE=$((IP_BASE+INDEX))
lxc exec $1:$2 -- sudo bash -c "echo '        address '$ETH3_IP_SUBNET.$IP_BASE >> /etc/network/interfaces"
lxc exec $1:$2 -- sudo bash -c "echo '        netmask 255.255.255.0' >> /etc/network/interfaces"
lxc exec $1:$2 -- ifup eth3
