
#!/bin/bash

current_dir=$(pwd)
subdomain_dir=$current_dir/s1_gonave
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

cp ../../../scripts/fort22fix.py fort22fix.py
python fort22fix.py

cp ../../../scripts/run_new.sh run.sh
cp ../../../scripts/slurmcold.sh slurm.sh

current_dir=$(pwd)
folder_name=$(basename $current_dir)
sed -i "s/^#SBATCH --job-name=.*$/#SBATCH --job-name=$folder_name/" slurm.sh

# subdomain file structure setup
mkdir s1_gonave
subdomain_dir=$current_dir/s1_gonave
cp ../../../datasets/s1_gonave/shape.e14 s1_gonave/shape.e14
# remove BOM (\ufeff) from shape.e14
sed -i '1s/^\xef\xbb\xbf//' s1_gonave/shape.e14

source ~/anaconda3/etc/profile.d/conda.sh  # Adjust the path to your Conda installation
conda activate py2
python2.7 ../../../scripts/gensub.py $current_dir $subdomain_dir

chmod +x run.sh slurm.sh 

