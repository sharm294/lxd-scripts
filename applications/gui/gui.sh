sudo lxc file push ./tigervncserver_1.8.0-1ubuntu1_amd64.deb $1:$2/home/$3/
sudo lxc exec $1:$2 -- apt-get -qq install xorg openbox xfce4
sudo lxc exec $1:$2 -- dpkg -i /home/$3/tigervncserver_1.8.0-1ubuntu1_amd64.deb
sudo lxc exec $1:$2 -- apt-get -f -qq install
sudo lxc exec $1:$2 -- rm /home/$3/tigervncserver_1.8.0-1ubuntu1_amd64.deb

sh gui_user.sh $1 $2 $3
