classdef slidingwindow < handle
%Duarte Dias -DETI_UA 11/3/2020
    
    properties
        
        len     %frame length 
        N       %number of window samples
        window  % window array
        dir     %slide direction

    end
    
    methods 
        function obj = slidingwindow(len,N,dir) %constructor
            obj.len = len;
            obj.N = N;
            obj.window = zeros(1,N);
            obj.dir = dir;
        end
        
       function put(obj,frame)      %adds frame to window
           if contains(obj.dir,'right')
               aux = obj.window(1 : end-obj.len);
               obj.window(1:obj.len) = frame;
               obj.window(obj.len + 1 : end) = aux;
           end
           if contains(obj.dir,'left')
               aux = obj.window(obj.len+1 : end);
               obj.window(obj.N-obj.len+1:end) = frame;
               obj.window(1:length(aux)) = aux;
           end
       end
        
       function y = get(obj) 
            y = obj.window;
        end
    end
end