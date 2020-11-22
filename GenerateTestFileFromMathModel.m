% Generate a Test file to verify the file "bioradarJNV.m" in the Mode 2
% that uses a recorded signal
% The porpouse of this script is to simulate a recorded signal from a
% Mathematical Channel Model.
% The Model is implemented in the file "BioRadarChannel.m"

% Jose Vieira e Duarte Dias
% 22/11/2020

% ===========================================================
%
% ===========================================================

clear all
close all
clc

debug= 0;        % Set the debug mode of operation

filename= 'BioRadarChannelFile.mat';      % Output file


T= 30;           % Acquisition time in seconds

%% Prepare for each type of input signals

Fc= 5.8e9;             % Analog Carrier Frequency
Fo= 1e4;               % Transmitted sinusoid frequency
Fs= 1e5;               % Sampling Frequency
N= 1000;               % Number of samples per frame
ar= 0.006;             % Breathing amplitude
Fb= 0.31;              % Breathing frequency
d1= 2;                 % Equivalent distance to the static objects
sig= 0.01;             % Channel noise STD


% Create the BioRadar channel object
brm= BioRadarChannel(Fs,Fc,N,ar,Fb,d1);
brm.nd= 0.005;         % Noise Density Power
brm.A0= 0.1;           % Amplitude of the received echo from the chest
brm.A1= 1;             % Equivalent amplitude of the static echos
brm.Theta= -pi/3;      % Constant Phase shift
brm.d0= 1.009;         % Distance to the chest wall

% Create the sinusoidal generator objec
sine1 = dsp.SineWave(1,Fo);
sine1.SampleRate= Fs;
sine1.ComplexOutput= 1;
sine1.SamplesPerFrame= N;

Nframes= floor(Fs*T/N);   % Number of Frames to Process

%% Main Loop
x= zeros(N,Nframes);
for nf= 1:Nframes,
    
    % Signal from a channel Mathematical Model
    s= sine1();                % Sinudoid wo (digital modulation)
    x(:,nf)= brm.Evaluate(s);       % BioRadar channel simulation

end % Main Loop
x= x(:);
save(filename,'x','Fs','Fo')




