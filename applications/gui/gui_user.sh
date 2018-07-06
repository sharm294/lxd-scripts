sudo lxc exec $1:$2 -- mkdir /home/$3/.vnc 
sudo lxc file push xstartup $1:$2/home/$3/.vnc/
sudo lxc exec $1:$2 -- chown $3:$3 /home/$3/.vnc
