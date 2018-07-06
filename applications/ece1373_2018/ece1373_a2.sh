#!/bin/bash

sudo lxc file push ./ece1373_a2.tar.gz $1:$2/opt/
sudo lxc exec $1:$2 -- tar --strip-components=2 -zxf /opt/ece1373_a2.tar.gz -C /opt/
sudo lxc exec $1:$2 -- rm /opt/ece1373_a2.tar.gz
sudo lxc exec $1:$2 -- mkdir -p /opt/program
sudo lxc file push ./clear.bit $1:$2/opt/program/
sudo lxc exec $1:$2 -- chown -R root:reg-users /opt/
sudo lxc exec $1:$2 -- chmod -R g+r /opt/
sudo lxc exec $1:$2 -- chmod -R g+w /opt/program/
sudo lxc exec $1:$2 -- find /opt/ -type d -exec chmod g+x {} +

sudo lxc exec $1:$2 -- apt-get -qq update
sudo lxc exec $1:$2 -- apt-get -qq install \
    cmake \
    git \
    wget \
    libatlas-base-dev \
    libboost-all-dev \
    libgflags-dev \
    libgoogle-glog-dev \
    libhdf5-serial-dev \
    libleveldb-dev \
    liblmdb-dev \
    libopencv-dev \
    libprotobuf-dev \
    libsnappy-dev \
    protobuf-compiler \
    python-dev \
    python-numpy \
    python-pip \
    python-setuptools \
    python-scipy \
    python-tk
sudo lxc exec $1:$2 -- rm -rf /var/lib/apt/lists/*

sudo lxc exec $1:$2 -- pip install --upgrade pip
sudo lxc exec $1:$2 -- pip install "Cython>=0.19.2"
sudo lxc exec $1:$2 -- pip install "numpy>=1.7.1"
sudo lxc exec $1:$2 -- pip install "scipy>=0.13.2"
sudo lxc exec $1:$2 -- pip install "scikit-image>=0.9.3"
sudo lxc exec $1:$2 -- pip install "matplotlib>=1.3.1"
sudo lxc exec $1:$2 -- pip install "ipython>=3.0.0"
sudo lxc exec $1:$2 -- pip install "h5py>=2.2.0"
sudo lxc exec $1:$2 -- pip install "leveldb>=0.191"
sudo lxc exec $1:$2 -- pip install "networkx>=1.8.1"
sudo lxc exec $1:$2 -- pip install "nose>=1.3.0"
sudo lxc exec $1:$2 -- pip install "pandas>=0.12.0"
sudo lxc exec $1:$2 -- pip install "python-dateutil>=1.3,<2"
sudo lxc exec $1:$2 -- pip install "protobuf>=2.5.0"
sudo lxc exec $1:$2 -- pip install "python-gflags>=2.0"
sudo lxc exec $1:$2 -- pip install "pyyaml>=3.10"
sudo lxc exec $1:$2 -- pip install "Pillow>=2.3.0"
sudo lxc exec $1:$2 -- pip install "six>=1.1.0"
sudo lxc exec $1:$2 -- pip install lmdb

sudo lxc file push ./tigervncserver_1.8.0-1ubuntu1_amd64.deb $1:$2/home/$3/
sudo lxc exec $1:$2 -- apt-get -qq install xorg openbox xfce4
sudo lxc exec $1:$2 -- dpkg -i /home/$3/tigervncserver_1.8.0-1ubuntu1_amd64.deb
sudo lxc exec $1:$2 -- apt-get -f -qq install
sudo lxc exec $1:$2 -- rm /home/$3/tigervncserver_1.8.0-1ubuntu1_amd64.deb

sh ./ece1373_a2_user.sh $1 $2 $3 $4
exit 0
