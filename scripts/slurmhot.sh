#!/bin/bash
# Hurricane Tomas Test Run
# Configuration
#SBATCH --job-name=tomas2010test
#SBATCH --account=fc_riser
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks=24
#SBATCH --ntasks-per-node=24
#SBATCH --cpus-per-task=1
#SBATCH --time=12:00:00

## Command(s) to run
mpirun -np 24 padcirc