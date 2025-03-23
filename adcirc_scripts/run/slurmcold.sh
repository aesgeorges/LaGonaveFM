#!/bin/bash
# Hurricane Matthew Staging Runs
# Configuration
#SBATCH --job-name=
#SBATCH --account=fc_riser
#SBATCH --partition=savio2
#SBATCH --nodes=1
#SBATCH --ntasks=24
#SBATCH --ntasks-per-node=24
#SBATCH --cpus-per-task=1
#SBATCH --time=12:00:00

## Command(s) to run

nprocs=24

main() {
    dt=$(sed -n '22p' fort.15 | awk '{print $1}')
    log="$SLURM_JOB_ID\t\t\t$dt\t\t\t 2-phase run-full"
    echo -e $log >> runlog.out 

    current_dir=$(pwd)
    folder_name=$(basename $current_dir)

    mkdir ../../logs/$folder_name/$SLURM_JOB_ID
    # cp fort.15 ../../logs/$folder_name/$SLURM_JOB_ID/fort.15

    echo -e "Cold start spinup run with tides ................ "
    run_cold_spinup
    echo -e "Hot start run with wind/hurricane forcing ................ "
    run_hot_wind

    mv slurm-$SLURM_JOB_ID.out ../../logs/$folder_name/$SLURM_JOB_ID/slurm-$SLURM_JOB_ID.out
}

run_cold_spinup() {
    log="\t\t\t\t\t\t\t\t\t\t coldstart-spinup"
    echo -e $log >> runlog.out 

    cp fort.15.coldstart ../../logs/$folder_name/$SLURM_JOB_ID/fort.15.coldstart
    rm -rf coldstart
    mkdir coldstart
    cd coldstart
    ln -sf ../fort.13
    ln -sf ../fort.14
    ln -sf ../fort.15.coldstart ./fort.15

    adcprep --np $nprocs --partmesh
    adcprep --np $nprocs --prepall
    mpirun -np $nprocs padcirc

    clean_directory
    cd ..
}

run_hot_wind() {
    log="\t\t\t\t\t\t\t\t\t\t hotstart-wind run"
    echo -e $log >> runlog.out 
    
    cp fort.15.hotstart ../../logs/$folder_name/$SLURM_JOB_ID/fort.15.hotstart
    rm -rf hotstart
    mkdir hotstart
    cd hotstart
    ln -sf ../fort.14
    ln -sf ../fort.13
    ln -sf ../fort.15.hotstart ./fort.15
    ln -sf ../coldstart/fort.67.nc
    ln -sf ../fort.22 ./fort.22
    aswip -n 20 -m 4 -z 2
    mv NWS_20_fort.22 fort.22

    adcprep --np $nprocs --partmesh
    adcprep --np $nprocs --prepall
    mpirun -np $nprocs padcirc

    clean_directory
    cd ..
}

clean_directory() {
  rm -rf PE*
  rm -rf partmesh.txt
  rm -rf metis_graph.txt
  rm -rf fort.13
  rm -rf fort.14
  rm -rf fort.15
  rm -rf fort.16
  rm -rf fort.80
  rm -rf fort.68.nc
}

main