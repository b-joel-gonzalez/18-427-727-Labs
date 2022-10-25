# https://www.mathworks.com/help/supportpkg/rtlsdrradio/ug/comm.sdrrtlreceiver-system-object.html

rxsdr = comm.SDRRTLReceiver('0','CenterFrequency',94.5e6,'SampleRate',250000, ...
    'SamplesPerFrame',2048,'EnableTunerAGC',true,'OutputDataType','double')

radioInfo = info(rxsdr)

for p=1:1000
   rxdata = rxsdr();
end

# rxdata = step(rxsdr)

plot(abs(rxdata))

release(rxsdr)
