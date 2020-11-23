function y= decimatepoly(x,D,h)
% DECIMATEPOLY(X,D)
% Polyphase decimator
% x is the input signal
% D is the decimation factor
% h is the FIR filter

N= length(x);
x= [zeros(1,D-1) x 0];
Nf= length(h);

Z= zeros(Nf/D-1,D);

Nframe= N/D;
y= zeros(1,Nframe);
for n= 0:Nframe-1,
    Dl= x((D:-1:1)+n*D);
    y2= 0;
    for k= 1:D,
        [y1,Z(:,k)]= filter(h(k:D:end),1,Dl(k),Z(:,k));
        y2= y2 + y1;
    end
    y(n+1)= y2;
end