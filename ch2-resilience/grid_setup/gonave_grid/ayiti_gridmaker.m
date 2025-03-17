PREFIX = 'ww_gonave'; % Greater Haiti and Windward Passage with Cuba and Jamaica

%% Defining domain
root = '/mnt/Work/LaGonaveFM/ch2-resilience/grid_setup/gonave_grid/';
domain = readtable([root 'datasets/mesh_extent.csv']);
subdomain1 = readtable([root 'datasets/gonave_extent.csv']);
subdomain2 = readtable([root 'datasets/gpbay_extent.csv']);

%% Defining mesh subdomains and boundaries boundaries 
bbox1 = [domain.lon domain.lat]; % Windward Passage, Haiti, SE Cuba, NE Jamaica
bbox2 = [subdomain1.lon subdomain1.lat]; % Gulf of Gonave
bbox3 = [subdomain2.lon subdomain2.lat]; % Grand-Pierre and Gonaives Bay

wl = 60;

%% Define mesh resolution parameters
min_el1 = 3e3;       % minimum resolution in meters.
max_el1 = 8e3;      % maximum resolution in meters.
grade1 = 0.28;       % mesh grade in decimal percent.
R = 2;              % Number of elements to resolve feature.

min_el2 = 1e3; % Minimum element size (m).
max_el2 = 5e3; % Maximum element size (m).
max_el_ns2 = 3e3; % Maximum nearshore element size (m).
grade2 = 0.22;


min_el3 = 100; % Refined minimum element size (m).
max_el3 = 1e3; % Refined maximum element size (m).
max_el_ns3 = 200; % Refined maximum nearshore element size (m).
grade3 = 0.2; % Mesh grading factor for refined area.
R2 = 3;

%% Initialize geographic data for mesh generation
coastline = [root 'coastline/GSHHS_windward'];
coastline_gonave = [root 'coastline/inner_coast'];

demfile = 'datasets/EastCoast.nc';

gdat1 = geodata('shp', coastline, 'bbox', bbox1, 'h0', min_el1);
gdat2 = geodata('shp', coastline, 'bbox', bbox2, 'h0', min_el2);
gdat3 = geodata('shp', coastline, 'bbox', bbox3, 'h0', min_el3); 

fh1 = edgefx('geodata', gdat1, 'fs', R, 'wl', wl, 'max_el', max_el1, 'g', grade1);
fh2 = edgefx('geodata', gdat2, 'fs', R2, 'wl', wl, 'max_el', max_el2, 'max_el_ns', max_el_ns2, 'g', grade2);
fh3 = edgefx('geodata', gdat3, 'fs', R2, 'wl', wl, 'max_el', max_el3, 'max_el_ns', max_el_ns3, 'g', grade3);

%% Generate mesh
mshopts = meshgen('ef', {fh1, fh2, fh3}, 'bou', {gdat1, gdat2, gdat3}, 'plot_on', 1);
mshopts = mshopts.build();

m = mshopts.grd;
m.plot()
%m = makens(m, 'auto', gdat1);

%% Export
save([root 'exports/' PREFIX '_v0.mat'], 'm');