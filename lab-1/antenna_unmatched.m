% patch antenna with no quarter-wave transformer

% 2.45 GHz parameters
patchLength    = 27.6e-3;
patchWidth    = 35.9e-3;
feedLineLength = 27.9e-3; % half wavelength at 2.45GHz
feedLineWidth  = 3e-3;
groundPlaneLength = 80e-3;
groundPlaneWidth = 60e-3;
height = 1.6e-3;
d  = dielectric('FR4');

% make patch antenna; has input impedance of 261
patch    = traceRectangular('Length',patchLength,'Width',patchWidth);
% show(patch);

% create quarter-wavelength transformers
% impedance is geometric mean of 50 ohm (feedline) and 261 ohm (antenna)
line = design(microstripLine('Substrate',d),2.45e9,"LineLength",0.25,"Z0",114);
transformerLine = traceRectangular('Length',line.Length,'Width',line.Width,'Center',[(-patch.Length/2-line.Length/2),0]);

% create patch antenna feedline (50 ohm)
feedLine = traceRectangular('Length',feedLineLength,'Width',feedLineWidth,'Center',[(-patch.Length/2-feedLineLength/2),0]);

% add feedline + transformer
antShape = patch + feedLine;
translate(antShape,[patchLength/2+feedLineLength,0,0]);
% figure;
% show(antShape);

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

% test impedance and reflection (this takes some time)
figure;
impedance(ant,linspace(2.2e9,2.6e9,101));
spar = sparameters(ant,linspace(2e9,3e9,50));
figure;
rfplot(spar);

% create gerber files (requires the appropriate subdirectory)
s = PCBServices.MayhewWriter;
s.Filename = 'antenna-unmatched-test';
PW = PCBWriter(ant,s);
PW.UseDefaultConnector = 0;
gerberWrite(PW)