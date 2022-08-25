% create trace
d = dielectric('FR4');
trace = design(microstripLine('Substrate',d),2.45e9,'Z0',50,'LineLength',.25);
% show(trace);

% convert to PCB
robj = pcbComponent(trace);
robj.BoardThickness = trace.Substrate.Thickness;
robj.Layers{2} = trace.Substrate;
figure;
show(robj);

% % test s-parameters
% freq = (1:2:60)*100e6;
% spar = sparameters(robj,freq);
% figure;
% rfplot(spar,1,1,'db','-s')

% create gerber file
% s = PCBServices.MayhewWriter;
% s.Filename = 'microstrip-test';
% PW = PCBWriter(robj,s);
% PW.UseDefaultConnector = 0;
% gerberWrite(PW)
