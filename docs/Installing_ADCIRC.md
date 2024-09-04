## Introduction

This guide provides instructions for installing, compiling and running the ADCIRC hydrodynamic model on Linux (specifically, Ubuntu WSL). 

## Installing ADCIRC

### Download Source Code

1. Visit the [ADCIRC GitHub Repo.](https://github.com/adcirc/adcirc) https://github.com/adcirc/adcirc
2. The source code needed for compilation can be downloaded in the terminal using one of the following commands:
    1. `$ gh repo clone adcirc/adcirc` (if GitHub CLI is installed)
    2. `$ git clone https:/github.com/adcirc/adcirc.git`

### Install Dependencies

The main libraries needed to run a basic, local run of ADCIRC are the following: 

- A Fortran compiler, here we chose GFortran: `gfortran`
- The HDF5 Fortran Library, needed by the NetCDF Library: `hdf5-fortran`
- The NetCDF Library: `netcdf-bin`
- GNU Make, for building executable files: `make`
- MPI, for parallel computing: `openmpi`

These libraries themselves have dependencies. Following these following commands in order will ensure them working on a clean Linux installation:

1. `$ sudo apt-get update` 
2. `$ sudo apt-get install gfortran` 
3. `$ sudo apt-get install make` 
4. `$ sudo apt-get install cmake` 
5. `$ sudo apt-get install openmpi-bin` 
6. `$ sudo apt-get install libopenmpi-dev` 
7. `$ sudo apt-get install perl` 
8. `$ sudo apt-get install libhdf5-dev` 
9. `$ sudo apt-get install libhdf5-fortran-102` 
10. `$ sudo apt-get install netcdf-bin` 
11. `$ sudo apt-get install libnetcdff-dev` 
12. `$ sudo apt-get install libxdmf-dev` 

### Modify the Compiler Flags

Now going in the ADCIRC Source Code folder we downloaded from Git, we will find the `work` folder. This folder holds all the parameters and files needed for compiling ADCIRC.

The `work/cmplrflags.mk` text file contains the flags needed by the compiler to build ADCIRC. 

We will make two modifications to that file.

1. **Point Make to which compiler to use** by uncommenting the following line (which can be found in the very first lines of the file: `compiler=gfortran`. If using a different compiler, please uncomment the equivalent line instead.
2.  **Switch the HDF5 Library pointer flag.** Ubuntu places the HDF5 Library under a serial subdirectory, leading to an error during compilation where the compiler cannot find the library using the given name:

`/usr/bin/ld: cannot find -lhdf5_fortran: No such file or directory`

Changing every instance of `-lhdf5_fortran` to the correct `-lhdf5_serial_fortran` flag in `cmplrflags` fixes this issue. 

If working in a terminal, this can quickly be done using the built-in `nano` terminal text editor. Following the next steps will help you perform this quick edit:

1. `$ cd adcirc/work`  Enter the `adcirc/work` folder if you haven’t done so yet.
2. `$ nano cmplrflgs.mk`  Open the compiler flags file in the text editor.
3. Hit the `Ctrl+\` keyboard shortcut to replace a string. Type in `-lhdf5_fortran` in the `Search (to replace):` field and hit enter.
4. Type in `-lhdf5_serial_fortran` in the `Replace with:` field and hit enter.
5. Hit `A` to replace all occurrences. It should have replace 10 occurrences.
6. Navigate using the arrow keys to uncomment the `compiler=gfortran` line.
7. Hit the `Ctrl+X` keyboard shortcut to close the file, confirming to save and using the same file name. 

### Compile ADCIRC (with NetCDF support)

We are ready to compile! The following steps will compile ADCIRC with NetCDF support, letting it write its output files in the (easier to use and friendlier to 3rd-party tools) NetCDF format (.nc files).

Assuming you are still in the `adcirc/work` folder:

1. `$ chmod +x config.guess`  To update the permissions of the `config.guess` file, which figures out your current hardware configuration.
2. `$ make adcirc NETCDF=enable NETCDFHOME=/usr NETCDF4=enable` Compiles ADCIRC with NetCDF support.
    1. The NETCDFHOME flag can be added to `cmplrflgs.mk` to avoid typing it everytime. Make sure to add it under the correct compiler mode. Here this will be under gfortran, look for the faollowing line in the file:
    
    `ifeq ($(compiler),gfortran)`
    
3. Type in `$ dir` to make sure the executable `adcirc` was successfully created. If yes, the model can be executed using the command: `./adcirc` (which will terminate because this current location has no input files to work with).
4. While this command will only work in the same folder where the executable is, forcing you to copy it to other directories, we can add it to the PATH variable, letting us access from any directory.
    1. `$ cd ~`  to return to the home directory.
    2. `$ nano .bashrc` To edit your system paths.
    3. At the very bottom of the file write in the following line: 
    
    `export PATH="~/path/to/adcirc/work/:$PATH"`
    
    Where `~/path/to/adcirc/work/` is the path to your the folder where the executable adcirc file is located, here `~/adcirc/work/`.
    
    Save and exit. Run `$ source ~/.bashrc` to reload your PATH configuration. You should now be able to call ADCIRC from any directory using the simple `$ adcirc` command.
    
    ### Compiling ADCIRC on HPC Savio
    
    Some additional steps are required to compile savio on HPC Savio.
    
    1. NetCDF library adjustments
    2. Add NETCDFHOME and FLIB paths to `cmplrflgs.mk`
    

## Compiling for Parallel

Involves compiling and running a couple extra files

Compile adcprep with NETCDF/4 support

Compile padcirc with NETCDF/4 support

run these to prep the files (where —np 8 is the number of processors to be used): 

./adcprep --np 8 --partmesh
./adcprep --np 8 --prepall

then call padcirc with openmpi:

mpirun -np 8 ./padcirc

## Installing Conda on Ubuntu WSL (Optional but Recommended for Virtual Environments)

Conda does not come preinstalled on Ubuntu and requires a few command lines to get installed through the terminal:

1. Download the installation script:
    
    `$ wget <https://repo.anaconda.com/archive/Anaconda3-2023.09-0-Linux-x86_64.sh>`
    
    *This url will change depending on the version that you want and follows this naming convention:*
    
    `https://repo.anaconda.com/archive/Anaconda3-YYYY.MM-#-Linux-x86_64.sh`
    
2. Give permission to script:
    
    `$ chmod +x Anaconda3-2023.09-0-Linux-x86-64.sh`
    
3. Run bash and follow instructions:
    
    `$ ./Anaconda3-2023.09-0-Linux-x86-64.sh`
    
4. cd Add Conda to path by modifying `.bashrc`:
    1. `$ nano .bashrc`
    2. Add the following line at the end: `export PATH="~/anaconda3/bin:$PATH"`
    3. Save and close the file.
    4. `$ source ~/.bashrc` to reload bash configuration.
5. Make new env:
    
    `$ conda create -n <env-name>`
    
6. Activate environment with:
    
    `$ conda activate <env-name>` or `$ source activate <env-name>`
    

## Installing Kalpana

1. Activate environment if you already have one.
2. Visit the [Kalpana Github Repo](https://github.com/ccht-ncsu/Kalpana).  https://github.com/ccht-ncsu/Kalpana.git
3. Clone the source code:  `$ git clone https://github.com/ccht-ncsu/Kalpana.git` 
4. Kalpana has some required dependencies which can be found in the `Kalpana/install/requirements.txt` text file. We can install all the dependencies using pip:
    1. `cd Kalpana/install` Navigate to the install folder.
    2. Install the dependencies using: `$ pip install -r requirements.txt` or `$ pip install . e`  in more recent versions.
5. I have found that Kalpana implicitly needs the PostgreSQL Database Adapter to work properly. This can be fixed by:
    1. `$ sudo apt-get install libpq-dev`
    2. `$ pip install psycopg2`
6. We can add `kalpana.py` and the other scripts to PATH so that their functions can be accessed from any directory:
    1. `$ nano ~/.bashrc` 
    2. Add the following line: `export PATH="~/Kalpana/kalpana:$PATH"`
    3. Save and close the file.
    4. `$ source ~/.bashrc` to reload bash configuration.

## Installing ADCIRCPy

1. Activate environment if you already have one.
2. Install ADCIRCPy using pip:
    
    `$ pip install adcircpy`
    

## Test Run!

We’re done installing! Now to run an example model. Thankfully adcirc offers a test suite that we can clone from GitHub.

1. Visit the [ADCIRC Test Suite Github Repo.](https://github.com/adcirc/adcirc-testsuite) https://github.com/adcirc/adcirc-testsuite
2. Clone the Test Suite: `$ git clone https:/github.com/adcirc/adcirc-testsuite.git`
3. There will be many examples under the `adcirc-testsuite/adcirc` folder, Let’s try to run the global tide example:
    1. `$ cd adcirc-testsuite/adcirc/adcirc_global-tide-2d`
    2. Notice the existence of `fort.13` , `fort.14`, and `fort.15` files in this directory. These are your input files.
    3. Call `$ adcirc` . If the adcirc executable was correctly added to path earlier this should work and the model will start running! (Note that this example will need to output in NetCDF, so the adcirc should have been compiled with NetCDF enabled, if not, we can quickly go recompile it using previous steps. Remember to run `$ make clean` before recompiling).
    4. `$ ls` to display files in the directory after complete run. Notice new files were added. These are output files that can be used for visualization.
4. Visualize! We can quickly visualize the max elevations using ADCIRCPy directly in the terminal assuming it was installed correctly:
    1. `$ plot_maxele maxele.63.nc` A window should open with a plot of the maximum elevations at every node!
    2. Visit the following site for documentation on the CLI and Library functionalities of ADCIRCPy: [ADCIRCPy — adcircpy 1.2.7.post7.dev0+2263910 documentation](https://adcircpy.readthedocs.io/en/latest/index.html)
    3. Visit the following site for documentation and descriptions of ADCIRC’s output files: [Output File Descriptions - ADCIRC](https://adcirc.org/home/documentation/users-manual-v50/output-file-descriptions/)
5. Kalpana can be used to post-process and make nicer plots in Python/Jupyter notebooks and is a more powerful visualization tool.

## Next

1. Automatic run configuration and hurricane forcing using ADCIRCPy.
2. Visualization and Post-Processing Using Kalpana.