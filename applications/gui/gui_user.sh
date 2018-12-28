#!/bin/bash

if [[ -z $ROOT_PATH ]]; then
	source ../../lxd.conf
fi

sudo lxc exec $1:$2 -- mkdir -p /home/$3/.vnc 
sudo lxc file push $ROOT_PATH/applications/gui/xstartup_xfce $1:$2/home/$3/.vnc/
sudo lxc exec $1:$2 -- chown $3:$3 /home/$3/.vnc
