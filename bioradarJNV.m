% BioRadar Processing
% This Matlab Script was created to test the signal processing algorithms
% in Matlab.
% It has 3 modes of opperation that can be chosen changing the variable
% Mode:
% 1 - Signal from a channel Mathematical Model
% 2 - Signal from a recorded acquisition (baseband decimated)
% 3 - Real Time DSP using an USRP
%
% For all the modes of operation, the DSP is performed buffer by buffer
% using the dsp toolbox of Matlab
%
% For the Mode 2 we consider a sample rate of 100Hz and the signal is
% already at the base band and decimated

% Jose Vieira e Duarte Dias
% 30/08/2020

% ===========================================================
% Pending tasks to complete
% 30/8/2020 - Acabar de arrumar o código para poder correr usando as várias fontes
% 31/8/2020 - Acabar o objeto BioRadarChannel. Garantir a continuidade de
% fase nas chamadas consecutivas
% 1/9/2020  - Implementar o canal do BioRadar com o modelo y(t)=
% x(t)*exp(-jwco*tau(t)). Para o tau(t) usar a função dsp.sine
% 3/9/2020 - O objeto que implementa o canal está pronto. Falta só realizar
% o debug
% 13/9/2020 - O modelo do canal para o bioradar está concluído e testado.
% Também foi foi incluído neste script, sendo possível aplicar o mesmo
% algoritmo a sinais adquiridos em tempo real com o USRP ou usando o modleo
% do canal.
% Falta terminar o Mode 2 que usa sinais adquiridos previamente. Falta
% ainda arrumar o código e os comentários de modo a torná-lo utilizável por
% qualquer investigador que necessite
% 16/09/2020 - O Modo 2 está quase pronto. Falta definir de forma
% conveniente a frequência de amostragem antes e dpois da decimação e o
% tamanho dos buffers.
% 
% ===========================================================

clear all
close all
clc

Mode_f= 2;         % Select the mode of operation
debug_f= 0;        % Set the debug mode of operation
filename_f= 'realsignals/OutFiles/I_seg_23.mat';      % File name for Mode 2 od operation


T_f= 30;           % Acquisition time in seconds. Only for mode 1 and 3

