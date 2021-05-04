#!/bin/bash

#This was completed after https://github.com/alitimer/LBPM_Installation, Thanks to Ali Zamani.

#Dependencies, ignore if you have them installed. Some like texlive and doxygen are optional
apt update
apt upgrade -y
apt install cmake -y
#apt install mpich -y
sudo apt install git
sudo apt install gfortran-9
sudo apt-get install gfortran
sudo apt install doxygen
sudo apt install texlive


#Ignore this part if you have openmpi 3.1.2 or any other compatible version installed. LBPM might be incompatible with newer or older versions. 
#DO NOT FORGET to expeort the openmpi address if you are ignoring this part

wget https://download.open-mpi.org/release/open-mpi/v3.1/openmpi-3.1.2.tar.bz2
tar -xf openmpi-3.1.2.tar.bz2
cd openmpi-3.1.2

export MPI_DIR=/opt/openmpi/3.1.2

./configure --prefix=$MPI_DIR \
          --with-cma \
            --enable-dlopen \
            --enable-shared 

make -j4 
sudo make install
cd ..
######################################################
mkdir lbpm && cd $_

#ZLIB 1.2.11
wget https://zlib.net/zlib-1.2.11.tar.gz
tar -xzvf zlib-1.2.11.tar.gz
cd zlib-1.2.11
export LBPM_ZLIB_DIR=$PWD
CC=$MPI_DIR/bin/mpicc CXX=$MPI_DIR/bin/mpicxx ./configure --prefix=$LBPM_ZLIB_DIR |& tee c.txt
make -j4 |& tee m.txt
make install |& tee i.txt

cd ..

#HDF5 1.8.12
wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8/hdf5-1.8.12/src/hdf5-1.8.12.tar.gz
tar -xzvf hdf5-1.8.12.tar.gz
cd hdf5-1.8.12
export LBPM_HDF5_DIR=$PWD
CC=$MPI_DIR/bin/mpicc CXX=$MPI_DIR/bin/mpicxx  CXXFLAGS="-fPIC -O3 -std=c++14"  ./configure --prefix=$LBPM_HDF5_DIR --enable-parallel --enable-shared --with-zlib=$LBPM_ZLIB_DIR |& tee c.txt
make -j4 |& tee m.txt
make install |& tee mi.txt

cd ..

#SILO 4.10.2
wget https://wci.llnl.gov/sites/wci/files/2021-01/silo-4.10.2.tgz
tar -xzvf silo-4.10.2.tgz
cd silo-4.10.2
export LBPM_SILO_DIR=$PWD
CC=$MPI_DIR/bin/mpicc CXX=$MPI_DIR/bin/mpicxx  CXXFLAGS="-fPIC -O3 -std=c++14"  ./configure --prefix=$LBPM_SILO_DIR -with-hdf5=$LBPM_HDF5_DIR/include,$LBPM_HDF5_DIR/lib -with-zlib=$LBPM_ZLIB_DIR/include,$LBPM_ZLIB_DIR/lib --enable-static |& tee c.txt
make -j4 |& tee m.txt
make install |& tee mi.txt

cd ..

#LBPM latest
#Cmake settings can be changed accordingly. I will try to insert the cuda automatically as well
git clone https://github.com/OPM/LBPM.git
mkdir LBPM_BUILD
cd LBPM_BUILD
export LBPM_BUILD=$PWD
cd ../LBPM
export LBPM_SOURCE=$PWD
cd $LBPM_BUILD
cmake \
     -D CMAKE_BUILD_TYPE:STRING=Release     \
    -D CMAKE_C_COMPILER:PATH=$MPI_DIR/bin/mpicc          \
    -D CMAKE_CXX_COMPILER:PATH=$MPI_DIR/bin/mpicxx        \
    -D CMAKE_C_FLAGS="-O3 -fPIC"         \
    -D CMAKE_CXX_FLAGS="-fPIC -O3 -std=c++14"      \
    -D CMAKE_CXX_STANDARD=14    \
    -D MPIEXEC=$MPI_DIR/bin/mpirun                     \
    -D CUDA_FLAGS="-arch sm_35"          \
    -D CUDA_HOST_COMPILER="/usr/bin/gcc" \
    -D HDF5_DIRECTORY=$LBPM_HDF5_DIR \
    -D HDF5_LIB=$LBPM_HDF5_DIR/lib/libhdf5.a\
    -D USE_SILO=1 \
    -D SILO_LIB=$LBPM_SILO_DIR/lib/libsiloh5.a \
    -D SILO_DIRECTORY=$LBPM_SILO_DIR \
    -D USE_MPI=1 \
    -D USE_NETCDF=0  \
    -D NETCDF_DIRECTORY="/opt/netcdf/4.6.1" \
    -D USE_CUDA=0                        \
    -D USE_TIMER=0 \
$LBPM_SOURCE

make -j4 |& tee m.txt
make install |& tee i.txt
ctest
#If the LBPM is built without error with MPI enabled but the parallel examples are not correctly run in ctest step, you might need to manually run your parallel example with mpirun in $MPI_DIR directory. something like this: /opt/openmpi/3.1.2/bin/mpirun -n 8 '/home/hamidreg/lbpm3/lbpm/LBPM_BUILD/bin/lbpm_color_simulator'  input_morphdrainpp.db
