%% 18729 Lab 2A: Patch Antenna Design
%antLength = 0.2; % antenna length in meters
patch = patchMicrostripInsetfed;
freq = 3e9;

%show(patch);
pattern(patch,freq);

patternAzimuth(patch,freq);

patternElevation(patch,freq);


%impedance(patch,freq*.9:freq/1000:freq*1.1);

%%
S = sparameters(patch,freq*.9:freq/1000:freq*1.1);

