#!/bin/bash

nprocs=6

main() {
    dateid=$(date '+%d%m%y-%H%M')
    dt=$(sed -n '22p' fort.15.coldstart | awk '{print $1}')
    log="$dateid\t\t\t$dt\t\t\t hurricane 2-phase run"
    echo -e $log >> runlog.out 

    current_dir=$(pwd)
    folder_name=$(basename $current_dir)

    mkdir -p ../../logs/$folder_name/$dateid

    read -p "Is this a subdomain run? (y/n): " choice
    case $choice in
        y|Y ) subdomain_setup
              subdomain "$folder_name" "$dateid";;
        n|N ) fulldomain "$folder_name" "$dateid";;
        * ) echo "Invalid choice. Exiting..."; exit 1;;
    esac
}

fulldomain() {
    folder_name=$1
    dateid=$2
    echo -e "Cold start spinup run with tides ................ " > ../../logs/$folder_name/$dateid/$dateid.out
    run_cold_spinup "../../../logs/$folder_name/$dateid"
    echo -e "Hot start run with wind/hurricane forcing ................ " >> ../../logs/$folder_name/$dateid/$dateid.out
    run_hot_wind "../../../logs/$folder_name/$dateid"
}

subdomain() {
    folder_name=$1
    dateid=$2
    current_dir=$(pwd)
    subdomain_dir=$current_dir/s1_gonave
    source ~/anaconda3/etc/profile.d/conda.sh
    conda activate py2

    ### We can remove the subdomain generation as it is already handled by the init.sh script
    # generate subdomain
    echo -e "generating subdomain"
    python2.7 ../../../scripts/gensub.py "$current_dir" "$subdomain_dir"

    cp fort.15.coldstart coldstart/fort.15
    cp fort.15.hotstart hotstart/fort.15

    # Geenrate full domain control file
    echo -e "generating full domain control file"

    # run adcirc on full domain (cold spinup followed by hot wind)
    echo -e "running adcirc on full domain"
    run_cold_spinup "../../../logs/$folder_name/$dateid"
    run_hot_wind "../../../logs/$folder_name/$dateid"

    # remap boundary nodes numbers
    echo -e "remapping boundary nodes numbers"
    echo -e "calling remap.py"
    python2.7 ../../../scripts/remap.py hotstart/ "$subdomain_dir"
    # extract subdomain boundary conditions for ADCIRC
    echo -e "extracting subdomain boundary conditions"
    python2.7 ../../../scripts/genbcs.py hotstart/ "$subdomain_dir" 

    # run adcirc on subdomain
    """ copy fort.15 into subdomain, most likely the hotstart one. """ 
    echo -e "running adcirc on subdomain"
    cd s1_gonave
    adcirc
    #run_cold_spinup "../../../../logs/$folder_name/$dateid"
    #run_hot_wind "../../../../logs/$folder_name/$dateid"
}

subdomain_setup() {
    # Find and replace the specific lines at the end of the file
    sed -i '
    /&metControl.*WindDragLimit/ {
        c\&metControl \
WindDragLimit=0.0025, \
DragLawString="default", \
outputWindDrag=F, \
invertedBarometerOnElevationBoundary=T \
/\
&subdomainModeling \
subdomainOn=T, /
}' fort.15.coldstart fort.15.hotstart

    #echo -e "&subdomainModeling subdomainOn=T /" >> fort.15.coldstart
    #echo -e "&subdomainModeling subdomainOn=T /" >> fort.15.hotstart
    ln -sf ../fort.22 s1_gonave/fort.22
}

run_cold_spinup() {
    logpath=$1
    log="\t\t\t\t\t\t\t\t\t\t coldstart-spinup"
    echo -e $log >> runlog.out 

    cp fort.15.coldstart "$logpath/fort.15.coldstart"
    rm -rf coldstart
    mkdir coldstart

    mv fort.15.coldstart fort.15
    python2.7 -i ../../../scripts/genfull.py .
    mv fort.15 fort.15.coldstart

    cd coldstart
    ln -sf ../fort.13
    ln -sf ../fort.14
    ln -sf ../fort.015
    ln -sf ../fort.15.coldstart ./fort.15
    
    adcprep --np $nprocs --partmesh >> "$logpath/dateid.out"
    adcprep --np $nprocs --prepall >> "$logpath/dateid.out"
    mpirun -np $nprocs ~/adcirc/work/padcirc >> "$logpath/dateid.out"
    clean_directory
    cd ..
}

run_hot_wind() {
    logpath=$1
    log="\t\t\t\t\t\t\t\t\t\t hotstart-wind run"
    echo -e $log >> runlog.out 
    
    cp fort.15.hotstart "$logpath/fort.15.hotstart"
    rm -rf hotstart
    mkdir hotstart

    mv fort.15.hotstart fort.15
    python2.7 -i ../../../scripts/genfull.py .
    mv fort.15 fort.15.hotstart

    cd hotstart
    ln -sf ../fort.14
    ln -sf ../fort.13
    ln -sf ../fort.15.hotstart ./fort.15
    ln -sf ../fort.015
    ln -sf ../coldstart/fort.67.nc
    ln -sf ../fort.22 ./fort.22
    aswip -n 20 -m 4 -z 2
    mv NWS_20_fort.22 fort.22

    adcprep --np $nprocs --partmesh >> "$logpath/dateid.out"
    adcprep --np $nprocs --prepall >> "$logpath/dateid.out"
    mpirun -np $nprocs ~/adcirc/work/padcirc >> "$logpath/dateid.out"
    clean_directory


    cd ..
}

clean_directory() {
    rm -rf PE*
    #rm -rf partmesh.txt
    #rm -rf metis_graph.txt
    #rm -rf fort.13
    #rm -rf fort.14
    #rm -rf fort.15
    #rm -rf fort.16
    #rm -rf fort.80
    #rm -rf fort.68.nc
}

main
