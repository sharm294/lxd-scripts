#!/bin/bash

die () {
    echo >&2 "$@"
    exit 1
}

[ "$#" -eq 3 ] || die "syntax: script AGENT CONTAINER_NAME USERNAME"

lxc stop $1:$2
lxc delete $1:$2
ssh -t $1 "sudo sed -i '/$2/d' /etc/default/dns.conf"

ssh -p 9999 -t root@localhost "userdel -r $3 && rm ~/jumpkeys/$3"
