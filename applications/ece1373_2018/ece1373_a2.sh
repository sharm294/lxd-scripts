#!/usr/bin/env bash

agent=$1
container=$2
username=$3

if [[ -z $ROOT_PATH ]]; then
	file_dir=$(dirname "$0")
	source $file_dir/../../lxd.conf
fi

lxc file push ./ece1373_a2.tar.gz $agent:$container/opt/
lxc exec $agent:$container -- tar --strip-components=2 -zxf /opt/ece1373_a2.tar.gz -C /opt/
lxc exec $agent:$container -- rm /opt/ece1373_a2.tar.gz
lxc exec $agent:$container -- mkdir -p /opt/program
lxc file push ./clear.bit $agent:$container/opt/program/
lxc exec $agent:$container -- chown -R root:$DEFAULT_NON_SUDO_GROUP /opt/
lxc exec $agent:$container -- chmod -R g+r /opt/
lxc exec $agent:$container -- chmod -R g+w /opt/program/
lxc exec $agent:$container -- find /opt/ -type d -exec chmod g+x {} +

lxc exec $agent:$container -- apt-get -qq update
lxc exec $agent:$container -- apt-get -qq install \
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
lxc exec $agent:$container -- rm -rf /var/lib/apt/lists/*

lxc exec $agent:$container -- pip install --upgrade pip
lxc exec $agent:$container -- pip install "Cython>=0.19.2"
lxc exec $agent:$container -- pip install "numpy>=1.7.1"
lxc exec $agent:$container -- pip install "scipy>=0.13.2"
lxc exec $agent:$container -- pip install "scikit-image>=0.9.3"
lxc exec $agent:$container -- pip install "matplotlib>=1.3.1"
lxc exec $agent:$container -- pip install "ipython>=3.0.0"
lxc exec $agent:$container -- pip install "h5py>=2.2.0"
lxc exec $agent:$container -- pip install "leveldb>=0.191"
lxc exec $agent:$container -- pip install "networkx>=1.8.1"
lxc exec $agent:$container -- pip install "nose>=1.3.0"
lxc exec $agent:$container -- pip install "pandas>=0.12.0"
lxc exec $agent:$container -- pip install "python-dateutil>=1.3,<2"
lxc exec $agent:$container -- pip install "protobuf>=2.5.0"
lxc exec $agent:$container -- pip install "python-gflags>=2.0"
lxc exec $agent:$container -- pip install "pyyaml>=3.10"
lxc exec $agent:$container -- pip install "Pillow>=2.3.0"
lxc exec $agent:$container -- pip install "six>=1.1.0"
lxc exec $agent:$container -- pip install lmdb

$ROOT_PATH/applications/gui/gui.sh $agent $container $username

./ece1373_a2_user.sh $agent $container $username $user_key
exit 0
