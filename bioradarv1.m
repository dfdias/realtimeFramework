clear all
close all
clc

sig = load('seg_23.mat')
S = sig.sinal(2:end)
%% Setting channel model constants

Fc= 5.8e9;              % Analog Carrier Frequency
Fo= 1e5;                % Transmitted sinusoid frequency
Fs= 1e5;                % Sampling Frequency
N= 1000;                % Number of samples per frame
ar= 0.005;              % Breathing amplitude
Fb= 0.3;                % Breathing frequency
d1= 2;                  % Equivalent distance to the static objects
D= 1000

brm= BioRadarChannel(Fs,Fc,N,ar,Fb,d1);
brm.nd= 0.005;          % Noise Density Power
brm.A0= 2;              % Amplitude of the received echo from the chest
brm.A1= 1;              % Equivalent amplitude of the static echos
brm.Theta= -pi/3;       % Constant Phase shift
brm.d0= 1.009;          % Distance to the chest wall

%% Create the sinusoidal generator object
sine1 = dsp.SineWave(1,10e3);
sine1.SampleRate= Fs;
sine1.ComplexOutput= 1;
sine1.SamplesPerFrame= N;

%% Create the Decimator object
h= fir1(500,1/D);
firdecim = dsp.FIRDecimator('DecimationFactor',D,'Numerator',h);

%% arc corretion high pass filter definition
z  = 1;
fa = Fs/D;
[B,A] = butter(1,0.5/(fa/2),'high');
%Ha = dfilt.df1(B,A)%trying direct form filter
%% Circular Buffer
buff = circularbuffer(1000,10)
%%slidingwindow(10,N*10,'left')

%% fitcorrect memory filter gains setup

axy = 0.1 % coordinates gain
ar = 0.1  %radius gain

%% Sliding window for time plot

win = slidingwindow(10,N*10,'left')

%% Simulation control Parameters

T = 30 %simulation time
Nframes= round(Fs*T/N); 
%Nframes = round(length(S)/10)

%% Plot Setup
figure(1)                % Creates a dummy variable 
dum= ones(1,N/D);            
dum= dum+1j*dum;
H1= plot(dum,'o');
axis(1*[-1 1 -1 1]);
grid on
%generates the circle plot
radius = 1
th = linspace(0,2*pi,200);
k = 0;
xunit = radius * cos(th) + 0;
yunit = radius * sin(th) + 0;
hold on
phi = linspace(0,2*pi,200)
c = (brm.A0*exp(j*phi) + brm.A1*exp(j*brm.theta1)) %ideal circle plot
H2 = plot(xunit,yunit,'o');
H3 = plot(c);
hold off

figure(2)
phi = linspace(0,2*pi,200)
dum= ones(1,N/D);            
dum= dum+1j*dum;
H5 = plot(dum,'o'); %ideal circle plot
axis(1/100*[-1 1 -1 1]);
hold on
H6 = plot(xunit,yunit);
figure(3)
hold off

H4 = plot(win.get())
H4.XData = (0:1e4-1)/(Fs/D)
axis([0 inf -5 5])
grid on


%%

x = 0
y = 0
radius = 0
idxs = 0:10:Nframes-10
for i = 0:Nframes
%  if i == round(Nframes/2)
%      brm.theta1 = -3*pi/4;
%      brm.A1 = 4;
%      brm.Fb = 0.4
%      c = (brm.A0*exp(j*phi) + brm.A1*exp(j*brm.theta1))
%      H3.XData = real(c)
%      H3.YData = imag(c)
%  
%  end
tic
s = sine1();
r= brm.Evaluate(s);
Move the signal to the base band
g= r.*conj(s);
signal decimation
d = firdecim(g);

%d = S(i*10+1:(i+1)*10);
%% DSP code
buff.put(d)
df = buff.get(); 
%% circle fitting
%gera matriz para o hyperfix
auxA = real(df);
auxB = imag(df);
P = HyperSVD([auxA,auxB]);%foi escolhido o svd por uma questão de estabildiade


%% Low Pass Filter
x = axy*P(1) + (1-axy)*x;
y = axy*P(2) + (1-axy)*y;
radius = ar*P(3) + (1-ar)*radius;
dfit = (real(d)-x) + j*(imag(d)-y);

%% Angle conditioning
phi = angle(dfit);
phi = unwrap(phi);%tribolet
[filtered,z] = filter(B,A,phi,z);
 %filtragem passo a alto
win.put(filtered)

%% Plot Updates


H1.XData= real(d);
H1.YData= imag(d);
H2.XData = radius * cos(th) + x;
H2.YData = radius * sin(th) + y;

%ideal x= 0 y = 0 and adjsuted d signal ploting
H5.XData = real(dfit);
H5.YData = imag(dfit);
xunit = radius * cos(th) + 0;
yunit = radius * sin(th) + 0;
H6.XData = xunit;
H6.YData = yunit;

%moving window breathing signal plot
H4.YData =win.get();

%% breathing rate estimation
[pxx,f] = pwelch(win.get(),[],[],4096,Fs/D);
 f(find(pxx == max(pxx)))
t = toc;
drawnow  
pause(N/Fs-t)
    
    
end





