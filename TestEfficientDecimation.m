% In this program we test efficient strategies to decimate a signal by a
% large factor.
% The decimation is performed using several decimation stages
% We also test combfilters
% We use the Matlab dsp lib
% Performed tests
% 1- Decimation using the decimation function
% 2- Decimation using the dsp lib
% 3- Decimation using the comb filters


clear
clc

Fs= 1e5;
D1= 20;
D2= 50;

N= 1e6;         % number of samples of the input signal
Nf= 1e4;        % Nuber of sampes per frame

Fsd= Fs/(D1*D2);
fprintf('Decimated Sampling Frequency= %d Hz\n', Fsd)

x= randn(Nf,1);


% test 1 with the decimation function
disp('Test 1')
tic
Nframes= N/Nf;
for k= 1:Nframes,
    x1= decimate(x, D1);
    x2= decimate(x1, D2);
end
1000*toc/Nframes



% Test 2 with the dsp lib
disp('Test 1')
h1= fir1(D1*10,1/D1);
figure(1)
freqz(h1,1,2^16,Fs)
firdecim1 = dsp.FIRDecimator('DecimationFactor',D1,'Numerator',h1);

h2= fir1(D2*10,1/D2);
figure(2)
freqz(h2,1,2^16,Fs)
firdecim2= dsp.FIRDecimator('DecimationFactor',D2,'Numerator',h2);

tic
Nframes= N/Nf;
for k= 1:Nframes,
    x1= firdecim1(x);
    x2= firdecim2(x1);
end
1000*toc/Nframes

release(firdecim1)
release(firdecim2)





