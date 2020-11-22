classdef circularbuffer < handle
% CIRCULARBUFFER
% This object implements a circular buffer with 3 methods
% Constructor obj= circularbuffer(N,len)
% N number of samples of each frame
% len Number of frames of the circular buffer

% Duarte Dias
% November 2020
    
    properties
        buffer  % circular buffer
        p1      % ponteiro1
        len     % number of frames
        N       % frame size
    end
    
    methods 
        function obj = circularbuffer(N,len) %constructor
            obj.p1 = 0; %write pointer| aponta para a posição de escrita
            obj.len = len;
            obj.N = N;
            obj.buffer = zeros(obj.N,obj.len); %initializes the frame buffer asa zero meatrix with lenx X N dimension
        end
        
       function put(obj,frame)      %adds frame to buffer
           obj.buffer(:,obj.p1+1) = frame;%index offset
           obj.p1 = mod(obj.p1 +1,obj.len);   %increments the write pointer
       end
        
        
       function y = get(obj)
            idx = obj.p1 : 1 : obj.p1+obj.len-1; %generates a vector of indexes
             %applies the module to adapt the indexes generated to the actual vector lenght and apllies a offset to avoid non positive integer error
            idx = mod(idx,obj.len)+1;  
            a = obj.buffer(:,idx);
            y = a(:);    
        end
    end
end