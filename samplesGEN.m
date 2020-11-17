clear all
close all
clc

%% Setting channel model constants

Fc= 5.8e9;              % Analog Carrier Frequency
Fo= 1e4;                % Transmitted sinusoid frequency
Fs= 1e5;                % Sampling Frequency
N= 1000;                % Number of samples per frame
ar= 0.005;              % Breathing amplitude
Fb= 0.3;                % Breathing frequency
d1= 2;                  % Equivalent distance to the static objects
D= 100

brm= BioRadarChannel(Fs,Fc,N,ar,Fb,d1);
brm.nd= 0.005;          % Noise Density Power
brm.A0= 2;              % Amplitude of the received echo from the chest
brm.A1= 1;              % Equivalent amplitude of the static echos
brm.Theta= -pi/3;       % Constant Phase shift
brm.d0= 1.009;          % Distance to the chest wall

%% Create the sinusoidal generator objec
sine1 = dsp.SineWave(1,10e3);
sine1.SampleRate= Fs;
sine1.ComplexOutput= 1;
sine1.SamplesPerFrame= N;

%% Create the Decimator object
h= fir1(500,1/D);
firdecim = dsp.FIRDecimator('DecimationFactor',D,'Numerator',h);

%% arc corretion high pass filter definition
z         = 1;
fa = Fs/D;
[B,A] = butter(1,0.5/(fa/2),'high');
%Ha = dfilt.df1(B,A)%trying direct form filter
%% Circular Buffer

%%slidingwindow(10,N*10,'left')

%% fitcorrect memory filter gains setup

axy = 0.5 % coordinates gain
ar = 0.5  %radius gain

%% Sliding window for time plot

win = slidingwindow(10,N*10,'left')

%% Simulation control Parameters

T = 30 %simulation time
Nframes= round(Fs*T/N); 

%%

x = 0
y = 0
radius = 0
buff = circularbuffer(Nframes,N)
for i = 1:Nframes
%  if i == round(Nframes/2)
%      brm.theta1 = -3*pi/4;
%      brm.A1 = 4;
%      brm.Fb = 0.4
%  end

s = sine1();
r=  brm.Evaluate(s);
buff.put(r)

end
x = buff.get();

 save('sintetico.mat','x','Fs','Fo')