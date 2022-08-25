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
feedLine = traceRectangular('Length',feedLineLength,'Width',feedLineWidth,'Center',[(-patch.Length/2-line.Length-feedLineLength/2),0]);

% add feedline + transformer
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

% test impedance and reflection
% figure;
% impedance(ant,linspace(2.2e9,2.6e9,31));
spar = sparameters(ant,linspace(2e9,3e9,30));
figure;
rfplot(spar);

% gerber files
% s = PCBServices.MayhewWriter;
% s.Filename = 'antenna-test';
% PW = PCBWriter(ant,s);
% PW.UseDefaultConnector = 0;
% gerberWrite(PW)