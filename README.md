## main LBPM package github repo: https://github.com/OPM/LBPM 
# The bash file was completed after https://github.com/alitimer/LBPM_Installation, Thanks to Ali Zamani.
# LBPM_installation
This bash script helps to make the LBPM installation automatic. 
LBPM might be incompatible with new versions of OpenMPI so we have included the OpenMPI 3.1.2 in the installation. 
If you already have a newer version installed, you can install this version in a different folder, like one pre-inserted in the bash file. 
********NOTE*********
Some dependencies like Doxygena and TexLive are optional and the LBPM will be successfully built without them. 
**********************
The file downloads, builds and installs the following packages one after each other. You can skip each of them if you have them already installed. 

      1. OpenMPI 3.1.2
      2. ZLIB 
      3. HDF5
      4. SILO
      5. LBPM

you can modify LBPM make options under cmake block in the bash file. 
If the LBPM make step was passed without any error but the parallel examples were not run successfully you might need to run them manually with the installed mpirun executable in the location you installed OpenMPI 3.1.2 ($MPI_DIR). Something like: 
/opt/openmpi/3.1.2/bin/mpirun -n 8 '/home/hamidreg/lbpm3/lbpm/LBPM_BUILD/bin/lbpm_color_simulator'  input_morphdrainpp.db

# The file was checked on Ubuntu 20.04 with an Intel i9-10900K CPU. 

I will try to add CUDA, and other optional packages like NETCDF to the bash file later. 
