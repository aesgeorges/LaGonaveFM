PREFIX = "ATGHT"; % Atlantic and Gulf of Gonave Refined

%% Defining mesh boundaries
bbox1 = [-101.86, -47.54; 6.62, 40.15]; % East Coast and Gulf of Mexico 
bbox2 = [-74.6, -72.31; 18.4, 19.663]; % Gulf of Gonave
bbox3 = [-72.779, -72.6; 19.245, 19.6]; % Grand-Pierre Bay
% [-72.833, -72.648; 19.165, 19.516];
%-72.8334181790718560,19.1643951728465076 : -72.6474444073471659,19.5168474337444167

dt = 80;
ts = '28-Sep-2016 12:00';
te = '09-Oct-2016 12:00';
wl = 60;
CONST = 'major8';

%% Define mesh resolution parameters
min_el1 = 3e3;       % minimum resolution in meters.
max_el1 = 1e6;      % maximum resolution in meters.
grade1 = 0.2;       % mesh grade in decimal percent.
R = 3;              % Number of elements to resolve feature.

min_el2 = 1e3; % Minimum element size (m).
max_el2 = 5e3; % Maximum element size (m).
max_el_ns2 = 4e3; % Maximum nearshore element size (m).
grade2 = 0.1;

min_el3 = 300; % Refined minimum element size (m).
max_el3 = 1e3; % Refined maximum element size (m).
max_el_ns3 = 500; % Refined maximum nearshore element size (m).
grade3 = 0.05; % Mesh grading factor for refined area.
%R3 = 5;

%% Initialize geographic data for mesh generation
rootpc = 'C:\Users\erich\OneDrive\UC Berkeley\Research\Thesis\tools';
if ispc
    coastline = [rootpc '\OceanMesh2D\datasets\GSHHS_shp\f\GSHHS_f_L1'];
else
    coastline = '/home/aesgeorges/OceanMesh2D/datasets/GSHHS_shp/f/GSHHS_f_L1';
end
root = '/mnt/Work/LaGonaveFM/ch2-resilience/grid_setup/gonave_grid/';
coastline_gpbay = [root 'coastline/coast'];
demfile = 'datasets/EastCoast.nc';
% demfile_gonave = 'Gonave.nc';

%gdat1 = geodata('shp', coastline, 'bbox', bbox1, 'h0', min_el1);
gdat2 = geodata('shp', coastline, 'bbox', bbox2, 'h0', min_el2);
gdat3 = geodata('shp', coastline_gpbay, 'bbox', bbox3, 'h0', min_el3);         

%% Generate edge function for refinement
%
fh2 = edgefx('geodata', gdat2, 'fs', R, 'wl', wl, 'max_el', max_el2, 'max_el_ns', max_el_ns2, 'g', grade2);
fh3 = edgefx('geodata', gdat3, 'fs', R, 'wl', wl, 'max_el', max_el3, 'max_el_ns', max_el_ns3, 'g', grade3);

%% Generate mesh
mshopts = meshgen('ef', {fh2, fh3}, 'bou', {gdat2, gdat3}, 'plot_on', 1);
mshopts = mshopts.build();

m = mshopts.grd;
m.plot()
m = makens(m, 'auto', gdat2);

save('gonave_grid_temp.mat', 'm');
