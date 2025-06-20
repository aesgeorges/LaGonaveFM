"""
Retreat Analysis Module for Mangrove Retreat + SLR Impact on Storm Surge Attenuation

Written by: Alexandre Erich Sebastien Georges
University of California, Berkeley

June 2025
"""

import os
import numpy as np
import pandas as pd
import netCDF4 as netcdf
import matplotlib.pyplot as plt
import matplotlib.colors as colors
import matplotlib.patches as mpatches
from matplotlib.lines import Line2D
import matplotlib.patheffects as path_effects
import cartopy.crs as ccrs
import cartopy.feature as cf
import geopandas as gpd
import xarray as xr
import rasterio as rio
import rioxarray as rxr
import fiona
from shapely.geometry import shape
import cmocean
import math
from typing import Dict, List, Tuple, Optional
from pathlib import Path


class Retreat:
    """
    A class to handle importing, processing and analyzing mangrove retreat scenarios.
    """
    
    def __init__(self,
                 retreat_id: str,
                 inun_path: str,
                 cover_path: str,
                 slr_scenarios: List[str] = ['ssp2', 'ssp5'],
                 horizons: List[int] = [2030, 2100],
                 data: Dict = None,
                 ):
        """
        Initialize the Retreat object with the given parameters.

        :param retreat_id: Unique identifier for the retreat scenario.
        :param path: Path to the directory containing the retreat data.
        :param cover_path: Path to mangrove cover data.
        """

        self.retreat_id = retreat_id
        self.inun_path = Path(inun_path)
        self.cover_path = Path(cover_path)
        self.slr_scenarios = slr_scenarios
        self.horizons = horizons
        self.data = None
        self.cover_geometry = None
        # Load Cover Geometry Data
        if cover_path is None:
            raise ValueError("Cover path must be provided.")
        else:
            self.load_cover_geometry()
        
        # Load data
        self.data = self.load_all_scenarios(self.inun_path)


    def load_cover_geometry(self):
        """
        Load the mangrove cover geometry from the provided path.
        """
        try:
            with fiona.open(self.cover_path, 'r') as src:
                cover_data = pd.DataFrame([feature['properties'] for feature in src])
                cover_data['geometry'] = [shape(feature['geometry']) for feature in src]
            self.cover_geometry = gpd.GeoDataFrame(cover_data, geometry='geometry')
        except Exception as e:
            raise ValueError(f"Error loading mangrove cover geometry: {e}")
        
    
    def load_data(self, inun_root: str, scenario: str, year: int) -> xr.Dataset:
        """
        Load the inundation data for a given retreat+slr scenario.
        
        Parameters:
        inun_root (str): 
            The root path to the inundation data directory.
        scenario (str): 
            The IPCC SLR scenario to load data for (e.g., 'ssp2', 'ssp5').
        year (int): 
            The horizon year of the scenario to load data for (e.g., 2030, 2100).
        
        Returns:
            xr.Dataset: The loaded dataset containing inundation raster data.
        """

        tail = '_flood_depths_exported.tif'
        file_path = f'{inun_root}/r{self.retreat_id}/r{self.retreat_id}_{scenario}_{year}{tail}'

        try: 
            ds = rxr.open_rasterio(file_path).squeeze()
            return ds
        except Exception as e:
            raise ValueError(f"Error loading inundation data for {self.retreat_id}, {scenario}, {year}: {e}")
            return None 
        

    def load_base_data(self, inun_root: str) -> xr.Dataset:
        """
        Load the base inundation data for the retreat.

        Parameters:
        inun_root (str):  
            The root path to the inundation data directory.

        Returns:
            xr.Dataset: The base dataset containing inundation raster data.
        """
        tail = '_flood_depths_exported.tif'
        file_path = f'{inun_root}/r{self.retreat_id}/r{self.retreat_id}_s0{tail}'

        try: 
            ds = rxr.open_rasterio(file_path).squeeze()
            return ds
        except Exception as e:
            raise ValueError(f"Error loading baseline inundation data for {self.retreat_id}: {e}")
            return None 


    def load_all_scenarios(self, inun_root: str) -> Dict:

        
        """
        Load all inundation scenarios for the retreat.

        Parameters:
        inun_root (str):  
            The root path to the inundation data directory.

         Returns:
            Dict[xr.Dataset]: Dictionary of datasets keyed by (scenario, year).
        """
        datasets = {}
        datasets['s0', 0] = self.load_base_data(inun_root)
        for scenario in self.slr_scenarios:
            for year in self.horizons:
                ds = self.load_data(inun_root, scenario, year)
                if ds is not None:
                    datasets[(scenario, year)] = ds
        return datasets


    def calculate_pixel_area(lat, pixel_width_deg, pixel_height_deg):
        """Calculate area of a WGS84 pixel in square meters given its latitude and dimensions in degrees"""
        # WGS84 ellipsoid parameters
        a = 6378137.0  # Semi-major axis (equatorial radius) in meters
        b = 6356752.314245  # Semi-minor axis (polar radius) in meters
        e_sq = 1 - (b*b)/(a*a)  # Eccentricity squared
        
        # Calculate meters per degree
        lon_meters_per_deg = (math.pi/180) * a * math.cos(math.radians(lat)) / math.sqrt(1 - e_sq * math.pow(math.sin(math.radians(lat)), 2))
        lat_meters_per_deg = (math.pi/180) * a * (1 - e_sq) / math.pow(1 - e_sq * math.pow(math.sin(math.radians(lat)), 2), 1.5)
        
        # Calculate area
        return pixel_width_deg * lon_meters_per_deg * pixel_height_deg * lat_meters_per_deg


    def calculate_flood_area(raster_path):
        # Open the raster file
        with rio.open(raster_path) as src:
            # Get the transform and dimensions
            transform = src.transform
            height = src.height
            width = src.width
            
            # Extract the pixel width and height in degrees
            pixel_width_deg = abs(transform[0])
            pixel_height_deg = abs(transform[4])
            
            # Read the raster data
            data = src.read(1).astype(float)  # Assuming single band raster and we're working with float type that can handle NaN
            data[data == -99999.0] = np.nan
            
            # Create a mask of valid (non-NaN) pixels
            valid_mask = ~np.isnan(data)
            valid_count = np.sum(valid_mask)
            
            # Get bounds
            bounds = src.bounds
            
            # Calculate total area of non-NaN pixels
            total_area = 0
            
            # Create an array of latitudes for each row
            # First, get the latitude of the top edge
            top_lat = bounds.top
            
            # For each row, calculate the latitude at the center of the pixels
            for row in range(height):
                # Calculate latitude at the center of this row of pixels
                # (subtract half a pixel to get to the center of the first pixel,
                # then subtract the appropriate number of pixels for the current row)
                row_lat = top_lat - (pixel_height_deg * (row + 0.5))
                
                # Calculate pixel area at this latitude
                pixel_area = calculate_pixel_area(row_lat, pixel_width_deg, pixel_height_deg)
                
                # Count valid pixels in this row and add their area to the total
                valid_pixels_in_row = np.sum(valid_mask[row, :])
                total_area += valid_pixels_in_row * pixel_area
            
            #print(f"Number of valid (non-NaN) pixels: {valid_count}")
            #print(f"Total area of valid pixels: {total_area:.2f} square meters ({total_area/1000000:.4f} square kilometers)")

            return total_area, valid_count
    

    def get_flood_statistics(self, scenarios: List[str], years: List[int] = None) -> pd.DataFrame:
        """
        Get flood area statistics for multiple scenarios.
        
        Parameters:
        scenarios : List[str]
            List of scenario identifiers
        years : List[str], optional
            List of years for each scenario
            
        Returns:
        pd.DataFrame
            Dataframe with flood area statistics
        """
        results = []
        
        for scenario in scenarios:
            for year in years:
                tail = '_flood_depths_exported.tif'
                file_path = f'{self.inun_root}/r{self.retreat_id}/r{self.retreat_id}_{scenario}_{year}{tail}'
                area, pixels = self.calculate_flood_area(file_path)
                results.append({
                    'retreat_id': self.retreat_id,
                    'scenario': scenario,
                    'year': year,
                    'area_km2': area / 1000000,
                    'area_m2': area,
                })
        
        return pd.DataFrame(results)