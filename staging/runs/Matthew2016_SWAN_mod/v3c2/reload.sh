#!/bin/bash

ulimit -s unlimited

set -e

NPROCS=8

main() {
  SECONDS=0
  #run_coldstart_phase
  if grep -Rq "ERROR: Elevation.gt.ErrorElev, ADCIRC stopping." padcirc.log; then
    duration=$SECONDS
    echo "ERROR: Elevation.gt.ErrorElev, ADCIRC stopping."
    echo "Wallclock time: $(($duration / 60)) minutes and $(($duration % 60)) seconds."
    exit -1
  else
    #run_hotstart_phase
    run_swan
    duration=$SECONDS
    if grep -Rq "ERROR: Elevation.gt.ErrorElev, ADCIRC stopping." padcswan.log; then
      echo "ERROR: Elevation.gt.ErrorElev, ADCIRC stopping."
      echo "Wallclock time: $(($duration / 60)) minutes and $(($duration % 60)) seconds."
      exit -1
    fi
  fi
  echo "Wallclock time: $(($duration / 60)) minutes and $(($duration % 60)) seconds."
}

run_swan() {
  rm -rf hotstart_swan
  mkdir hotstart_swan
  cd hotstart_swan
  ln -sf ../fort.14
  ln -sf ../fort.13
  ln -sf ../fort.26
  ln -sf ../swaninit
  ln -sf ../fort.15.hotstart ./fort.15
  ln -sf ../coldstart/fort.67.nc
  ln -sf ../fort.22 ./fort.22
  aswip
  mv NWS_20_fort.22 fort.22
  adcprep --np 8 --partmesh
  adcprep --np 8 --prepall
  mpiexec -n 8 padcswan 2>&1 | tee ../padcswan.log
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
