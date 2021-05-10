#!/bin/bash
#using: https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#download-nvidia-driver-and-cuda-software
#https://developer.nvidia.com/cuda-downloads
#Virginia region
DEBIAN_FRONTEND=noninteractive
DEB_BUILD_DEPS="build-essential python3-dev python3-pip python3-setuptools software-properties-common"
DEB_PACKAGES="sudo nano less time git curl wget htop graphviz gfortran nvtop"
PIP_PACKAGES="numpy scipy matplotlib pandas testresources seaborn sympy cvxpy pytest dask distributed bokeh networkx ortools cython numba graphviz jedi==0.17.2 awscli cupy-cuda112"
USER=ubuntu
JUPYTERLAB_VERSION=3.0.0
LANG=C.UTF-8
LC_ALL=C.UTF-8

apt-get update && export $DEBIAN_FRONTEND && apt-get install -y tzdata

apt-get update && apt-get install -y $DEB_BUILD_DEPS $DEB_PACKAGES && pip3 install --upgrade pip

# Install nodejs deps
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash - && apt-get install -y nodejs

#install cuda-toolkit

apt-get install linux-headers-$(uname -r)

#using local type installation for cuda-toolkit from:
#https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64&=Ubuntu&target_version=20.04&target_type=deb_local

wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
wget https://developer.download.nvidia.com/compute/cuda/11.3.0/local_installers/cuda-repo-ubuntu2004-11-3-local_11.3.0-465.19.01-1_amd64.deb
dpkg -i cuda-repo-ubuntu2004-11-3-local_11.3.0-465.19.01-1_amd64.deb
apt-key add /var/cuda-repo-ubuntu2004-11-3-local/7fa2af80.pub
apt-get update && sudo apt-get -y install cuda

#another type of installation: network for cuda-toolkit from:
#https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64&=Ubuntu&target_version=20.04&target_type=deb_network

#wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
#mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
#apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/7fa2af80.pub
#add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /"
#apt-get update
#apt-get -y install cuda

CUDA_VERSION=cuda-11.3
echo "export PATH=/usr/local/$CUDA_VERSION/bin${PATH:+:${PATH}}" >> /home/$USER/.profile
echo "export LD_LIBRARY_PATH=/usr/local/$CUDA_VERSION/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}" >>/home/$USER/.profile

#install next packages for ubuntu user

sudo -H --preserve-env -u $USER bash << EOF
export PATH=/home/$USER/.local/bin:$PATH


pip3 install --user $PIP_PACKAGES

pip3 install --user jupyter jupyterlab==$JUPYTERLAB_VERSION
jupyter notebook --generate-config && sed -i "s/# c.NotebookApp.password = .*/c.NotebookApp.password = u'sha1:115e429a919f:21911277af52f3e7a8b59380804140d9ef3e2380'/" /home/$USER/.jupyter/jupyter_notebook_config.py


EOF
