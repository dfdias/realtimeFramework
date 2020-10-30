from dds_gen import dds_gen as gen
from matplotlib import pyplot as plt
from Channel import Channel


fc = 5.8e9
f0 = 1e5
fs = 1e5
N = 1000
ar = 0.005
fb = 10e3
d1 = 2
sig = 0.01
D = 1000
T = 30

sine1 = gen(N,fs,1,f0)
a = sine1.gen(fb,N)

plt.figure(1)
plt.plot(a)
plt.show()