lambda = (3e8 / 915e6);
dipole_length = lambda/2;
dipole = dipoleCylindrical('Radius', 1e-3, 'Length', dipole_length);

%figure;
%patternAzimuth(dipole, 915e6);

%figure;
%patternElevation(dipole, 915e6);

%figure;
%pattern(dipole, 915e6);

psi = rad2deg((2 * pi * (lambda/2) * cos(pi/4)) / lambda);
phases = [0 psi 2*psi 3*psi];

la = linearArray;
la.NumElements = 4;
la.Element = dipole;
la.ElementSpacing = lambda/2;
la.PhaseShift = phases;
layout(la);

figure;
patternAzimuth(la, 915e6);

figure;
patternElevation(la, 915e6);

figure;
pattern(la, 915e6);