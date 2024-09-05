
#!/bin/bash

# Rename and modify fort.15 for netcdf output and wind run
mv fort.15.coldstart fort.15

replacement_ele="-3 0.000000 15.000000 20                              ! NOUTGE"
replacement_vel="-3 0.000000 15.000000 20                              ! NOUTGV"
rep_NWS="8                                                               ! NWS"
storm_ref="2016 09 28 18 1 0.7 1                                           ! IREFYR IREFMO IREFDAY IREFHR StormNumber BLAdj GEOFACTOR"
metstation="0 0 0 0                                                         ! NOUTM TOUTSM TOUTFM NSPOOLM         - MET STATION OUTPUT INFO (UNIT 71 and 72)"
nstam="0                                                               ! NSTAM"
wind_output="-3 0.000000 15.000000 20                              ! NOUTGW TOUTSGW TOUTFGW NSPOOLGW     - GLOBAL WIND STRESS AND ATM PRESSURE OUTPUT INFO (UNIT 73 and 74)"

sed -i "s/0 0.000000 0.000000 0                                           ! NOUTGE/$replacement_ele/" fort.15
sed -i "s/0 0.000000 0.000000 0                                           ! NOUTGV/$replacement_vel/" fort.15
sed -i "s/0                                                               ! NWS/$rep_NWS/" fort.15
sed -i "/0                                                               ! REFTIM/a\
$storm_ref" fort.15
sed -i "/110                                                             ! ANGINN/a\
$metstation\n\
$nstam" fort.15
sed -i "/-3 0.000000 15.000000 20                              ! NOUTGV/a\
$wind_output" fort.15


current_dir=$(pwd)
folder_name=$(basename $current_dir)

mkdir ../../logs
mkdir ../../logs/$folder_name
log_header="Logs of run attempts and their parameters."
log_header2="Hurricane Isaias2020"
log_header3="------------------------------------------"
log_header4="id\t\t\t\t\t\tdt\t\t\t\t\t\ttype\t\t\t\t\t\tcomment"
echo -e $log_header > runlog.out
echo -e $log_header2 >> runlog.out
echo -e $log_header3 >> runlog.out
echo -e $log_header4 >> runlog.out

# call aswip to format fort.22 proper
aswip -n 20 -m 4 -z 2
mv fort.22 ../../logs/$folder_name/fort.22
mv NWS_20_fort.22 fort.22

cp ../../../scripts/run.sh run.sh
cp ../../../scripts/slurmcold.sh slurmcold.sh
cp ../../../scripts/slurmhot.sh slurmhot.sh

current_dir=$(pwd)
folder_name=$(basename $current_dir)
sed -i "s/^#SBATCH --job-name=.*$/#SBATCH --job-name=$folder_name/" slurmcold.sh
sed -i "s/^#SBATCH --job-name=.*$/#SBATCH --job-name=$folder_name hot/" slurmhot.sh

chmod +x run.sh slurmcold.sh slurmhot.sh
