PREFIX = 'artibonite'; % Greater Haiti and Windward Passage with Cuba and Jamaica

%% Defining domain
root = '/mnt/Work/LaGonaveFM/gis-meshmaker/meshmaker/';
domain = readtable([root 'datasets/gonave_hd_extent.csv']);

%% Defining mesh subdomains and boundaries boundaries 
bbox = [domain.lon domain.lat]; % Windward Passage, Haiti, SE Cuba, NE Jamaica

wl = 60;
dt = 60;

%% Define mesh resolution parameters
% min 50 max 120 maxns 30 yields a high quality mesh
min_el3 = 50; % Refined minimum element size (m).
max_el3 = 50; % Refined maximum element size (m).
max_el_ns3 = 50; % Refined maximum nearshore element size (m).
grade3 = 0.3; % Mesh grading factor for refined area.
R2 = 2;

%% Initialize geographic data for mesh generation
coastline = [root 'coastline/gonave_hd_coastline'];
% coastline_gonave = [root 'coastline/inner_coast'];

demfile = 'datasets/.nc';
root_dem = '/mnt/Work/LaGonaveFM/';
dem_topo = [root_dem 'datasets/rasters/DeltaDTM_Artibonite.nc']; %DeltaDTM_Artibonite

gdat = geodata('shp', coastline, 'dem', dem_topo, 'bbox', bbox, 'h0', min_el3); 

fh3 = edgefx('geodata', gdat, 'fs', R2,'dt', dt, 'wl', wl, 'max_el', max_el3, 'max_el_ns', max_el_ns3, 'g', grade3);

%% Generate mesh
mshopts = meshgen('ef', fh3, 'bou', gdat, 'plot_on', 1);
mshopts = mshopts.build();

m = mshopts.grd;
m.plot()
%m = makens(m, 'auto', gdat1);

%% Export
save([root 'exports/' PREFIX '_v0.mat'], 'm');