%% make a 915 MHz dipole
dipole_radius =   1e-3; % radius in meters
dipole_length = (3e8/915e6) /2; % length in meters

dipole = dipoleCylindrical('Radius', dipole_radius, 'Length', dipole_length);
show(dipole);

figure;
pattern(dipole, 915e6); % show the elevation pattern

figure;
patternAzimuth(dipole, 915e6); % show the azimuth pattern


%% now make it an array
la = linearArray;
la.NumElements = 16;
la.Element = dipole;
la.ElementSpacing = dipole_length;
% layout(la);

la.PhaseShift = (15:-1:0) *127.27;

figure;
pattern(la,915e6);

figure;
patternAzimuth(la,915e6);
