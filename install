#!/bin/bash

# Ask root permissions
echo "$(whoami)"
[ "$UID" -eq 0 ] || exec sudo "$0" "$@"

# install pip3
apt install python3-pip

# install python packages
pip3 install opencv-python
pip3 install numpy
pip3 install argparse

git submodule update --init --recursive
cd ./rv8
make
