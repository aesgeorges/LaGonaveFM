
#!/bin/bash

current_dir=$(pwd)
folder_name=$(basename $current_dir)

mkdir ../../logs
mkdir ../../logs/$folder_name
log_header="Logs of run attempts and their parameters."
log_header2="Hurricane $folder_name"
log_header3="------------------------------------------"
log_header4="id\t\t\t\t\t\tdt\t\t\t\t\t\ttype\t\t\t\t\t\tcomment"
echo -e $log_header > runlog.out
echo -e $log_header2 >> runlog.out
echo -e $log_header3 >> runlog.out
echo -e $log_header4 >> runlog.out

cp ../../../scripts/run_base.sh run.sh
cp ../../../scripts/slurmcold.sh slurmcold.sh
cp ../../../scripts/slurmhot.sh slurmhot.sh

current_dir=$(pwd)
folder_name=$(basename $current_dir)
sed -i "s/^#SBATCH --job-name=.*$/#SBATCH --job-name=$folder_name/" slurmcold.sh
sed -i "s/^#SBATCH --job-name=.*$/#SBATCH --job-name=$folder_name hot/" slurmhot.sh

chmod +x run.sh slurmcold.sh slurmhot.sh
