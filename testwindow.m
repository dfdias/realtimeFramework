clear all 
clc
N = 10
%moving window breathing signal plot
fs = 100
sine1 = dsp.SineWave(1,1);
sine1.SampleRate= fs;
sine1.ComplexOutput= 0;
sine1.SamplesPerFrame=N;

win = slidingwindow(N,3e3,'left')
figure(1)
H1 = plot(win.get())
H1.XData = (1:3e3)/fs
while(1)
   f = sine1();
   win.put(f'); 
   H1.YData = win.get();
   drawnow
   pause(0.01)
end
