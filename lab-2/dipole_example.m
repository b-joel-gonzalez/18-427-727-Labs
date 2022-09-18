dipole_radius = 1e-3; % radius in meters
dipole_length = 10e-2; % length in meters

dipole = dipoleCylindrical('Radius', dipole_radius, 'Length', dipole_length);
show(dipole);

figure;
impedance(dipole,linspace(5e8,1.5e9,101)); % show impedance from 0.9-1.1GHz

figure;
s11 = sparameters(dipole,linspace(5e8,1.5e9,101),73); % get the S11 plot
rfplot(s11);

figure;
patternElevation(dipole, 1e9); % show the elevation pattern

figure;
patternAzimuth(dipole, 1e9); % show the azimuth pattern

figure;
pattern(dipole, 1e9); % show the radiation pattern at 1GHz