% Test the decimatepoly

clear
clc

N= 1e6;
x= 0:N-1;
Nf= 500;
h= randn(1,Nf);

D= 100;   % Decimation factor
tic
y= decimatepoly(x,D,h);
toc


tic
yf= filter(h,1,x);
yf= yf(1:D:end);
toc
