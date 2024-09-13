## Command(s) to run

nprocs=6

main() {
    dateid=$(date '+%d%m%y-%H%M')
    dt=$(sed -n '22p' fort.15.coldstart | awk '{print $1}')
    log="$dateid\t\t\t$dt\t\t\t hurricane 2-phase run"
    echo -e $log >> runlog.out 

    current_dir=$(pwd)
    folder_name=$(basename $current_dir)

    mkdir ../../logs/$folder_name/$dateid

    echo -e "Cold start spinup run with tides ................ " > ../../logs/$folder_name/$dateid/dateid.out
    run_cold_spinup
    echo -e "Hot start run with wind/hurricane forcing ................ " >> ../../logs/$folder_name/$dateid/dateid.out
    run_hot_wind
}

run_cold_spinup() {
    log="\t\t\t\t\t\t\t\t\t\t coldstart-spinup"
    echo -e $log >> runlog.out 

    cp fort.15.coldstart ../../logs/$folder_name/$dateid/fort.15.coldstart
    rm -rf coldstart
    mkdir coldstart
    cd coldstart
    ln -sf ../fort.13
    ln -sf ../fort.14
    ln -sf ../fort.15.coldstart ./fort.15
    
    adcprep --np $nprocs --partmesh >> ../../../logs/$folder_name/$dateid/dateid.out
    adcprep --np $nprocs --prepall >> ../../../logs/$folder_name/$dateid/dateid.out
    mpirun -np $nprocs ~/adcirc/work/padcirc >> ../../../logs/$folder_name/$dateid/dateid.out
    clean_directory
    cd ..
}

run_hot_wind() {
    log="\t\t\t\t\t\t\t\t\t\t hotstart-wind run"
    echo -e $log >> runlog.out 
    
    cp fort.15.hotstart ../../logs/$folder_name/$dateid/fort.15.hotstart
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

    adcprep --np $nprocs --partmesh >> ../../../logs/$folder_name/$dateid/dateid.out
    adcprep --np $nprocs --prepall >> ../../../logs/$folder_name/$dateid/dateid.out
    mpirun -np $nprocs ~/adcirc/work/padcirc >> ../../../logs/$folder_name/$dateid/dateid.out
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