% Convert the Baseband and decimated signals in this directory to the
% following format
% .mat file
% with Fs= 1e5
% with modulated signals using a sinusoid of Fo= 1e4 Hz

% José Vieira 16/11/2020
% 

clear
clc

OutDir= 'OutFiles';
if ~isfolder(OutDir),
    mkdir(OutDir);
end

% Use '/' for Mac or Linux and '\' for Windows
sep= '/';               % Default is Mac or Linux
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
L1= 40;
L2= 25;
% Create the Decimator object
h1= fir1(900,1/L1);
firinterp1 = dsp.FIRInterpolator('InterpolationFactor',L1,'Numerator',h1);
h2= fir1(500,1/L2);
firinterp2 = dsp.FIRInterpolator('InterpolationFactor',L2,'Numerator',h2);


DirFiles= dir('*.mat');

for k= 1:length(DirFiles),
    xstruct= load(DirFiles(k).name);
    x1= xstruct.sinal;
    N= length(x1)*L;
    % Generate the sinusoid to modulate the signal
    t= ((0:N-1)*Ts)';
    s= exp(1j*2*pi*Fo*t);
    % Interpolate the input signal
    x = firinterp1(x1);
    x = firinterp2(x);
    % Perform the modulation
    x= x.*s;
    % Write the file
    save([OutDir sep 'I_' DirFiles(k).name],'x','Fs','Fo')
end


