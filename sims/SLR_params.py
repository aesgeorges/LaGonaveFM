import numpy as np
import os
import shutil

# Define scenarios with SLR values
scenarios = {
    'S0': 0.0,
    'SSP1_2050': 0.23,
    'SSP1_2070': 0.35,
    'SSP1_2100': 0.52,
    'SSP2_2050': 0.25,
    'SSP2_2070': 0.39,
    'SSP2_2100': 0.65,
    'SSP3_2050': 0.25,
    'SSP3_2070': 0.42,
    'SSP3_2100': 0.75,
    'SSP5_2050': 0.27,
    'SSP5_2070': 0.45,
    'SSP5_2100': 0.84
}

# Base directory
base_dir = 'Gonave_SLR_mangrove'
template_fort13 = os.path.join(base_dir, 'S0/fort.13')

# Create directories and modified fort.13 files
for scenario_name, slr_value in scenarios.items():
    # Skip processing for the baseline scenario (S0) since we're using it as a template
    if scenario_name == 'S0':
        continue
    
    # Create scenario directory
    scenario_dir = os.path.join(base_dir, scenario_name)
    os.makedirs(scenario_dir, exist_ok=True)
    
    # Copy all necessary files from baseline
    for file in ['fort.14', 'fort.15.coldstart', 'fort.15.hotstart', 'driver.sh', 'fort.22']:
        src_file = os.path.join(base_dir, 'S0', file)
        if os.path.exists(src_file):
            shutil.copy2(src_file, scenario_dir)
    
    # Now handle fort.13 modification
    output_fort13 = os.path.join(scenario_dir, 'fort.13')
    
    # Read the original fort.13
    with open(template_fort13, 'r') as f:
        lines = f.readlines()
    
    # Extract header information
    header_lines = lines[0:3]  # First 3 lines (mesh name, node count, attribute count)
    
    # Update attribute count in the header
    num_attributes = int(header_lines[2].strip())
    
    # Check if sea_surface_height_above_geoid already exists
    ssh_exists = False
    for line in lines:
        if 'sea_surface_height_above_geoid' in line:
            ssh_exists = True
            break
    
    # If SSH doesn't exist, we'll need to increment the attribute count
    if not ssh_exists:
        header_lines[2] = f"{num_attributes + 1}\n"
    
    # Prepare to build the new file
    modified_lines = []
    modified_lines.extend(header_lines)  # Add header
    
    # Add sea_surface_height_above_geoid as the first attribute
    modified_lines.append("sea_surface_height_above_geoid\n")
    modified_lines.append("m\n")  # Units line
    modified_lines.append("1\n")  # Number of values per node
    modified_lines.append(f"{slr_value:.6f}\n")  # SLR value
    
    # Now add all remaining attributes from the original file
    # Skip the first 3 lines (header) and look for attribute lines
    current_line = 3
    attributes_added = 0
    
    while current_line < len(lines) and attributes_added < num_attributes:
        attribute_name = lines[current_line].strip()
        
        # Skip if this is sea_surface_height_above_geoid (we already added it)
        if 'sea_surface_height_above_geoid' in attribute_name:
            # Skip this attribute's lines (name, units, values per node, default)
            # Typically 4 lines, but could be more if there are exceptions listed
            lines_to_skip = 3  # name, units, values per node
            
            # Try to determine how many more lines to skip (looking for the default value line)
            # This is usually 1 more line, but could be more complex
            next_line = current_line + lines_to_skip
            if next_line < len(lines):
                try:
                    # Try to convert the next line to a float to identify the default value line
                    float(lines[next_line].strip())
                    lines_to_skip += 1
                except ValueError:
                    # If not a float, use our best guess
                    lines_to_skip += 1
            
            current_line += lines_to_skip
            attributes_added += 1
            continue
        
        # Add this attribute's lines
        # First add the attribute name
        modified_lines.append(f"{attribute_name}\n")
        current_line += 1
        
        # Add units line
        if current_line < len(lines):
            modified_lines.append(lines[current_line])
            current_line += 1
        
        # Add number of values per node
        if current_line < len(lines):
            modified_lines.append(lines[current_line])
            current_line += 1
        
        # Add default value
        if current_line < len(lines):
            modified_lines.append(lines[current_line])
            current_line += 1
        
        attributes_added += 1
    
    # Add any remaining lines (might be nodal attribute data, etc.)
    modified_lines.extend(lines[current_line:])
    
    # Write the modified file
    with open(output_fort13, 'w') as f:
        f.writelines(modified_lines)

print("All scenario directories and modified fort.13 files created successfully.")