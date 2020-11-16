clear all 
clc
N = 10 %number of samples per frame
%moving window breathing signal plot
Fs = 1e5
sine1 = dsp.SineWave(1,10e3);
sine1.SampleRate= Fs;
sine1.ComplexOutput= 0;
sine1.SamplesPerFrame=1000;
D = 100
numframes = 10e3
buff= circularbuffer(numframes,N)

% Create the Decimator object
h= fir1(500,1/D);
firdecim = dsp.FIRDecimator('DecimationFactor',D,'Numerator',h);


figure(1)
idxs = buff.getorder() ;%obtem as frames ordenadas do buffer circular
a = buff.buffer(:,idxs);
H1 = plot(a(:));
H1.XData = (1:numframes*N)/Fs

while(1)
   f = sine1();
   df = firdecim(f);
   buff.appends(df);
   idxs = buff.getorder() ;%obtem as frames ordenadas do buffer circular
   a = buff.buffer(:,idxs);
   H1.YData = a(:);
   drawnow
   pause(N/Fs)
end
