% BioRadar Processing
% This Matlab Script was created to test the signal processing algorithms
% in Matlab.
% It has 3 modes of opperation that can be chosen changing the variable
% Mode:
% 1 - Signal from a channel Mathematical Model
% 2 - Signal from a recorded acquisition
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
% 22/11/2020 - Introduziu-se a decimação por 1000 em dois estágios
%
% ===========================================================

clear all
clc

Mode_f= 2;         % Select the mode of operation
debug_f= 0;        % Set the debug mode of operation
filename_f= 'realsignals/OutFiles/I_seg_16.mat';      % File name for Mode 2 of operation


T_f= 30;           % Acquisition time in seconds. Only for Mode 1 and 3. Ignored for Mode 2

%% Prepare for each type of input signals
switch Mode_f,
    case 1       % Mathematical Model input signal
        disp('Signal from a channel Mathematical Model')
        Fc_f= 5.8e9;             % Analog Carrier Frequency
        Fo_f= 1e4;               % Transmitted sinusoid frequency
        Fs_f= 1e5;               % Sampling Frequency
        N_f= 20000;              % Number of samples per frame
        ar_f= 0.006;             % Breathing amplitude
        Fb_f= 0.31;              % Breathing frequency
        d1_f= 2;                 % Equivalent distance to the static objects
        sig_f= 0.01;             % Channel noise STD
        D1_f= 20;                % Decimation factor 1
        D2_f= 50;                % Decimation factor 2
        D_f= D1_f*D2_f;          % Total decimation factor
        Nd_f = N_f/(D1_f*D2_f);
        Fsd_f= Fs_f/D_f;         % Decimated signal sampling frequency
        fprintf('Fsd= %d Hz\n',Fsd_f) % Decimated sampling frequency
        % Create the BioRadar channel object
        brm_f= BioRadarChannel(Fs_f,Fc_f,N_f,ar_f,Fb_f,d1_f);
        brm_f.nd= 0.005;         % Noise Density Power
        brm_f.A0= 0.1;           % Amplitude of the received echo from the chest
        brm_f.A1= 1;             % Equivalent amplitude of the static echos
        brm_f.Theta= -pi/3;      % Constant Phase shift
        brm_f.d0= 1.009;         % Distance to the chest wall
        
    case 2       % Signal from a real acquisition (baseband decimated)
        disp('Signal from a recorded acquisition')
        gstruct_f= load(filename_f);       % Read the data and parameters
        g_f= gstruct_f.x;                  % Received signal
        M_f= max(abs(g_f))
        g_f= g_f/M_f;
        Fs_f= gstruct_f.Fs;                % Sampling frequency
        Fo_f= gstruct_f.Fo;                % Transmitted sinusoid frequency
        N_f= 20000;                        % Number of Samples per Frame
        D1_f= 20;                          % Decimation Factor 1
        D2_f= 50;                          % Decimation Factor 2
        D_f= D1_f*D2_f;                    % Total decimation factor
        Nd_f = N_f/(D1_f*D2_f);
        Fsd_f= Fs_f/D_f;                   % Decimated signal sampling frequency
        
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
        Fc_f = 5.8e9;                    % Carrier frequency 5.8Ghz
        rxgain_f = 70;                   % Receiver gain
        txgain_f = 50;                   % Tramitter gain
        MasterClockRate_f = 5e6;         % Sampling rate (5 MHz to 56 MHz)
        N_f = 1024*16;                   % Number of Samples per Frame
        Dusrp_f= 50;                     % USRP decimation factor
        Fs_f= MasterClockRate_f/Dusrp_f;     % Sampling rate
        D1_f= 20;                        % Decimation Factor 1
        D2_f= 50;                        % Decimation Factor 2
        Fsd_f= Fs_f/D_f;                 % Decimated signal sampling frequency
        
        % Configure the USRP receiver
        display('Setting parameters for the reception channel...')
        
        rx_SDRu_f = comm.SDRuReceiver(...      % Parameters for the receiver
            'Platform',usrp_dev_f.Platform,...
            'SerialNum',usrp_dev_f.SerialNum,...
            'CenterFrequency',Fc_f,...
            'LocalOscillatorOffset',0,...      % Can we use it for calibration ?
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
        tx_SDRu_f = comm.SDRuTransmitter(...   % Parameters for the receiver
            'Platform',usrp_dev_f.Platform,...
            'SerialNum',usrp_dev_f.SerialNum,...
            'CenterFrequency',Fc_f,...
            'LocalOscillatorOffset',0,...      % Can we use it for calibration ?
            'Gain',txgain_f,...
            'MasterClockRate', MasterClockRate_f,...
            'InterpolationFactor', Dusrp_f,...
            'EnableBurstMode', false,...
            'TransportDataType', 'int16');
        
        display(tx_SDRu_f)
        display('Transmission channel parameters set!')
        
        dataLen_f= N_f;
end


Nframes_f= floor(Fs_f*T_f/N_f);   % Number of Frames to Process

% Create the sinusoidal generator object
sine1_f = dsp.SineWave(1,Fo_f);
sine1_f.SampleRate= Fs_f;
sine1_f.ComplexOutput= 1;
sine1_f.SamplesPerFrame= N_f;

% Create the Decimator objects
h1_f= fir1(D1_f*10,1/D1_f);
firdecim1_f = dsp.FIRDecimator('DecimationFactor',D1_f,'Numerator',h1_f);
h2_f= fir1(D2_f*10,1/D2_f);
firdecim2_f = dsp.FIRDecimator('DecimationFactor',D2_f,'Numerator',h2_f);
% Low-Pass filter to reduce the noise
hlp_f= fir1(50,10/(Fs_f/(2*D_f)));
firlowpass_f= dsp.FIRFilter(hlp_f);

if debug_f
    % Verify the filter frequency response
    figure(101)
    freqz(firdecim1_f);
    figure(102)
    freqz(firdecim2_f);
    pause
end
% Configure the sine wave generator
s_f= sine1_f();

if (Mode_f == 2),
    Nframes_f= floor(length(g_f)/N_f);      % Number of Frames to Process
    T_f= Nframes_f*N_f/Fs_f;
end



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
% Inicialize the variables of the
x= 0;
y= 0 ;
radius= 0;
dfit= 0;


%% arc corretion high pass filter definition
z= 1;
Fa= Fs_f/(D_f);
[B,A]= butter(1,0.5/(Fa/2),'high');

%% Circular Buffer
NumberFramesInCircularBuffer= floor(8*Fsd_f/Nd_f);
fprintf('Number of Samples in the Circular Buffer= %d samples\n',NumberFramesInCircularBuffer*Nd_f)
buff = circularbuffer(Nd_f,NumberFramesInCircularBuffer);

%% fitcorrect memory filter gains setup
axy= 0.1; % coordinates gain
ar= 0.1;  %radius gain

%% Sliding window for time plot
NumberFramesSlidingWindow= 400;
sliwin = slidingwindow(Nd_f,Nd_f*NumberFramesSlidingWindow,'left');

% Sliding window for the circle estimation
sliwinP = slidingwindow(Nd_f,Nd_f*NumberFramesSlidingWindow,'left');

%% Plot Setup

% Plot of the received complex signal and the circle fitr estimation
figure(1)
dum= ones(1,Nd_f);
dum= dum+1j*dum;
H1= plot(dum,'ro');
hold on
H1c= plot(dum,'gx');
hold off
axis(1*[-1 1 -1 1]);
axis square
grid on
% generates the circle plot
if Mode_f == 2 | Mode_f == 1,
    radius = 1;
    th = linspace(0,2*pi,200);
    k = 0;
    xunit = radius * cos(th) + 0;
    yunit = radius * sin(th) + 0;
    hold on
    phi = linspace(0,2*pi,200);
    H2 = plot(xunit,yunit,'.');
    hold off
    title('frame of signal g(n) and circle fitting')
end

% Sliding window of the respiratory signal
figure(2)
Td_f= D_f/Fs_f;
td_f= (0:Nd_f*NumberFramesSlidingWindow-1)*Td_f;
H3 = plot(td_f, sliwin.get());
axis([0 inf -1 1]);
grid on
xlabel('seg.')
title('Respiratory signal')

% Plot for the absolute value of the x y coordinates of the circle fitting
figure(3)
H4= plot(td_f, sliwinP.get());
axis([0 inf -1 1])
grid on
xlabel('seg.')
title('abs circle coordinates')

% Plot for the circular buffer signal
figure(4)
plot(0,0)
axis([-1 1 -1 1])
axis square
title('Circular buffer signal')


% Use this special function to show all figures non overlapping
placeFigures;

% ================================================================
% ================================================================
th = linspace(0,2*pi,200);


%% Main Loop DSP
% This main loop process a frame at a time for all modes of operation
k_f= 0;                         % Auxiliary Counter
nk= 1:N_f;                      % Auxiliary vector for efficiency
Pr= zeros(Nframes_f,3);         % Vector to store the circle estimation
dataLen_f= N_f;                % For compatibility with Modes 1 and 2
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
            r_f= g_f(nk+N_f*k_f);           % Gets a block on N samples form g
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
    
    if (dataLen_f ~= 0),
        % Move the signal to the base band
        g= r_f.*conj(s_f);
        % Decimate the signal
        d1_f = firdecim1_f(g);
        d_f = firdecim2_f(d1_f);
        % Remove out of band noise
        d_f= firlowpass_f(d_f);
    end
    
    
    % Update the data plot for the received complex signal and the circle fit estimation
    % Later put this plot in debug mode
    H1.XData= real(d_f);
    H1.YData= imag(d_f);
    H1c.XData= real(dfit);
    H1c.YData= imag(dfit);
    H2.XData = radius * cos(th) + x;
    H2.YData = radius * sin(th) + y;
    
    % Moving window breathing signal plot
    H3.YData =sliwin.get();
    if (Mode_f == 1) | (Mode_f == 2),
        %pause(N_f/Fs_f)
    end
    
    % Moving window breathing signal plot
    H4.YData =sliwinP.get();
    
    % Update all the plots
    drawnow
    
    % ================================================================
    % ================================================================
    %% DSP code
    buff.put(d_f);
    df = buff.get();
    figure(4)
    plot(df,'.r')
    title('Circular buffer signal')
    
    %% circle fitting
    %gera matriz para o hyperfix
    auxA = real(df);
    auxB = imag(df);
    P = HyperSVD([auxA,auxB]);          % foi escolhido o svd por uma questão de estabilidade
    
    %% Heuristic algorithms to limit the ampitude of the (x,y) coordinates and radius
    Lim= 0.5;
    for nl= 1:3,
        if abs(P(nl)) > Lim,
            P(nl)= sign(P(nl))*Lim;
        end
    end
    
    Pr(nf,:)= P;
    sliwinP.put(abs(P(1)+j*P(2)))
    
    %% Low Pass Filter the circle fitting parameters
    x = axy*P(1) + (1-axy)*x;                       % x coordinate of the circle
    y = axy*P(2) + (1-axy)*y;                       % y coordinate of the circle
    radius = ar*P(3) + (1-ar)*radius;               % radius of the circle
    
    % Removes the complex DC component due to the static obstacles
    dfit = (real(d_f)-x) + j*(imag(d_f)-y);
    
    %% Angle conditioning
    phi = angle(dfit);
    phi = unwrap(phi);                  % tribolet algorithm
    [phif,z] = filter(B,A,phi,z);
    % High Pass filtering
    sliwin.put(phif);
    % ================================================================
    % ================================================================
    
end % Main Loop DSP

disp(['Acquisition Time= ' num2str(toc)])

if (Mode_f == 3),
    release(rx_SDRu_f)
end
release(firdecim1_f)
release(firdecim2_f)

