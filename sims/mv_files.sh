#!/bin/bash


TRACK_PATH="../hurricane_track_gen/${TRACK}"

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

move_f22() {
  echo Input base directory for scenarios: e.g., Gonave_SLR_mangrove_t2
  read BASE_DIR

  echo Input correct matthew track: e.g., matthew_track1.22, matthew_track2.22 or matthew_track3.22
  read TRACK


  for scenario in "${SCENARIOS[@]}"; do
    scenario_dir="$BASE_DIR/$scenario"
    cd "$scenario_dir"

    cp "../../$TRACK_PATH" fort.22
    echo "Copying $TRACK in $scenario_dir"
    cd "../../"

  done  
}

move_f13() {
  echo are you copying in mangrove [1/m] or no mangrove [2/nm]?
  read MANGROVE

  if [ "$MANGROVE" == "1" ] || [ "$MANGROVE" == "m" ]; then
    echo Input base directory for populating mangrove scenarios: e.g., Gonave_SLR_mangrove_t2
    read BASE_DIR
    F13_DIR="../mannings_cover_gen/mangrove/"
  elif [ "$MANGROVE" == "2" ] || [ "$MANGROVE" == "nm" ]; then
    echo Input base directory for no mangrove scenarios: e.g., Gonave_SLR_nomangrove_t2
    read BASE_DIR
    F13_DIR="../mannings_cover_gen/nomangrove/"
  else
    echo "Invalid input. Please enter '1' for mangrove or '2' for no mangrove."
    return 1
  fi

  for scenario in "${SCENARIOS[@]}"; do
    echo "Copying $scenario.13 from $F13_DIR to $BASE_DIR"
    cp "$F13_DIR/$scenario.13"* "$BASE_DIR/$scenario/fort.13"
  done
}

move_f13
