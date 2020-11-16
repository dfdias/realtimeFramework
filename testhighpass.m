clear all
close all
clc
 f = [0 0.05 0.1 1]
 a = [0 0.8 1 1]
 b = firpm(100,f,a)
Fs = 1000
t = (0:1e4)/Fs;
f = 0.3
A = 2
DC = 2 + 2*j
[B,A] = butter(2,0.05/(Fs/2),'high');


dfit = 2*exp(-j*2*pi*f*t) + DC;

figure(1)
% 
plot(t,real(dfit))

phi = angle(dfit);
phi = unwrap(phi);%tribolet

figure(2)
plot(t,phi)

[pxx,f] = pwelch(phi,1024,300,2048,Fs);

figure(3)
plot(f,pxx)

phi =filter(b,1,phi); %filtragem passo a alto

figure(4)

plot(t,phi)

[pxx,f] = pwelch(phi,[],[],4096,Fs);

figure(5)
plot(f,pxx)
f(find(pxx == max(pxx)))


