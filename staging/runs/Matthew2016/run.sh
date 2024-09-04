## Command(s) to run

dateid=$(date '+%d%m%y-%H%M')
dt=$(sed -n '22p' fort.15 | awk '{print $1}')
log="$dateid\t\t\t$dt\t\t\t coldstart-full"
echo -e $log >> runlog.out 

current_dir=$(pwd)
folder_name=$(basename $current_dir)

mkdir ../../logs/$folder_name/$dateid
cp fort.15 ../../logs/$folder_name/$dateid/fort.15

adcprep --np 10 --partmesh > ../../logs/$folder_name/$dateid/dateid.out
adcprep --np 10 --prepall >> ../../logs/$folder_name/$dateid/dateid.out
mpirun -np 10 ~/adcirc/work/padcirc >> ../../logs/$folder_name/$dateid/dateid.out