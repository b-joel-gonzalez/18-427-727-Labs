% https://www.mathworks.com/help/rfpcb/ref/microstripline.html

% create microstrip trace, 5cm long
d = dielectric('FR4');
trace = design(microstripLine('Substrate',d),7.5e8,'Z0',50,'LineLength',.25);
% show(trace);

% convert to PCB
robj = pcbComponent(trace);
robj.BoardThickness = trace.Substrate.Thickness;
robj.Layers{2} = trace.Substrate;
figure;
show(robj);

% test s-parameters (this takes some time)
freq = (1:2:60)*100e6;
spar = sparameters(robj,freq);
figure;
rfplot(spar,1,1,'db','-s')

% create gerber files (requires the appropriate subdirectory)
s = PCBServices.MayhewWriter;
s.Filename = 'microstrip-test';
PW = PCBWriter(robj,s);
PW.UseDefaultConnector = 0;
gerberWrite(PW)
