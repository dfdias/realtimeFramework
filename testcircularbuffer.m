clear all
clc

F= 3;
N = 2;
ocb = circularbuffer(F,N);
x= 1:100;

for n = 1:2:40
    b = x(n:n+N-1);
    ocb.put(b)
    ocb.get()
    pause
end


