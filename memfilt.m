clear all
clc

 

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

%arc corretion high pass filter definition

fa = Fs/D;
[B,A] = butter(1,0.1/(fa/2),'high');
Hd.B = B; %handle creation
Hd.A = A;

%Circular Buffer
buff = circularbuffer(100,N/D)


%fitcorrect memory filter gains setup

axy = 0.5 % coordinates gain
ar = 0.5  %radius gain


s= sine1();              % Sinudoid wo (digital modulation)

figure(1)                % Creates a dummy variable 
dum= ones(1,N/D);            
dum= dum+1j*dum;

H1= plot(dum,'o');
axis(4*[-1 1 -1 1]);
grid on
%generates the circle plot
radius = 1
th = 0:pi/50:2*pi;
k = 0;
xunit = radius * cos(th) + 0;
yunit = radius * sin(th) + 0;

hold on
phi = linspace(1,2*pi,200)
c = (brm.A0*exp(j*phi) + brm.A1*exp(j*brm.theta1)) %ideal circle plot
H5 = plot(xunit,yunit,'o');
H6 = plot(c);
hold off


figure(2)
m = zeros(1,4e3)
H10 = plot(m)
axis([0 inf -5 5])
grid on

x_past = 0
y_past = 0
r_past = 0

T = 30 %simulation time
Nframes= round(Fs*T/N); 



for nf = 1:Nframes
% Process the frame
if nf == round(Nframes/2)
    brm.theta1 = -pi/4;
    brm.A1 = 2;
    c = (brm.A0*exp(j*phi) + brm.A1*exp(j*brm.theta1))
    H6.XData = real(c)
    H6.YData = imag(c)

end

s = sine1();
r= brm.Evaluate(s);
k= k+1;
% Move the signal to the base band
g= r.*conj(s);
%f = filter(hd,g)
d = firdecim(g);
%% DSP code
buff.appends(d')%adiciona uma frame ao buffer


% Later put this plot in debug mode
idxs = buff.getorder() ;%obtem as frames ordenadas do buffer circular
a = buff.buffer(:,idxs);
df = a(:);

[f,x,y,r] = fit_correct(df,x_past,y_past,r_past,axy,ar,Hd,false);%aplicação de circle fit filtro e correção do arco
x_past = x;%atualização das variáveis
y_past = y;
r_past = r;

H1.XData= real(d);
H1.YData= imag(d);
H5.XData = r * cos(th) + x;
H5.YData = r * sin(th) + y;



%moving window breathing signal plot
   aux_m = (m(1 : end-length(f)));
   m(1:length(f)) = f;
   m(length(f)+1: end) = aux_m;
  
H10.YData = m %moving window


pause(N/Fs)
drawnow
end
