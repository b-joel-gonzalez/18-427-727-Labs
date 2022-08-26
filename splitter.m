% https://www.mathworks.com/help/rfpcb/ref/wilkinsonsplitter.html

% generate splitter
d = dielectric('FR4');
split = design(wilkinsonSplitter('Substrate',d,'ResistorLength',.01),2.45e9);
% show(split);

% convert to PCB
robj = pcbComponent(split);
robj.BoardThickness = split.Substrate.Thickness;
robj.Layers{2} = split.Substrate;
figure;
show(robj);

% s parameters
% spar = sparameters(robj,linspace(1e9,3e9,30));
% figure;
% rfplot(spar);

% % gerber files
% s = PCBServices.MayhewWriter;
% s.Filename = 'splitter-test';
% PW = PCBWriter(robj,s);
% PW.UseDefaultConnector = 0;
% gerberWrite(PW)