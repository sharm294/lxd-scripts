#! /bin/bash

die () {
    echo >&2 "$@"
    exit 1
}

[ "$#" -eq 1 ] || die "syntax: script USERNAME"

ssh -p 9999 -t root@localhost "userdel -r $1 && rm ~/jumpkeys/$1"
