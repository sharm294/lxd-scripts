#!/bin/bash

sudo lxc exec $1:$2 -- git clone https://github.com/UofT-HPRC/ECE1373_assignment2.git /home/$3/ECE1373_assignment2/
sudo lxc exec $1:$2 -- chown -R $3:$3 /home/$3/ECE1373_assignment2/

sudo lxc exec $1:$2 -- mkdir /home/$3/.vnc                                                                                                                                                                         
sudo lxc file push xstartup $1:$2/home/$3/.vnc/
sudo lxc exec $1:$2 -- chown $3:$3 /home/$3/.vnc

exit 0
