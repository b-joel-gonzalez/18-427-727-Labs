% 915 MHz patch antenna, to be used in a linear array
% designed using calculators from em-talk

%% patch antenna geometry
% 915 MHz parameters
fc = 9.15e8;
patchLength    = 74.68e-3;
patchWidth    = 96.27e-3;
feedLineLength = 43.29e-3; % 1/4-wavelength at 915MHz
feedLineWidth  = 2.84e-3; % 50-ohm match
groundPlaneLength = 200e-3;
groundPlaneWidth = 170e-3;
height = 1.5875e-3;
d  = dielectric('FR4');

% make patch antenna; has input impedance of 261
patch    = traceRectangular('Length',patchLength,'Width',patchWidth);
figure;
show(patch);

% create quarter-wavelength transformer
% impedance is geometric mean of 50 ohm (feedline) and 261 ohm (antenna)
line = design(microstripLine('Substrate',d),fc,"LineLength",0.25,"Z0",114);
transformerLine = traceRectangular('Length',line.Length,'Width',line.Width,'Center',[(-patch.Length/2-line.Length/2),0]);

% create patch antenna feedline (50 ohm)
feedLine = traceRectangular('Length',feedLineLength,'Width',feedLineWidth,'Center',[(-patch.Length/2-line.Length-feedLineLength/2),0]);

% add feedline and transformer
antShape = patch + transformerLine + feedLine;
translate(antShape,[patchLength/2+feedLineLength+line.Length,0,0]);
figure;
show(antShape);

%% make PCB
Gnd = antenna.Rectangle('Length',groundPlaneLength,'Width',groundPlaneWidth,'Center',[groundPlaneLength/2,0]); 
ant = pcbStack;
ant.Layers = {antShape,d,Gnd};
ant.BoardShape    = Gnd;
ant.FeedLocations = [0 0 1 3];
ant.BoardThickness = height;
figure;
show(ant);
hold;

%% plotting characteristics

figure;
s11 = sparameters(ant,linspace(5e8,1.5e9,51)); % get the S11 plot
rfplot(s11);
 
figure;
patternElevation(ant, fc); % show the elevation pattern

figure;
patternAzimuth(ant, fc); % show the azimuth pattern
 
figure;
pattern(ant, fc); % show the radiation pattern

%% create gerber files (requires the appropriate subdirectory)
s = PCBServices.MayhewWriter;
s.Filename = 'patch';
PW = PCBWriter(ant,s);
PW.UseDefaultConnector = 0;
gerberWrite(PW)