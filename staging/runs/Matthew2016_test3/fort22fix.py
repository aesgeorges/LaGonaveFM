import pandas as pd
import subprocess

df = pd.read_csv('fort.22', header=None)
dates_str = df.iloc[:, 2]
dates = pd.to_datetime(dates_str, format='%Y%m%d%H')
first_date = dates[0]
timedeltas = (dates - first_date).apply(lambda x: str(int(x.total_seconds()/3600)))

# Read the original file into memory
with open('fort.22', 'r') as file:
    lines = file.readlines()

# Open the file in write mode to overwrite it
with open('fort.22', 'w') as file:
    for i, line in enumerate(lines[1:]):
        old_delta = rf"""BEST,   0,"""
        new_delta = rf"""BEST,   {timedeltas[i]},"""
        if int(timedeltas[i]) >= 10:
            new_delta = rf"""BEST,  {timedeltas[i]},"""
        if int(timedeltas[i]) >= 100:
            new_delta = rf"""BEST, {timedeltas[i]},"""
        if int(timedeltas[i]) >= 1000:
            new_delta = rf"""BEST,{timedeltas[i]},"""
        modified_line = line.replace(old_delta, new_delta)
        file.write(modified_line)