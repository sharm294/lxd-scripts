#!/bin/bash
#This script can be used to deploy containers on an agent. It will create the 
#container, add a user account (and make them sudo optionally), set up the IP 
#address, and set up the permissions on the jumpbox for access.

#Assumptions
# - Temporary files are created in the local directory

source ./lxd.conf #contains common variables and file paths

#input validation
if [[ "$#" != 4 && "$#" != 5 ]]; then 
    echo "Syntax: script AGENT CONTAINER_NAME USERNAME USER_KEY [SCRIPT]"
    echo "e.g. create_container.sh agent-7 cont_a1 sharmava0 sharmava0.pub"
    exit 1
fi

#check if the key for the agent exists
if [ ! -f $KEY_PATH/$1.pub ]; then
    echo "$1.pub not found"
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

if [ ! -f $KEY_PATH/$4 ]; then
    echo "User key $KEY_PATH/$4 not found"
    exit 1
fi

if [[ "$2" =~ [^a-zA-z0-9-] ]]; then
    echo "Invalid container name: can only contain letters, numbers and dashes"
    exit 1
fi

#create authorized_keys file for new container
cp $KEY_PATH/$1.pub authorized_keys
chmod 600 authorized_keys
cat $KEY_PATH/jumpbox.pub >> authorized_keys
cat $KEY_PATH/controller.pub >> authorized_keys

#launch container, create user and make them sudo if requested
ssh -t $1 "lxc launch $IMAGE $2"
#sudo lxc launch $IMAGE $1:$2
sudo lxc exec $1:$2 -- adduser --disabled-password --gecos "" $3 &> /dev/null
if [ "$MAKE_SUDO" == "TRUE" ]
then
    sudo lxc exec $1:$2 -- usermod -aG sudo $3
    sudo lxc exec $1:$2 -- passwd -d $3 #sets empty sudo password
else
    if ! sudo lxc exec $1:$2 -- grep -q "^${DEFAULT_NON_SUDO_GROUP}:" /etc/group; then
        sudo lxc exec $1:$2 -- groupadd $DEFAULT_NON_SUDO_GROUP
    fi
    sudo lxc exec $1:$2 -- usermod -aG $DEFAULT_NON_SUDO_GROUP $3
fi

#container setup
sudo lxc exec $1:$2 -- mkdir /home/$3/.ssh
sudo lxc exec $1:$2 -- chmod 700 /home/$3/.ssh
sudo lxc file push authorized_keys $1:$2/home/$3/.ssh/
rm authorized_keys
sudo lxc exec $1:$2 -- chown -R $3:$3 /home/$3/.ssh
sudo lxc exec $1:$2 -- ifconfig eth0 mtu 1300 #needed for ssh tunneling bug

#get the container IP address
[ -s "./IP" ]
while [ $? -gt 0 ]
do
    echo "Waiting for IP..."
    sleep 5
    sudo lxc info $1:$2 | grep -Eo '10.84.[0-9]{1,3}.[0-9]{1,3}' > IP
    [ -s "./IP" ]
done

#set up a static IP for the container
ip_addr=$(<IP)
scp $1:/etc/default/$DNS_FILE .
echo "dhcp-host=$2,$ip_addr" | sudo tee --append ./$DNS_FILE
scp $DNS_FILE $1:~/
ssh -t $1 "sudo mv ~/$DNS_FILE /etc/default"
rm dns.conf

#set up the jumpkey configuration file
cp $JUMP_TEMPLATE_PATH $3
sed -i "s/$JUMP_USER/$3/g" $3
sed -i "s/$JUMP_IP/$ip_addr/" $3
key=$(<$KEY_PATH/$4)
sed -i "s|$JUMP_KEY|$key|" $3

#push the jumpkey
scp -P9999 $3 root@localhost:~/jumpkeys
ssh -p 9999 -t root@localhost "adduser --disabled-password --gecos \"\" $3"
rm $3
rm IP

#install default apps
sudo lxc exec $1:$2 -- apt-get -qq update
sudo lxc exec $1:$2 -- apt-get -qq install $(cat ./profile/default)

if [ "$#" -eq 5 ]
then
    sh ./$5 $1 $2 $3 $4
fi
