% https://www.mathworks.com/help/rfpcb/ref/tracetee.html

% generate splitter
d = dielectric('FR4');
m = design(microstripLine('Substrate',d),1e9,'Z0',50,'LineLength',.25);
tee = traceTee('Length',[m.Length*2 m.Length], "Width",[m.Width m.Width]);
% show(split);

% convert to PCB
robj = pcbComponent(tee);
robj.BoardThickness = m.Substrate.Thickness;
robj.Layers{2} = m.Substrate;
figure;
show(robj);

% test s-parameters (this takes some time)
spar = sparameters(robj,linspace(5e8,3e9,30));
figure;
rfplot(spar);

% create gerber files (requires the appropriate subdirectory)
s = PCBServices.MayhewWriter;
s.Filename = 'junction-test';
PW = PCBWriter(robj,s);
PW.UseDefaultConnector = 0;
gerberWrite(PW)