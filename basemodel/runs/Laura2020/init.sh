
#!/bin/bash

# Rename and modify fort.15 for netcdf output and wind run
mv fort.15.coldstart fort.15

replacement_ele="-3 0.000000 15.000000 20                              ! NOUTGE"
replacement_vel="-3 0.000000 15.000000 20                              ! NOUTGV"

sed -i "s/0 0.000000 0.000000 0                                           ! NOUTGE/$replacement_ele/" fort.15
sed -i "s/0 0.000000 0.000000 0                                           ! NOUTGV/$replacement_vel/" fort.15


current_dir=$(pwd)
folder_name=$(basename $current_dir)

mkdir ../../logs
mkdir ../../logs/$folder_name
log_header="Logs of run attempts and their parameters."
log_header2="Hurricane Laura2020"
log_header3="------------------------------------------"
log_header4="id\t\t\t\t\t\tdt\t\t\t\t\t\ttype\t\t\t\t\t\tcomment"
echo -e $log_header > runlog.out
echo -e $log_header2 >> runlog.out
echo -e $log_header3 >> runlog.out
echo -e $log_header4 >> runlog.out

cp ../../../scripts/run.sh run.sh
cp ../../../scripts/slurmcold.sh slurmcold.sh
cp ../../../scripts/slurmhot.sh slurmhot.sh

current_dir=$(pwd)
folder_name=$(basename $current_dir)
sed -i "s/^#SBATCH --job-name=.*$/#SBATCH --job-name=$folder_name base/" slurmcold.sh
sed -i "s/^#SBATCH --job-name=.*$/#SBATCH --job-name=$folder_name base hot/" slurmhot.sh

chmod +x run.sh slurmcold.sh slurmhot.sh
