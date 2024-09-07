#!/bin/bash
# Hurricane Matthew Staging Runs
# Configuration
#SBATCH --job-name=Matthew2016base
#SBATCH --account=fc_riser
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks=24
#SBATCH --ntasks-per-node=24
#SBATCH --cpus-per-task=1
#SBATCH --time=12:00:00

## Command(s) to run
dt=$(sed -n '22p' fort.15 | awk '{print $1}')
log="$SLURM_JOB_ID\t\t\t$dt\t\t\t coldstart-full"
echo -e $log >> runlog.out 

current_dir=$(pwd)
folder_name=$(basename $current_dir)

mkdir ../../logs/$folder_name/$SLURM_JOB_ID
cp fort.15 ../../logs/$folder_name/$SLURM_JOB_ID/fort.15

adcprep --np 24 --partmesh
adcprep --np 24 --prepall
mpirun -np 24 padcirc

mv slurm-$SLURM_JOB_ID.out ../../logs/$folder_name/$SLURM_JOB_ID/slurm-$SLURM_JOB_ID.out