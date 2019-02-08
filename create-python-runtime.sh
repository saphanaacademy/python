#!/bin/bash
if [[ $# -eq 0 ]] ; then
    echo 'Usage:'
    echo 'create-python-runtime.sh [release] [suffix]'
    echo 'See https://www.python.org/downloads/source/'   
    echo 'Examples:'
    echo 'create-python-runtime.sh 3.7.2'
    echo 'create-python-runtime.sh 3.7.2 rc1'
    echo 'create-python-runtime.sh 3.8.0 a1'    
    exit 0
fi

cd ~ ; mkdir -p builds source Downloads

wget -P ~/Downloads -N https://www.python.org/ftp/python/$1/Python-$1$2.tgz
# read -p "Press [Enter] to continue or [Ctrl]+[C] to exit."

tar xzvf ~/Downloads/Python-$1$2.tgz -C ~/source
# read -p "Press [Enter] to continue..."

cd ~/source/Python-$1$2
./configure \
--prefix=/usr/sap/HXE/home/builds/Python-$1$2 \
--exec-prefix=/usr/sap/HXE/home/builds/Python-$1$2 \
--enable-optimizations
# read -p "Press [Enter] to continue..."

make altinstall clean
# read -p "Press [Enter] to continue..."

xs create-runtime -p ~/builds/Python-$1$2
xs runtimes
