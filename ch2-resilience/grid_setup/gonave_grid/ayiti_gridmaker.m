PREFIX = 'AYTCJ'; % Greater Haiti and Windward Passage with Cuba and Jamaica

%% Defining mesh boundaries
bbox1 = [-76.6345591746215149, -72.1416664304764055; 17.3937220000000003, 20.3116449355255213]; % Windward Passage, Haiti, SE Cuba, NE Jamaica
bbox2 = [-74., -72.31; 18.4, 19.663]; % Gulf of Gonave
bbox3 = [-72.79, -72.65; 19.24, 19.45]; % Grand-Pierre and Gonaives Bay

wl = 60;

%% Define mesh resolution parameters
min_el1 = 5e3;       % minimum resolution in meters.
max_el1 = 8e3;      % maximum resolution in meters.
grade1 = 0.28;       % mesh grade in decimal percent.
R = 2;              % Number of elements to resolve feature.

min_el2 = 3e3; % Minimum element size (m).
max_el2 = 5e3; % Maximum element size (m).
grade2 = 0.22;


min_el3 = 100; % Refined minimum element size (m).
max_el3 = 1e3; % Refined maximum element size (m).
max_el_ns3 = 200; % Refined maximum nearshore element size (m).
grade3 = 0.2; % Mesh grading factor for refined area.
R2 = 3;

%% Initialize geographic data for mesh generation

root = '/mnt/Work/LaGonaveFM/ch2-resilience/grid_setup/gonave_grid/';
coastline = [root 'coastline/GSHHS_windward'];
coastline_gonave = [root 'coastline/inner_coast'];

demfile = 'datasets/EastCoast.nc';

gdat1 = geodata('shp', coastline, 'bbox', bbox1, 'h0', min_el1);
gdat2 = geodata('shp', coastline, 'bbox', bbox2, 'h0', min_el2);
gdat3 = geodata('shp', coastline, 'bbox', bbox3, 'h0', min_el3); 

fh1 = edgefx('geodata', gdat1, 'fs', R, 'wl', wl, 'max_el', max_el1, 'g', grade1);
fh2 = edgefx('geodata', gdat2, 'fs', R2, 'wl', wl, 'max_el', max_el2, 'g', grade2);
fh3 = edgefx('geodata', gdat3, 'fs', R2, 'wl', wl, 'max_el', max_el3, 'max_el_ns', max_el_ns3, 'g', grade3);

%% Generate mesh
mshopts = meshgen('ef', {fh1, fh2, fh3}, 'bou', {gdat1, gdat2, gdat3}, 'plot_on', 1);
mshopts = mshopts.build();

m = mshopts.grd;
m.plot()
%m = makens(m, 'auto', gdat1);

%% Export
save([PREFIX '_mesh_fixtest.mat'], 'm');