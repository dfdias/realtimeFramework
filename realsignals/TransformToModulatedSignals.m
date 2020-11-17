% Convert the Baseband and decimated signals in this directory to the
% following format
% .mat file
% with Fs= 1e5
% with modulated signals using a sinusoid of Fo= 1e4 Hz

% José Vieira 16/11/2020

clear
clc

OutDir= 'OutFiles';
if ~isfolder(OutDir),
    mkdir(OutDir);
end

% Use '/' for Mac or Linux and '\' for Windows
sep= '/';               % Default is Mac
if ispc,
    sep= '\';
end

% Define the parameters of the input signals
Fsin= 100;              % Sampling frequency of the input signal

% Define the parameters of the output signals
Fs= 1e5;
Ts= 1/Fs;
Fo= 1e4;

% Interpolation factor
L= Fs/Fsin;
% Create the Decimator object

h= fir1(1000,1/L);
firinterp = dsp.FIRInterpolator('InterpolationFactor',L,'Numerator',h);


DirFiles= dir('*.mat');

for k= 1:length(DirFiles),
    tic
    xstruct= load(DirFiles(k).name);
    x1= xstruct.sinal;
    N= length(x1)*L;
    % Generate the sinusoid to modulate the signal
    t= ((0:N-1)*Ts)';
    s= exp(j*2*pi*Fo*t);
    % Interpolate the input signal
    x = firinterp(x1);
    % Perform the modulation
    x= x.*s;
    % Write the file

    save([OutDir sep 'I_' DirFiles(k).name],'x','Fs','Fo')
    t= toc
end


