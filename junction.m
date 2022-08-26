% https://www.mathworks.com/help/rfpcb/ref/tracetee.html

% generate splitter
d = dielectric('FR4');
m = design(microstripLine('Substrate',d),1.25e9,'Z0',50,'LineLength',.25);
tee = traceTee('Length',[m.Length*2 m.Length], "Width",[m.Width m.Width]);
% show(split);

% convert to PCB
robj = pcbComponent(tee);
robj.BoardThickness = m.Substrate.Thickness;
robj.Layers{2} = m.Substrate;
figure;
show(robj);

% % s parameters
% spar = sparameters(robj,linspace(5e8,3e9,30));
% figure;
% rfplot(spar);

% % gerber files
% s = PCBServices.MayhewWriter;
% s.Filename = 'splitter-test';
% PW = PCBWriter(robj,s);
% PW.UseDefaultConnector = 0;
% gerberWrite(PW)