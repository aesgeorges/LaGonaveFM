#!/bin/bash

# Define source directory
source_path="../Gonave_SLR_mangrove"
destination_path="r3"

# List of specific directories to process
directories=("S0" "SSP2_2030" "SSP2_2100" "SSP5_2030" "SSP5_2100")

# Ask user to select a directory
echo "Select a directory:"
select dir in "${directories[@]}"; do
    mkdir -p "$destination_path"/"$dir"
    cp "$source_path"/"$dir"/fort.13 "$destination_path"/"$dir"/fort.13
    cp "$source_path"/"$dir"/fort.14 "$destination_path"/"$dir"/fort.14
    cp "$source_path"/"$dir"/fort.15.coldstart "$destination_path"/"$dir"/fort.15.coldstart
    cp "$source_path"/"$dir"/fort.15.hotstart "$destination_path"/"$dir"/fort.15.hotstart
    cp "$source_path"/"$dir"/fort.22 "$destination_path"/"$dir"/fort.22
    cp "$source_path"/"$dir"/init.sh "$destination_path"/"$dir"/init.sh
    cp "$source_path"/"$dir"/driver.sh "$destination_path"/"$dir"/driver.sh
    echo "Files moved successfully to $destination_path/$dir"
    break  
done