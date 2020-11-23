% Polyphase decimator
clear
clc

N= 20;
x= 0:N-1;

Nf= 8;
h= randn(1,Nf);

D= 4;   % Decimation factor

x= [zeros(1,D-1) x];

Z= zeros(Nf/D-1,D);
Nframe= N/D;
for n= 0:Nframe-1,
    Dl= x((D:-1:1)+n*D);
    Dl'
    y2= 0;
    for k= 1:D,
        [y1,Z(:,k)]= filter(h(k:D:end),1,Dl(k),Z(:,k));
        y2= y2 + y1;
    end
    y(n+1)= y2;
end


x
h
y
yf= filter(h,1,x);
yf= yf(D:D:end)