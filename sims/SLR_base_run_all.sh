#!/bin/bash

# Base directory to setup all scenario folders in
echo Please input the folder name for the simulations you want to setup:
read BASE_DIR

LOG_FILE="${BASE_DIR}/run_all_scenarios.log"

echo "Starting simulations $(date)" > $LOG_FILE

SCENARIOS=(
    "S0"
    "SSP1_2030"
    "SSP1_2050"
    "SSP1_2070"
    "SSP1_2100"
    "SSP2_2030"
    "SSP2_2050"
    "SSP2_2070"
    "SSP2_2100"
    "SSP3_2030"
    "SSP3_2050"
    "SSP3_2070"
    "SSP3_2100"
    "SSP5_2030"
    "SSP5_2050"
    "SSP5_2070"
    "SSP5_2100"
)

run_all() {
    for scenario in "${SCENARIOS[@]}"; do
        scenario_dir="$BASE_DIR/$scenario"
        cd "$scenario_dir"
        
        chmod +x driver.sh

        LOG_FILE="../run_all_scenarios.log"
        echo "Starting run for scenario: $scenario at $(date)" | tee -a $LOG_FILE

        # Start a background process to display log updates
        (
            while true; do
                tput clear
                echo "=== Running scenario: $scenario  for $BASE_DIR ==="
                tail -n 20 driver_output.log
                sleep 1
            done
        ) &
        TAIL_PID=$!

        start_time=$(date +%s)

        ./driver.sh &> driver_output.log
        EXIT_CODE=$?
        end_time=$(date +%s)
        runtime=$((end_time - start_time))
        hours=$((runtime / 3600))
        minutes=$(( (runtime % 3600) / 60 ))
        seconds=$((runtime % 60))
        echo "Scenario $scenario runtime: ${hours}h ${minutes}m ${seconds}s" | tee -a $LOG_FILE

        if [ $EXIT_CODE -eq 0 ]; then
            echo "Scenario $scenario completed successfully at $(date)" | tee -a $LOG_FILE
        else
            echo "Warning: Scenario $scenario failed with exit code $EXIT_CODE at $(date)" | tee -a $LOG_FILE
        fi

        echo "All scenario runs completed at $(date)" | tee -a $LOG_FILE

        kill $TAIL_PID
        wait $TAIL_PID 2>/dev/null

        cd "../../"
    done
    echo "All $BASE_DIR simulations completed at $(date)" | tee -a $LOG_FILE
}

run_all
