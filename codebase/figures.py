import cmocean
import numpy as np
import netCDF4 as netcdf
import matplotlib.pyplot as plt
from tqdm import tqdm
from kalpana.plotting import plot_nc
from kalpana.export import fort14togdf
from kalpana.ADCIRC_tools import extract_ts_from_nc
import cartopy.crs as ccrs
import cartopy.feature as cfeature
import matplotlib as mpl

def plot_transects(mesh, center_x, center_y, num_points, transects):
    """
    Plots all transects' observation points on the mesh.

    Parameters:
    - mesh       : geopandas.GeoDataFrame, data for plotting the background mesh.
    - center_x   : float, x-coordinate of the center of the transect arcs.
    - center_y   : float, y-coordinate of the center of the transect arcs.
    - num_points : int, number of transects to plot.
    - transects  : list, list of transect dataframes containing longitude and latitude.

    Returns:
    - fig        : matplotlib.figure.Figure, the generated figure.
    - ax         : matplotlib.axes.Axes, the plot axis.
    """
    fig, ax = plt.subplots(figsize = (10,8), subplot_kw={'projection': ccrs.PlateCarree()})
    ax.set_xlim(-73.5, -72.2)
    ax.set_ylim(18.75, 19.75)

    mesh.plot(ax=ax)
    ax.scatter(center_x, center_y, color = 'k', marker = '+', s = 15, zorder=5)

    for i in range(num_points):
        ax.scatter(transects[i].lon, transects[i].lat, color = 'k', marker = '+', s = 15, zorder=5)
    gl = ax.gridlines(crs=ccrs.PlateCarree(), draw_labels=True, alpha=0.5, linestyle='--')
    gl.top_labels = False
    gl.right_labels = False
    gl.xlocator = mpl.ticker.MaxNLocator(nbins=5)
    gl.ylocator = mpl.ticker.MaxNLocator(nbins=5)

    return fig, ax


def plot_transect_data(transect_id, timestep, transects, nc, nc_wind, mesh):
    """
    Plots water elevation along a specified transect with an inset map showing the transect location.

    Parameters:
    - transect_id : int, ID of the transect to plot.
    - timestep    : int, timestep to extract data for.
    - transects   : list, list of transect dataframes containing longitude and latitude.
    - nc          : netCDF4.Dataset, NetCDF dataset containing water elevation data.
    - nc_wind     : netCDF4.Dataset, NetCDF dataset containing wind data.
    - mesh        : geopandas.GeoDataFrame, mesh data for plotting the inset map.

    Returns:
    - fig         : matplotlib.figure.Figure, the generated figure.
    - ax_main     : matplotlib.axes.Axes, the main plot axis.
    - ax_inset    : matplotlib.axes.Axes, the inset map axis
    """
    fig, ax_main = plt.subplots(figsize=(10, 6), dpi=800)
    ax_inset = fig.add_axes([0.17, 0.15, 0.38, 0.38], projection=ccrs.PlateCarree())  # [x, y, width, height] for inset

    # Extract water elevation data along the transect
    dfout, rep = extract_ts_from_nc(nc, list(zip(transects[transect_id].lon, transects[transect_id].lat)), variable='zeta', extractOut=False, closestIfDry=False)  
    time = dfout.iloc[timestep].name
    tr_elev = dfout.iloc[timestep].values  # Water elevation along the transect

    # Main plot
    ax_main.axhline(0, color='red', linestyle='--', linewidth=1)
    ax_main.grid(True)
    ax_main.set_title('Water elevation along transect at '+str(time))
    ax_main.plot(transects[transect_id].lon, tr_elev)
    ax_main.set_xlabel('Longitude along transect')
    ax_main.set_ylabel('Water Elevation')
    ax_main.set_xlim(transects[transect_id].lon.min(), transects[transect_id].lon.max())
    ax_main.set_ylim(-0.5, 2.0)

    # Inset plot
    for i in range(len(transects)):
        ax_inset.plot(transects[i].lon, transects[i].lat, 
                      transform=ccrs.PlateCarree(), color='k', alpha=0.2, linewidth=0.5, linestyle='--')
    ax_inset.plot(transects[transect_id].lon, transects[transect_id].lat, 
                  transform=ccrs.PlateCarree(), color='red', alpha=0.8, linewidth=0.7, linestyle='--')
    #mesh.plot(ax=ax_inset)
    
    cmap = plt.get_cmap('bwr_r')
    cmap = cmocean.tools.crop(cmap, -.5, 1.8, 0)
    
    plot_nc(nc, 'zeta', levels=np.arange(-.5, 1.8, 0.02), background_map=False, cbar=True, cb_label='Max water level [mMSL]', cmap=cmap, ts=timestep,
        ncvec=nc_wind, dxvec=0.1, dyvec=0.1, vecsc=1000, ax=ax_inset, fig=fig)
    coast = cf.GSHHSFeature(scale='high', alpha=0.5)
    ax_inset.add_feature(coast)
    ax_inset.set_xlim(-73.45, -72.6)
    ax_inset.set_ylim(19., 19.72)
    gl = ax_inset.gridlines(crs=ccrs.PlateCarree(), draw_labels=True, alpha=0.5, linestyle='--')
    gl.top_labels = False
    gl.right_labels = False
    gl.xlocator = mpl.ticker.MaxNLocator(nbins=5)
    gl.ylocator = mpl.ticker.MaxNLocator(nbins=3)

    return fig, ax_main, ax_inset


def plot_wave_direction_and_height(nc_HS, nc_DIR, track_df, timestep):
    """
    Plots wave direction and height at a given timestep.

    Parameters:
    - nc_HS    : netCDF4.Dataset, NetCDF dataset with significant wave height data.
    - nc_DIR   : netCDF4.Dataset, NetCDF dataset with wave direction data.
    - track_df : pandas.DataFrame, DataFrame with hurricane track data.
    - timestep : int, Timestep to plot.

    Returns:
    - fig, ax  : matplotlib.figure.Figure, matplotlib.axes.Axes, Figure and axes objects.
    """
    fig, ax = plt.subplots(figsize=(12, 8), dpi=600, subplot_kw={'projection': ccrs.PlateCarree()}, constrained_layout=True)
    
    # Significant wave height
    plot_nc(nc_HS, 'swan_HS', levels=np.arange(0., 15., 0.01),
            background_map=True, cbar=True, cb_label='Significant Wave Height [m]',
            cmap=cmocean.cm.deep_r, ts=timestep, ax=ax, fig=fig)

    # Get the coordinates and wave direction data
    x = nc_DIR.variables['x'][:]
    y = nc_DIR.variables['y'][:]
    dir_data = nc_DIR.variables['swan_DIR'][timestep, :]

    # Convert from oceanographic convention to mathematical angles
    math_angles_rad = np.radians(dir_data)

    # Calculate u and v components for arrows
    u = np.cos(math_angles_rad)
    v = np.sin(math_angles_rad)

    # Skip points to make the plot clearer
    n = 2
    ax.quiver(x[::n], y[::n], u[::n], v[::n], 
              scale=80, width=0.001, color='white', 
              alpha=0.75, transform=ccrs.PlateCarree())

    # Plot trajectory line
    ax.plot(track_df['Longitude'], track_df['Latitude'], '+-', linewidth=0.5, color='red', markersize=5)

    # Set plot limits and title
    ax.set_xlim(-75., -72.2)
    ax.set_ylim(18., 20.2)
    ax.set_title('Wave Direction (arrows) and Height at timestep: ' + str(timestep))
    
    return fig, ax
