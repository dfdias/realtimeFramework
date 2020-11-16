classdef BioRadarChannel
    % BioRadar Channel Model
    % This class defines a Bio Radar Model with two reflections components
    % A chest wall reflection
    % A reflection contribution from all the static objects in the
    % environment
    % This is a digital model of the bio-radar channel that uses the
    % baseband model
    % y(t)= A0*x(t)*exp(-jwc*tau0(t)) + A1*x(t)*exp(-j*wc*tau1)
    % where tau0(t) is the chest wall movement an tau1 is the delay of all
    % the static reflections
    
    properties (Constant)
        c= 299792458; % Speed of Light
    end
    
    properties
        Fs            % Sampling Frequency
        N             % Number of samples in a frame
        Fb            % Breathing frequency
        Fc            % Analog Carrier Frequency
        nd            % Noise Density Power
        A0            % Amplitude of the received echo from the chest
        A1            % Equivalent amplitude of the static echos
        Theta         % Constant Phase shift
        d0            % Distance to the chest wall
        ar            % Breathing amplitude
        d1            % Equivalent distance to the static objects
        lambda
        t
        theta1
        sineb
    end
    
    methods
        function y= Evaluate(obj,x)
            b= obj.sineb();
            phi= rem(-4*pi*obj.d0/obj.lambda - obj.Theta, 2*pi);
            phi= phi - 4*pi*b/obj.lambda;
            n= obj.nd*(randn(1,obj.N)'+1j*randn(1,obj.N)');
            y= x .* (obj.A0*exp(j*phi) + obj.A1*exp(j*obj.theta1)) + n;
%             fprintf("X= %d\n",real(obj.A1*exp(j*obj.theta1)))
%             fprintf("Y= %d\n",imag(obj.A1*exp(j*obj.theta1)))
        end
        
        function brc = BioRadarChannel(Fs,Fc,N,ar,Fb,d1)
            if nargin >0
                brc.Fs= Fs;
                brc.Fc= Fc;
                brc.N= N;
                brc.ar= ar;
                brc.Fb= Fb;
                brc.d1= d1;
            end
            % Breathing signal in meters
            brc.sineb = dsp.SineWave(brc.ar,brc.Fb);
            brc.sineb.SampleRate= brc.Fs;
            brc.sineb.ComplexOutput= 0;
            brc.sineb.SamplesPerFrame= brc.N;
            % Set some usful variables
            brc.lambda= brc.c/brc.Fc;
            brc.t= (0:brc.N-1)/brc.Fs;
            brc.theta1= rem(-4*pi*brc.d1/brc.lambda, 2*pi);
        end
    end
end

