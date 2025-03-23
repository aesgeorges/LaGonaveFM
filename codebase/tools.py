import numpy as np
import pandas as pd

def make_transect(radii, angle, center_x, center_y):
    """"
    Generates a transect of points with distance between points given by a radius."

    Parameters:
    - radii: list, list of radii from the end of the transect.
    - angle: float, angle of the transect.
    - center_x: float, x-coordinate of the center of the transect arcs.
    - center_y: float, y-coordinate of the center of the transect arcs.

    Returns:
    - pd.DataFrame: DataFrame containing the generated transect points with columns 'lon' and 'lat'.
    """
    xs = []
    ys = []
    for i, radius in enumerate(radii):
        xs.append(center_x + radius * np.cos(angle))
        ys.append(center_y + radius * np.sin(angle))

    transect = pd.DataFrame({'lon': xs, 'lat': ys})
    
    return transect


def get_hurricane_track(filepath):
    """
    Parses the fort.22 file and extracts latitude, longitude, and time data.

    Parameters:
    - filepath (str): Path to the fort.22 file.

    Returns:
    - pd.DataFrame: A DataFrame containing the extracted data with columns 'Time', 'Latitude', and 'Longitude'.
    """
    with open(filepath, 'r') as f:
        lines = f.readlines()

    lats = []
    lons = []
    times = []

    for i in range(0, len(lines), 3):  # Process every 3rd line (first entry for each time)
        if i >= len(lines):
            break

        line = lines[i]
        parts = line.split(',')

        # Extract latitude
        lat_str = parts[6].strip()
        lat_val = float(lat_str[:-1]) / 10.0  # Convert to decimal degrees

        # Extract longitude
        lon_str = parts[7].strip()
        lon_val = -float(lon_str[:-1]) / 10.0  # Negative for W longitude

        # Extract time
        time_str = parts[2].strip()

        lats.append(lat_val)
        lons.append(lon_val)
        times.append(time_str)

    return pd.DataFrame({
        'Time': times,
        'Latitude': lats,
        'Longitude': lons
})
