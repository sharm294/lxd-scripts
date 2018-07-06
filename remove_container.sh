#!/bin/bash

die () {
    echo >&2 "$@"
    exit 1
}

[ "$#" -eq 3 ] || die "syntax: script AGENT CONTAINER_NAME USERNAME"

ssh -t $1 "rm -f /home/savi/authorized_keys"
lxc stop $1:$2
lxc delete $1:$2
ssh -t $1 "rm -f /home/savi/IP"
ssh -t $1 "sudo sed -i '/$2/d' /etc/default/dns.conf"

#cp remove_container_agent.sh temp.sh
#sed -i "s/\$1/$2/g" temp.sh
#scp temp.sh $1:~ && ssh $1 './temp.sh'

ssh -p 9999 -t root@localhost "userdel -r $3 && rm ~/jumpkeys/$3"

#cp remove_container_jumpbox.sh temp.sh
#sed -i "s/\$1/$3/g" temp.sh
#scp -P9999 temp.sh root@localhost:~ && ssh -p 9999 root@localhost './temp.sh'
#rm temp.sh
