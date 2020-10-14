clear all
close all
clc

T = 30

%% Setting channel model constants

Fc= 5.8e9;             % Analog Carrier Frequency
Fo= 1e5;               % Transmitted sinusoid frequency
Fs= 1e5;               % Sampling Frequency
N= 1000;               % Number of samples per frame
ar= 0.005;             % Breathing amplitude
Fb= 0.31;              % Breathing frequency
d1= 2;                 % Equivalent distance to the static objects
D= 100

brm= BioRadarChannel(Fs,Fc,N,ar,Fb,d1);
brm.nd= 0.005;           % Noise Density Power
brm.A0= 2;           % Amplitude of the received echo from the chest
brm.A1= 1;             % Equivalent amplitude of the static echos
brm.Theta= -pi/3;      % Constant Phase shift
brm.d0= 1.009;         % Distance to the chest wall

% Create the sinusoidal generator objec
sine1 = dsp.SineWave(1,10e3);
sine1.SampleRate= Fs;
sine1.ComplexOutput= 1;
sine1.SamplesPerFrame= N;

% Create the Decimator object
h= fir1(500,1/D);
firdecim = dsp.FIRDecimator('DecimationFactor',D,'Numerator',h);

s= sine1();              % Sinudoid wo (digital modulation)


figure(1)
dum= ones(1,N/D);             % Creates a dummy variable
dum= dum+1j*dum;
H1= plot(dum,'o');
axis(2*[-1 1 -1 1]);
grid on
k = 0;
xunit = r * cos(th) + 0;
yunit = r * sin(th) + 0;
hold on
H5 = plot(xunit,yunit)
hold off


radius = 1
figure(2)
H3=polarplot(angle(dum),abs(dum));
hold on
radius = 1;
x = 0
y = 0
th = 0:pi/50:2*pi;
xunit = 0 * cos(th) + x;
yunit = 0 * sin(th) + y;
[theta,rho] = cart2pol(xunit,yunit)
H4 = polarplot(theta,rho)
hold off


buff = circularbuffer(100,10)
x_past = 0;
y_past = 0;
r_past = 0;
a1 = 0.3;
a2 = 0.7;
idx = 1
Nframes =round(Fs*T/N) ;
for nf = 1:Nframes
% Process the frame
r= brm.Evaluate(s);
k= k+1;
% Move the signal to the base band
g= r.*conj(s);
d = firdecim(g);
%% DSP code

idx = idx +1;
buff.appends(d')%adiciona uma frame ao buffer


% Later put this plot in debug mode
idxs = buff.getorder() ;%obtem as frames ordenadas do buffer circular
a = buff.buffer(:,idxs)
df = a(:)
[f,x,y,r] = fit_correct(df,x_past,y_past,a1,a2,false);%aplicação de circle fit filtro e correção do arco
x_past = x;%atualização das variáveis
y_past = y;
figure(1)
H1.XData= real(d);
H1.YData= imag(d);
H5.XData = r * cos(th) + x;
H5.YData = r * sin(th) + y;

figure(2)

H3.XData = angle(f);
H3.YData = abs(f);

xunit = r * cos(th) + 0;
yunit = r * sin(th) + 0;
[theta,rho] = cart2pol(xunit,yunit)
H4.XData = theta
H4.YData = rho
pause(N/Fs)
drawnow
end
