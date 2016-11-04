#!/bin/sh
# Script for installing Caffe with cuDNN support on Jetson TX1 Development Kitls
# 9-15-16 JetsonHacks.com
# MIT License
# Install and compile Caffe on NVIDIA Jetson TX1 Development Kit
# Prerequisites (which can be installed with JetPack 2):
# L4T 24.2 (Ubuntu 16.04)
# OpenCV4Tegra
# CUDA 8.0
# cuDNN v5.1
# Tested with last Github Caffe commit: 80f44100e19fd371ff55beb3ec2ad5919fb6ac43
sudo add-apt-repository universe
sudo apt-get update -y
/bin/echo -e "\e[1;32mLoading NVIDIA Caffe Dependencies.\e[0m"
sudo apt-get install cmake -y
# General Dependencies
sudo apt-get install libprotobuf-dev libleveldb-dev libsnappy-dev \
libhdf5-serial-dev protobuf-compiler -y
sudo apt-get install --no-install-recommends libboost-all-dev -y
# BLAS
sudo apt-get install libatlas-base-dev -y
# Remaining Dependencies
sudo apt-get install libgflags-dev libgoogle-glog-dev liblmdb-dev -y
# Python Dependencies
sudo apt-get install python-dev python-numpy python-skimage python-protobuf -y
/bin/echo -e "\e[1;32mCloning NVIDIA Caffe into the home directory\e[0m"
# Place caffe in the home directory
cd $HOME
# Git clone NVIDIA Caffe
git clone https://github.com/NVIDIA/caffe.git -b caffe-0.15 nvcaffe
cd nvcaffe
cp Makefile.config.example Makefile.config
# Remove cmake folder and CMakeLists files
# rm -rf cmake/ CMakeLists.txt
# Enable cuDNN usage
sed -i 's/# USE_CUDNN/USE_CUDNN/g' Makefile.config
sed -i 's/-gencode arch=compute_50,code=compute_50/-gencode arch=compute_53,code=sm_53 -gencode arch=compute_53,code=compute_53/g' Makefile.config
# Include the hdf5 directory for the includes; 16.04 has issues for some reason
echo "INCLUDE_DIRS += /usr/include/hdf5/serial/" >> Makefile.config
echo "LIBRARY_DIRS += /usr/lib/aarch64-linux-gnu/hdf5/serial/" >> Makefile.config
# Fix HDF5 linking issue
sudo ln -s /usr/lib/aarch64-linux-gnu/libhdf5_serial.so.10 /usr/lib/aarch64-linux-gnu/libhdf5.so
sudo ln -s /usr/lib/aarch64-linux-gnu/libhdf5_serial_hl.so.10 /usr/lib/aarch64-linux-gnu/libhdf5_hl.so
/bin/echo -e "\e[1;32mCompiling Caffe\e[0m"
# Regen the makefile; On 16.04, aarch64 has issues with a static cuda runtime
mkdir build && cd build && \
cmake -DCUDA_USE_STATIC_CUDA_RUNTIME=OFF .. && \
make -j4 all && make pycaffe && \
make install
# Run the tests to make sure everything works
/bin/echo -e "\e[1;32mRunning Caffe Tests\e[0m"
make -j4 runtest

# Edit the following lines in .bashrc and then source .bashrc
export PATH=/usr/local/cuda-8.0/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/ubuntu/caffe/build/tools
export PYTHONPATH=/home/ubuntu/caffe/python:$PYTHONPATH

# Install ipython
sudo apt-get install ipython ipython-notebook python-pandas -y