%% Prepare for each type of input signals
switch Mode_f,
    case 1       % Mathematical Model input signal
        disp('Signal from a channel Mathematical Model')
        Fc_f= 5.8e9;             % Analog Carrier Frequency
        Fo_f= 1e4;               % Transmitted sinusoid frequency
        Fs_f= 1e5;               % Sampling Frequency
        N_f= 1000;              % Number of samples per frame
        ar_f= 0.006;             % Breathing amplitude
        Fb_f= 0.31;              % Breathing frequency
        d1_f= 2;                 % Equivalent distance to the static objects
        sig_f= 0.01;             % Channel noise STD
        D_f= 100;                % Decimation Factor
        Nd_f = N_f/D_f
        
        % Create the BioRadar channel object
        brm_f= BioRadarChannel(Fs_f,Fc_f,N_f,ar_f,Fb_f,d1_f);
        brm_f.nd= 0.005;         % Noise Density Power
        brm_f.A0= 0.1;           % Amplitude of the received echo from the chest
        brm_f.A1= 1;             % Equivalent amplitude of the static echos
        brm_f.Theta= -pi/3;      % Constant Phase shift
        brm_f.d0= 1.009;         % Distance to the chest wall
        
        % Create the sinusoidal generator objec
        sine1_f = dsp.SineWave(1,Fo_f);
        sine1_f.SampleRate= Fs_f;
        sine1_f.ComplexOutput= 1;
        sine1_f.SamplesPerFrame= N_f;
        
        % Create the Decimator object
        h_f= fir1(500,1/D_f);
        firdecim_f = dsp.FIRDecimator('DecimationFactor',D_f,'Numerator',h_f);
        
        
    case 2       % Signal from a real acquisition (baseband decimated)
        disp('Signal from a recorded acquisition')
        g_f= load(filename_f); 
        Fs_f = g_f.Fs;                       % Sampling frequency (manually set)
        Fo_f = g_f.Fo
       
        N_f= 1000;
        D_f = 100
        Nd_f = N_f/D_f
        % Number of Samples per Frame
             % Read all the data
        g_f= g_f.x;
        MG_f= max(abs(g_f));               % 
        
    case 3       % Real Time DSP using an USRP
        disp('Real Time DSP using an USRP')
        % Check for the presence of the USRP
        usrp_dev_f= findsdru();
        if strcmp(usrp_dev_f.Status, 'Success'),
            disp(['USRP ' usrp_dev_f.Platform ' detected'])
        else
            error(['USRP not detected'])
        end
        
        % Set all the necessary variables for Real Time operation
        Fo_f = 1e4;
        Fc_f = 4.0e9;                    % Carrier frequency 1.5Ghz
        rxgain_f = 70;                   % Receiver gain
        txgain_f = 50;                   % Tramitter gain
        MasterClockRate_f = 5e6;         % Sampling rate (5 MHz to 56 MHz)
        N_f = 1024*16;                   % Number of Samples per Frame
        Dusrp_f= 50;                     % USRP decimation factor
        Fs_f= MasterClockRate_f/Dusrp_f;     % Sampling rate
        D_f= 64;                         % Decimation
        Nd_f = N_f/D_f
        % Configure the USRP receiver
        display('Setting parameters for the reception channel...')
        
        rx_SDRu_f = comm.SDRuReceiver(...     % Parameters for the receiver
            'Platform',usrp_dev_f.Platform,...
            'SerialNum',usrp_dev_f.SerialNum,...
            'CenterFrequency',Fc_f,...
            'LocalOscillatorOffset',0,...   % Can we use it for calibration ?
            'Gain',rxgain_f,...
            'MasterClockRate', MasterClockRate_f,...
            'FrameLength', N_f,...
            'DecimationFactor', Dusrp_f,...
            'EnableBurstMode', false,...
            'TransportDataType', 'int16',...
            'OutputDataType', 'single');
        
        display(rx_SDRu_f)
        display('Reception channel parameters set!')
        
        % Configure the USRP transmitter
        display('Setting parameters for the transmission channel...')
        tx_SDRu_f = comm.SDRuTransmitter(...     % Parameters for the receiver
            'Platform',usrp_dev_f.Platform,...
            'SerialNum',usrp_dev_f.SerialNum,...
            'CenterFrequency',Fc_f,...
            'LocalOscillatorOffset',0,...   % Can we use it for calibration ?
            'Gain',txgain_f,...
            'MasterClockRate', MasterClockRate_f,...
            'InterpolationFactor', Dusrp_f,...
            'EnableBurstMode', false,...
            'TransportDataType', 'int16');
        
        display(tx_SDRu_f)
        display('Transmission channel parameters set!')
        
        dataLen_f= N_f;
end

if (Mode_f == 1) | (Mode_f == 3),
    Nframes_f= floor(Fs_f*T_f/N_f);   % Number of Frames to Process
    
    % Create the sinusoidal generator objec
    sine1_f = dsp.SineWave(1,Fo_f);
    sine1_f.SampleRate= Fs_f;
    sine1_f.ComplexOutput= 1;
    sine1_f.SamplesPerFrame= N_f;
    
    % Create the Decimator object
    h_f= fir1(500,1/D_f);
    firdecim_f = dsp.FIRDecimator('DecimationFactor',D_f,'Numerator',h_f);
    
    if debug_f
        % Verify the filter frequency response
        freqz(firdecim_f);
        pause
    end
    % Configure the sine wave generator
    s_f= sine1_f();

elseif (Mode_f == 2),
    % Create the sinusoidal generator objec
    sine1_f = dsp.SineWave(1,Fo_f);
    sine1_f.SampleRate= Fs_f;
    sine1_f.ComplexOutput= 1;
    sine1_f.SamplesPerFrame= N_f;
    
    % Create the Decimator object
    h_f= fir1(500,1/D_f);
    firdecim_f = dsp.FIRDecimator('DecimationFactor',D_f,'Numerator',h_f);
    Nframes_f= floor(length(g_f)/N_f);      % Number of Frames to Process
    T_f= Nframes_f*N_f/Fs_f;
end


% Prepare the real time Real/Imaginary plot
figure(1)
% Creates a dummy variable for the plot
if (Mode_f == 2),
    dum_f= ones(1,N_f);
else
    dum_f= ones(1,N_f/D_f);
    d_f= dum_f;
    MG_f= 2;
end
dum_f= dum_f+1j*dum_f;
H1_f= plot(dum_f,'o');
axis(MG_f*[-1 1 -1 1]);
grid on

