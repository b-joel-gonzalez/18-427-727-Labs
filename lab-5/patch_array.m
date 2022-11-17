% impedance-matched patch antenna

% 915 MHz parameters
patchLength    = 74.7e-3;
patchWidth    = 96.3e-3;
feedLineLength = 37.4e-3; % quarter wavelength at 915 MHz
feedLineWidth  = 3e-3;
groundPlaneLength = 160e-3;
groundPlaneWidth = 160e-3;
height = 1.5875e-3;
d  = dielectric('FR4');

% make patch antenna; has input impedance of 261
patch    = traceRectangular('Length',patchLength,'Width',patchWidth);

% create quarter-wavelength transformer
% impedance is geometric mean of 50 ohm (feedline) and 261 ohm (antenna)
line = design(microstripLine('Substrate',d),2.45e9,"LineLength",0.25,"Z0",114);
transformerLine = traceRectangular('Length',line.Length,'Width',line.Width,'Center',[(-patch.Length/2-line.Length/2),0]);

% add transformer
antShape = patch + transformerLine;

% create patch antenna feedline (50 ohm)
feedLine = traceRectangular('Length',feedLineLength,'Width',feedLineWidth,'Center',[(-patch.Length/2-line.Length-feedLineLength/2),0]);

% add feedline
antShape = patch + transformerLine + feedLine;
translate(antShape,[patchLength/2+feedLineLength+line.Length,0,0]);

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

%%
% analysis of antenna (impedance, S11, radiation patterns)
% figure;
% impedance(ant,linspace(5e8,1.5e9,51)); % show impedance from .5-1.5GHz
% 
% figure;
% s11 = sparameters(ant,linspace(5e8,1.5e9,51)); % get the S11 plot
% rfplot(s11);
% 
figure;
patternElevation(ant, 915e6); % show the elevation pattern

figure;
patternAzimuth(ant, 915e6); % show the azimuth pattern

figure;
pattern(ant, 915e6); % show the radiation pattern at 2.45GHz

% create gerber files (requires the appropriate subdirectory)
% s = PCBServices.MayhewWriter;
% s.Filename = 'antenna-test';
% PW = PCBWriter(ant,s);
% PW.UseDefaultConnector = 0;
% gerberWrite(PW)

%% now make it an array
pcbArr = array(ant,'linear','NumElements',5,'ElementSpacing',0.2);
show(pcbArr)

figure;
pattern(la,915e6);

figure;
patternAzimuth(la,915e6);
