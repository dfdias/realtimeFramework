clear all 
clc
N = 1000
%moving window breathing signal plot
fs = 1e5
sine1 = dsp.SineWave(1,1);
sine1.SampleRate= fs;
sine1.ComplexOutput= 0;
sine1.SamplesPerFrame=N;
% configuringwindow
win = slidingwindow(N,1e6,'left')
figure(1)
H1 = plot(win.get())
H1.XData = (1:1e6)/fs
while(1)
   f = sine1();
   win.put(f); 
   H1.YData = win.get();
   drawnow
   pause(N/fs)
end
