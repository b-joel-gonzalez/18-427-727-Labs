%% generateComplexEnvelope_DSBLC_voice.m
%   Generates a complex envelope for broadcasting with Ettus B200 USRP.
%   This version generates a DSB-LC waveform with a voice message signal.
%   The DSB-LC carrier if offset by 30kHz.
%
%   Cory J. Prust, Ph.D.
%   Last Modified:  7/11/2018

%%  USRP Configuration
%   The script generates the complex envelope sampled at 240kHz
%   So, the B200 must be configured for MasterClockRate/Interpolation = 240000.
%    e.g., MasterClockRate = 9600000 and Interpolation = 40 
clear all
close all

%% load .wav file
[m, fs_audio] = audioread('dreamland.wav');

%% apply LPF
h = fir1(50,4e3/(fs_audio/2));
m = filter(h,1,m);

% resample
fs = 240000; %USRP baseband sample rate
m = resample(m',fs,fs_audio);  %note transpose here to convert to row vector
N = length(m);
t = 0:(1/fs):(N-1)*(1/fs);

% generate DSB-LC
mu = 1.2;   % modulation index
a = max(m);
A = mu*a;

% generate complex envelope
fi_DSBLC = 30e3;
z = (A + m).*exp(j*2*pi*fi_DSBLC*t);

% normalize complex envelope
z = z/max(abs(z)) * 0.8;  % ensure magnitude < 1 to prevent saturation in USRP

% z = [z; z];

% time-domain plots
% figure
% hold on
% plot(t,real(z))
% plot(t,imag(z))
% plot(t,abs(z))
% plot(t,angle(z))
% legend('real','imag','abs','angle')

% frequency-domain plot
% f = -fs/2:(fs/N):(fs/2 - fs/N);
% figure
% plot(f,20*log10(abs(fftshift(fft(z)))));