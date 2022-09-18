% impedance-matched patch antenna

% 2.45 GHz parameters
patchLength    = 27.6e-3;
patchWidth    = 35.9e-3;
feedLineLength = 27.9e-3; % half wavelength at 2.45GHz
feedLineWidth  = 3e-3;
groundPlaneLength = 80e-3;
groundPlaneWidth = 60e-3;
height = 1.5875e-3;
d  = dielectric('FR4');

% make patch antenna; has input impedance of 261
patch    = traceRectangular('Length',patchLength,'Width',patchWidth);
figure;
show(patch);

% create quarter-wavelength transformer
% impedance is geometric mean of 50 ohm (feedline) and 261 ohm (antenna)
line = design(microstripLine('Substrate',d),2.45e9,"LineLength",0.25,"Z0",114);
transformerLine = traceRectangular('Length',line.Length,'Width',line.Width,'Center',[(-patch.Length/2-line.Length/2),0]);

% create patch antenna feedline (50 ohm)
feedLine = traceRectangular('Length',feedLineLength,'Width',feedLineWidth,'Center',[(-patch.Length/2-line.Length-feedLineLength/2),0]);

% add feedline and transformer
antShape = patch + transformerLine + feedLine;
translate(antShape,[patchLength/2+feedLineLength+line.Length,0,0]);
figure;
show(antShape);

% make PCB
Gnd = antenna.Rectangle('Length',groundPlaneLength,'Width',groundPlaneWidth,'Center',[groundPlaneLength/2,0]); 
ant = pcbStack;
ant.Layers = {antShape,d,Gnd};
ant.BoardShape    = Gnd;
ant.FeedLocations = [0 0 1 3];
ant.BoardThickness = height;
figure;
show(ant);
hold;

% analysis of antenna (impedance, S11, radiation patterns)
figure;
impedance(ant,linspace(2e9,3e9,51)); % show impedance from 2-3GHz

figure;
s11 = sparameters(ant,linspace(2e9,3e9,51)); % get the S11 plot
rfplot(s11);

figure;
patternElevation(ant, 2.45e9); % show the elevation pattern

figure;
patternAzimuth(ant, 2.45e9); % show the azimuth pattern

figure;
pattern(ant, 2.45e9); % show the radiation pattern at 2.45GHz

% create gerber files (requires the appropriate subdirectory)
s = PCBServices.MayhewWriter;
s.Filename = 'antenna-test';
PW = PCBWriter(ant,s);
PW.UseDefaultConnector = 0;
gerberWrite(PW)