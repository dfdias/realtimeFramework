classdef framework < handle

    
    properties
        buffer  %circular buffer
        p1      %ponteiro1
        p2      %ponteiro2
        len     %number of frames
    end
    
    methods 
        function obj = framework(len) %constructor
            obj.p1 = 0 %write pointer
            obj.p2 = 0 % read pointer
            obj.len = len
            obj.buffer = zeros(obj.len,10) 
        end
        
       function y = appends(obj,a)      %adds frame to buffer
           if obj.p1 > obj.len 
               obj.p1 = mod(obj.p1,obj.len);
           end
           obj.buffer(obj.p1+1,:) = a;
           obj.p1 = obj.p1 +1;   
           y = 'done';
       end
        

        function y = get(obj) %gets frames N frames
            y = 0;
            idx = obj.p1 : 1 : obj.p1+obj.len-1; %generates a vector of indexes
             %applies the module to adapt the indexes generated to the actual vector lenght and apllies a offset to avoid non positive integer error
            idx = mod(idx,obj.len)+1  
            for i=1 : length(idx)
                y =  [y obj.buffer(idx(i),:)]; %fills the return vector with every frame in the buffer by order
            end;
            y = y(2:end) %fixes the first 0 offset
        end
    end
end