% wait while USRP channel turns on
if Mode_f == 3,
    underrun_f= tx_SDRu_f(s_f);
    datalen_f= 0;
    while datalen_f==0
        [r_f,datalen_f]= rx_SDRu_f();
    end
end

% ================================================================
% ================================================================
% Put the Inicialization code here
% 
x = 0
y = 0 
dfit = 0
%% arc corretion high pass filter definition
z  = 1;
if Mode_f == 2 
    fa = Fs_f; 
elseif Mode_f == 1 || Mode_f == 3
    fa = Fs_f/D_f;
end
    [B,A] = butter(1,0.5/(fa/2),'high');
%Ha = dfilt.df1(B,A)%trying direct form filter
%% Circular Buffer
if Mode_f == 3
    Nd = N_f/D_f;
    buff = circularbuffer(10*Nd,Nd);
else
    buff = circularbuffer(10*N_f,N_f)

end

%% fitcorrect memory filter gains setup

axy = 0.1 % coordinates gain
ar = 0.1  %radius gain

%% Sliding window for time plot
if Mode_f == 3
    Nd = N_f/D_f;
   win = slidingwindow(Nd,Nd*50,'left')
else
   win = slidingwindow(N_f,N_f*10,'left')
end

%% Plot Setup
figure(1)                % Creates a dummy variable 

H1= plot(dum_f,'o');
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
H2 = plot(xunit,yunit,'o');

hold off

figure(2)
phi = linspace(0,2*pi,200)
H5 = plot(dum_f,'o'); %ideal circle plot
axis(1/100*[-1 1 -1 1]);
hold on
H6 = plot(xunit,yunit);
figure(3)
hold off

H4 = plot(win.get())
if Mode_f == 1
    H4.XData = (0:N_f*10-1)/(Fs_f/D_f)
elseif Mode_f == 2
     H4.XData = (0:N_f*10-1)/(Fs_f)
end
axis([0 inf -0.5 0.5])
grid on
% ================================================================
% ================================================================


%% Main Loop DSP
% This main loop process a frame at a time for all modes of operation
k_f= 0;                         % Auxiliary Counter
nk= 1:N_f;                      % Auxiliary vector for efficiency
tic
for nf= 1:Nframes_f,
    % Get a new frame signal according to the selected input
    switch Mode_f,
        case 1
            % Signal from a channel Mathematical Model
            s_f= sine1_f();               % Sinudoid wo (digital modulation)
            r_f= brm_f.Evaluate(s_f);       % BioRadar channel simulation
            
        case 2
            % Signal from a recorded acquisition
            d_f= g_f(nk+N_f*k_f);           % Gets a block on N samples form g
            k_f= k_f+1;
            
        case 3
            % Real Time DSP using an USRP
            s_f= sine1_f();               % Sinudoid wo (digital modulation)
            underrun_f= tx_SDRu_f(s_f);                       % Transmit a frame
            [r_f,dataLen_f,overrun_f] = rx_SDRu_f();            % Reads a frame of the input signal
            if (length(dataLen_f) == 0),
                disp('Empty frame')
            end
            % detect underrun
            if (underrun_f ~= 0),
                disp('underrun');
            end
            if (overrun_f ~= 0),
                disp('overrun');
            end
            
    end % Switch
    
    if (Mode_f==1) | ((Mode_f==3) & (dataLen_f ~= 0)),
        % Process the frame
        k_f= k_f+1;
        % Move the signal to the base band
        g_f= r_f.*conj(s_f);
        d_f = firdecim_f(g_f);
    end
     
    % Later put this plot in debug mode
        H1.XData= real(d_f);
        H1.YData= imag(d_f);
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
        drawnow
        if (Mode_f == 1) | (Mode_f == 2),
            pause(N_f/Fs_f)
        end
    
    % ================================================================
    % ================================================================
        %% DSP code
        buff.put(d_f)
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
        dfit = (real(d_f)-x) + j*(imag(d_f)-y);

        %% Angle conditioning
        phi = angle(dfit);
        phi = unwrap(phi);%tribolet
        [filtered,z] = filter(B,A,phi,z);
         %filtragem passo a alto
        win.put(filtered)
        [pxx,f] = pwelch(win.get(),[],[],4096,Nd_f);
        f(find(pxx == max(pxx)))
    % ================================================================
    % ================================================================
    
end % Main Loop DSP

disp(['Acquisition Time= ' num2str(toc)])

if (Mode_f == 3),
    release(rx_SDRu_f)
end

