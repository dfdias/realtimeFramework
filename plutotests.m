clear all;
close all;
clc;

Fs = 1e6
radio = findPlutoRadio()
status = configurePlutoRadio('AD9363', 'usb:0') %%firmware with greater tunning abilities
Fc = 3e9;
Gain = -1;
F0 = 10e3;
tx_obj = sdrtx('Pluto','Gain',Gain,'CenterFrequency',Fc,'ShowAdvancedProperties',1,'DataSourceSelect','DDS','DDSTone1Freq',1,'DDSTone1Scale',0,'DDSTone2Freq',0);
rx_obj = sdrrx('Pluto','Gain',Gain,'CenterFrequency',Fc);

a = capture(rx_obj,0.01,'Seconds');
release(rx_obj)

figure
plot(real(a))