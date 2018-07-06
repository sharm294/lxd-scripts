#! /bin/bash

ssh -p 9999 -t root@localhost "userdel -r $1 && rm ~/jumpkeys/$1"
