%% Post-processing

dt = 15; %dt should be in memory from running gridmaker, if not, set with same value
demfile = 'datasets/EastCoast.nc'; %EastCoast.nc
m = load('exports/AYTCJ_mesh_fixtest.mat').m;
m = interp(m, demfile, 'nan', 'fill');
m = Calc_tau0(m);
m = bound_courant_number(m,dt);
m = renum(m);
write(m, 'exports/AYTCJ_grid_fix');
plot(m, 'b')

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
