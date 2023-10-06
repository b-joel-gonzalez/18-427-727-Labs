clc
clear all;
close all;

tar_freq = 5e8;
%tar_freq = 7.01e8;
%tar_freq = 9.02e8;

%%

amp = read(rfckt.amplifier,'amp_measure.s2p');
[sparams,AllFreq] = extract(amp.AnalyzedResult,'S_Parameters');

[mu,muprime] = stabilitymu(sparams);
figure
plot(AllFreq/1e9,mu,'--',AllFreq/1e9,muprime,'r')
legend('MU',"MU'",'Location','Best') 
title("Stability Parameters MU and MU'")
xlabel('Frequency [GHz]')

if (length(AllFreq(mu<=1)) > 1)
    disp('Measured Frequencies where the amplifier is not unconditionally stable:')
    fprintf('\tFrequency = %.1e\n',AllFreq(mu<=1))
end

figure
AllGammaL = calculate(amp,'GammaML','none');
AllGammaS = calculate(amp,'GammaMS','none');
hsm = smithplot([AllGammaL{:} AllGammaS{:}]);
hsm.LegendLabels = {'#Gamma ML','#Gamma MS'};

freq = AllFreq(AllFreq == tar_freq)
GammaL = AllGammaL{1}(AllFreq == tar_freq)
%%

figure
hsm = smithplot;
circle(amp,freq,'Gamma',abs(GammaL),hsm); 
hsm.GridType = 'yz';
hold all
plot(0,0,'k.','MarkerSize',16)                    
plot(GammaL,'k.','MarkerSize',16)
txtstr = sprintf('\\Gamma_{L}\\fontsize{8}\\bf=\\mid%s\\mid%s^\\circ', ...
    num2str(abs(GammaL),4),num2str((angle(GammaL)*180/pi),4));
text(real(GammaL),imag(GammaL)+.1,txtstr,'FontSize',10, ...
    'FontUnits','normalized');
plot(0,0,'r',0,0,'k.','LineWidth',2,'MarkerSize',16);
text(0.05,0,'y_L','FontSize',12,'FontUnits','normalized')

%%

circle(amp,freq,'G',1,hsm);
hsm.ColorOrder(2,:) = [1 0 0];
GammaL_val = abs(GammaL);
[~,pt2] = imped_match_find_circle_intersections_helper([0 0], GammaL_val, [-.5 0],.5);
GammaMagA = sqrt(pt2(1)^2 + pt2(2)^2);  
GammaAngA = atan2(pt2(2),pt2(1));
ax = hsm.Parent.CurrentAxes;
hold (ax,"on");
plot(ax, pt2(1),pt2(2),'k.','MarkerSize',16);
txtstr = sprintf('A=\\mid%s\\mid%s^\\circ',num2str(GammaMagA,4), ...
    num2str(GammaAngA*180/pi,4));
text(ax, pt2(1),pt2(2)-.07,txtstr,'FontSize',8,'FontUnits','normalized', ...
    'FontWeight','Bold')
container = hsm.Parent;
annotation(container,'textbox','VerticalAlignment','middle',...
    'String',{'Unity','Conductance','Circle'},...
    'HorizontalAlignment','center','FontSize',8,...
    'EdgeColor',[0.04314 0.5176 0.7804],...
    'BackgroundColor',[1 1 1],'Position',[0.1403 0.1608 0.1472 0.1396])
annotation(container,'arrow',[0.2786 0.3286],[0.2778 0.3310])
annotation(container,'textbox','VerticalAlignment','middle',...
    'String',{'Constant','Magnitude','Circle'},...
    'HorizontalAlignment','center','FontSize',8,...
    'EdgeColor',[0.04314 0.5176 0.7804],...
    'BackgroundColor',[1 1 1],'Position',[0.8107 0.3355 0.1286 0.1454])
annotation(container,'arrow',[0.8179 0.5761],[0.4301 0.4887]);

%%

