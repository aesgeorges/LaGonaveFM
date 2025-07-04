%% Post-processing

root = '/mnt/Work/LaGonaveFM/';
root_14 = [root 'sims/Gonave_SLR_mangrove/S0/fort.14'];
root_meshmaker = '/mnt/Work/LaGonaveFM/gis-meshmaker/meshmaker/';

dt = 4; %dt should be in memory from running gridmaker, if not, set with same value
DTM = [root 'datasets/rasters/GrandPierre_topo2.nc']; %EastCoast_GEBCO_2024 GrandPierre_topo
Bathy = [root 'datasets/rasters/EastCoast_GEBCO_2024.nc'];

m = msh(root_14);

buffer_dist = 500; % meters

m = interp(m, DTM, 'method', 'natural', 'blend_dist', buffer_dist);
m = lim_bathy_slope(m, 0.2, 0);
%m = interp(m,demfile,'type', 'depth');
m = Calc_tau0(m);
m = bound_courant_number(m,dt);
m = renum(m);
m = clean(m, 'ds', 1);
write(m, [root_meshmaker 'exports/ww_gonave_v3_test']);
plot(m, 'type', 'b', 'proj', 'merc');

%save('gonave_grid.mat', 'm')
%write(m, 'gonave_grid')

%m = Make_f15(m, ts, te, dt, 'const', {CONST}, 'sta database',{'CO−OPS','NDBC',[1]}); 
%m.f15.dramp = 30;
%m.f15.nramp = 1;
%m.f15.outge = [5 30 31 3600];
%m.f15.ntip = 2;
%m.f15.oute = [5 30 35 360];
%m.f15.outhar = [30 120 360 0];
%m.f15.outhar_flag = [0 0 5 0];

%write(m)m.plot()
