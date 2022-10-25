% https://www.mathworks.com/help/supportpkg/rtlsdrradio/ug/spectral-analysis-with-rtl-sdr-radio.html

%For the option to change default settings, set |cmdlineInput| to 1.
cmdlineInput = 0

if cmdlineInput
%     Request user input from the command-line for application parameters
    userInput = helperSpectralAnalysisUserInput;
%     Set initial parameters
    [SAParams, sigSrc] = helperSpectralAnalysisConfig(userInput);
else
%     Set initial parameters
    load defaultInputSpecAnalysis.mat
    [SAParams, sigSrc] = helperSpectralAnalysisConfig;
end

hSpectrum = spectrumAnalyzer(...
    'Name',             'Passband Spectrum',...
    'Title',            'Passband Spectrum', ...
    'Method',           'Welch', ...
    'SpectrumType',     'Power density', ...
    'FrequencySpan',    'Full', ...
    'SampleRate',       SAParams.FrontEndSampleRate, ...
    'SpectralAverages', 50, ...
    'FrequencyOffset',  SAParams.CenterFrequency, ...
    'YLimits',          [-120 10], ...
    'YLabel',           'Magnitude-squared, dB', ...
    'Position',         figposition([50 30 30 40]));
    
% Initialize radio time
radioTime = 0;

% Main loop
while radioTime < userInput.Duration
  % Receive baseband samples (Signal Source)
  if SAParams.isSourceRadio
      if SAParams.isSourcePlutoSDR
          rcv = sigSrc();
          lost = 0;
          late = 1;
      elseif SAParams.isSourceUsrpRadio
          rcv= sigSrc();
          lost = 0;
      else
          [rcv,~,lost,late] = sigSrc();
      end
  else
    rcv = sigSrc();
    lost = 0;
    late = 1;
  end
  
    rcv = rcv - mean(rcv);  % Remove DC component.
    step(hSpectrum, rcv);

  % Update radio time. If there were lost samples, add those too.
  radioTime = radioTime + SAParams.FrontEndFrameTime + ...
    double(lost)/SAParams.FrontEndSampleRate;
end

% Release all System objects
release(sigSrc);
release(hSpectrum);