monopole = monopole('Height', .3175);

% figure ;
% patternAzimuth ( monopole , 1.1e9 ); % show the azimuth pattern

% figure ;
% patternElevation ( monopole , 1.1e9 ); % show the elevation pattern

% figure ;
% pattern ( monopole , 1.1e9 ); % show the radiation pattern at 1.1 GHz

la = linearArray ;
la.NumElements = 4;
la.Element = monopole ;
la.ElementSpacing = 0.136363636; % set this to lambda /2
la.PhaseShift = [0 0 0 0]

figure ;
patternAzimuth ( la , 1.1e9 ); % show the azimuth pattern

figure ;
patternElevation ( la , 1.1e9 ); % show the elevation pattern

figure ;
pattern ( la , 1.1e9 ); % show the radiation pattern at 1.1 GHz