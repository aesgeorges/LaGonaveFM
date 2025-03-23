#!/bin/bash

INPUT_FILE='fort.22'
TEMP_FILE='fort.22.temp'
OUTPUT_FILE='fort.22.fixed'

echo "Checking for timestep issues in $INPUT_FILE file"

DATE_TIMES=$(awk -F, '{print $3}' "$INPUT_FILE" | sort -u)
DATE_TIME_COUNT=$(echo "$DATE_TIMES" | wc -l)

echo "Found $DATE_TIME_COUNT unique time points."

ISSUE_COUNT=0

FIRST_DT=$(awk -F, '{print $3; exit}' "$INPUT_FILE" | tr -d ' \t\r\n')
echo "First date-time: $FIRST_DT"

for dt in $DATE_TIMES; do
    # Count instances of this datetime
    DISTINCT_HOURS=$(grep "$dt" "$INPUT_FILE" | awk -F, '{print $5}' | sort -u | wc -l)
    # Check if the timesteps are consistent with the datetimes
    if [ "$DISTINCT_HOURS" -gt 1 ]; then
        echo "Warning: Date-time $dt has $DISTINCT_HOURS different forecast hours."
        ISSUE_COUNT=1
    fi
    # Count isotachs for this datetime (must be less than 4)
    ISOTACH_COUNT=$(grep "$dt" "$INPUT_FILE" | wc -l)
    if [ "$ISOTACH_COUNT" -gt 4 ]; then
        echo "Warning: Date-time $dt has $ISOTACH_COUNT isotachs (max allowed is 4)."
        ISSUE_COUNT=1
    fi
    # Check if all entries for this datetime have a timestep=0 (this is the most common issue)
    TS_ZERO=$(grep "$dt" "$INPUT_FILE" | awk -F, '$6 == 0 {count++} END {print count}')
    # Skip the first datetime (we maintain a counter using a static variable in awk)
    if [ "$dt" != "$FIRST_DT" ] && [ "$TS_ZERO" -eq "$ISOTACH_COUNT" ] && [ "$ISOTACH_COUNT" -gt 1 ]; then
        echo "Issue: Date-time $dt has all timesteps set to 0. Must be adjusted."
        ISSUE_COUNT=1
    fi
done

if [ "$ISSUE_COUNT" -eq 0 ]; then
    echo "Script has detected no issues forecast timesteps or isotach counts."
    exit 0
fi

echo "Fixing fort.22 ..." 

> "fort.22.temp"

# Process the file by date-time
current_dt=""
forecast_hour=0

# Sort the input file by date-time first and remove any blank lines
sort -t, -k3,3 "$INPUT_FILE" | grep -v '^[[:space:]]*$' | while IFS= read -r line; do
    # Skip empty lines
    [ -z "$line" ] && continue
    
    # Extract the date-time
    dt=$(echo "$line" | awk -F, '{print $3}')
    
    # If this is a new date-time, increment the forecast hour
    if [ "$dt" != "$current_dt" ]; then
        if [ -n "$current_dt" ]; then  # Skip increment for first date-time
            forecast_hour=$((forecast_hour + 6))
        fi
        current_dt="$dt"
    fi
    
    # Format the forecast hour with leading spaces to match original format
    formatted_hour=$(printf "%4d" $forecast_hour)
    
    # Replace the forecast hour in the line and ensure no empty fields
    new_line=$(echo "$line" | awk -F, -v hour="$formatted_hour" '{OFS=","; $6=hour; print $0}' | sed 's/^,//;s/,,*/,/g')
    
    # Write the modified line to the temp file
    echo "$new_line" >> "$TEMP_FILE"
done

mv "$TEMP_FILE" "$OUTPUT_FILE"
echo "Fixed file saved as $OUTPUT_FILE"
echo "Please verify the fixed file before using it with ADCIRC. If correct, feel free to copy its contents to fort.22."