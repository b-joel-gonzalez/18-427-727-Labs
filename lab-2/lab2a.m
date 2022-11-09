%% 18729 Lab 2: Patch Antenna Design

%% Dipole
dipole_radius = 1e-3;   % radius in meters
dipole_length = 15e-2;  % length in meters

dipole = dipoleCylindrical('Radius',dipole_radius,'Length',dipole_length);

show(dipole)

figure
fc = 2e9;
pattern(dipole,fc)

figure
freqs = linspace(.9*fc,1.1*fc,100);
impedance(dipole,freqs)

S = sparameters(dipole, freqs);
figure; 
rfplot(S);
%%
figure
patternElevation(dipole,fc);

figure
patternAzimuth(dipole,fc);

%enumerate frequencies
freqs = linspace(.9*fc,1.1*fc,100);

%plot complex impedance
figure
impedance(d,freqs)

% plot S11
S = sparameters(dipole, freqs);
figure; 
rfplot(S);

% %antLength = 0.2; % antenna length in meters
% patch = patchMicrostripInsetfed;
% freq = 3e9;

%show(patch);
% pattern(patch,freq);
% 
% patternAzimuth(patch,freq);
% 
% patternElevation(patch,freq);
% 
% 
% impedance(patch,freq*.5:freq/1000:freq*1.5);
% S = sparameters(patch,freq*.5:freq/1000:freq*1.5);

%% Design Parameters
% from: https://teaandtechtime.com/2-4-ghz-patch-antenna-design-with-matlab/
c  = physconst('lightspeed');

%center frequency
fc = 2.670e9; 

%dielectric constant
er = 4.2;

%Hight of the substrate
h = 1.4986e-3; %m 1.524mm

%microstrip width 50ohms
mw50 = 2.762e-3; %m

%microstrip width 100ohms
mw100 = .658e-3; %m

%Length of antenna patch
%L = c/(2*fc*sqrt(er)); %m
L = .02560;

%Width of antenna patch
W = .03;%L; %m

%Length of ground plane
Lg = .045; %2*L;

%Width of ground plane
Wg = .04; %2*W;

%Inset notch width
Nw = mw50*3;

%Inset notch length
Nl = mw50*1.7;

%% Build the antenna
patch = antenna.Rectangle('Length', L, 'Width', W);
groundplane = antenna.Rectangle('Length', Lg, 'Width', Wg);
notch = antenna.Rectangle('Length', Nl, 'Width', Nw, 'Center', [(L/2)-(Nl/2),0]);
microstrip_feed = antenna.Rectangle('Length', Lg/2, 'Width', mw50, 'Center', [(Lg/4),0]);
substrate_material = dielectric('Name','FR4','EpsilonR', er, 'Thickness', h); %dielectric('FR4');

build_patch = (patch-notch) + microstrip_feed;

%% Define the properties of the PCB stack.
basicPatch = pcbStack;
basicPatch.Name = 'Spectrum Buddy Basic Patch';
basicPatch.BoardThickness = h;
basicPatch.BoardShape = groundplane;
basicPatch.Layers = {build_patch,substrate_material,groundplane};
basicPatch.FeedLocations = [Lg/2 0 1];

show(basicPatch)
figure
pattern(basicPatch, fc)

%% Plot the impedance of the basic patch antenna.
%enumerate frequencies
freqs = linspace(fc-0.05*fc,fc + 0.1*fc,100);

%plot complex impedance
figure
impedance(basicPatch,freqs)

%% plot RF s-parameters
S = sparameters(basicPatch, freqs);
figure; 
rfplot(S);