StubPositionOut = ((2*pi + GammaAngA) - angle(GammaL))/(4*pi)
GammaA = GammaMagA*exp(1j*GammaAngA);
bA = imag((1 - GammaA)/(1 + GammaA));
StubLengthOut = -atan2(-2*bA/(1 + bA^2),(1 - bA^2)/(1 + bA^2))/(4*pi)

%%

GammaS = AllGammaS{1}(AllFreq == tar_freq)
[pt1,pt2] = imped_match_find_circle_intersections_helper([0 0], ...
    abs(GammaS),[-.5 0],.5);
GammaMagA = sqrt(pt2(1)^2 + pt2(2)^2);
GammaAngA = atan2(pt2(2),pt2(1));
GammaA = GammaMagA*exp(1j*GammaAngA);
bA = imag((1 - GammaA)/(1 + GammaA));
StubPositionIn = ((2*pi + GammaAngA) - angle(GammaS))/(4*pi)
StubLengthIn = -atan2(-2*bA/(1 + bA^2),(1 - bA^2)/(1 + bA^2))/(4*pi)

%%

stubTL4 = rfckt.microstrip;
analyze(stubTL4,freq);
Z0 = stubTL4.Z0

phase_vel = stubTL4.PV;

TL2 = rfckt.microstrip('LineLength',phase_vel/freq*StubPositionIn);
TL3 = rfckt.microstrip('LineLength',phase_vel/freq*StubPositionOut);

stubTL1 = rfckt.microstrip('LineLength',phase_vel/freq*StubLengthIn, ...
    'StubMode','shunt','Termination','open'); %,'Width',3.5e-3);
set(stubTL4,'LineLength',phase_vel/freq*StubLengthOut, ...
    'StubMode','shunt','Termination','open'); %,'Width',3.5e-3)

matched_amp = rfckt.cascade('Ckts',{stubTL1,TL2,amp,TL3,stubTL4});
analyze(matched_amp,3e8:1e7:3e9);
analyze(amp,3e8:1e7:3e9);

%%

%clf
figure(4)
plot(amp,'S11','dB')
hold all
hline = plot(matched_amp,'S11','dB');
hline.Color = 'r';
legend('S_{11} - Original Amplifier', 'S_{11} - Matched Amplifier')
legend('Location','SouthEast')
%xlim([1,3]);
hold off


%%

Length_Line1 = TL2.LineLength; % Length of the Input Matching Network
Length_Stub1 = stubTL1.LineLength;  % Length of the Stub

Length_Line2 = TL3.LineLength;   % Length of the Output Matching Network
Length_Stub2 = stubTL4.LineLength; % Length of the Stub
Width_Line   = 6.0000e-04;  % Width of the line

EpsilonR     = 3.48;    % Dielectric EpsilonR
Height       = 1.6e-3;% Height of the Substrate
LossTangent  = 0.0037;  % Loss Tangent of the Substrate

fmin   = 200e6;
fmax   = 3e9;
points = 100;
freq   = linspace(fmin,fmax,points);
d  = dielectric('FR4');


%%

InputMatching = traceTee('Length',[Length_Line1 Length_Stub1],'Width',[Width_Line Width_Line]);
figure(5);
show(InputMatching);

OutputMatching = traceTee('Length',[Length_Line2 Length_Stub2],'Width',[Width_Line Width_Line]);
figure(6)
show(OutputMatching);

Gnd1 = antenna.Rectangle('Length',Length_Line1,'Width',30e-3);
Gnd2 = antenna.Rectangle('Length',Length_Line1,'Width',30e-3);

%%

InputMatchingNw = pcbComponent(InputMatching);
figure(7);
show(InputMatchingNw);

OutputMatchingNw = pcbComponent(OutputMatching);
figure(8);
show(OutputMatchingNw);

%%

s = PCBServices.MayhewWriter;
s.Filename = 'inputMatching_5e8';
gerberWrite(InputMatchingNw,s);

s = PCBServices.MayhewWriter;
s.Filename = 'outputMatching_5e8';
gerberWrite(OutputMatchingNw,s);
