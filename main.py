from Channel import Channel
from dds_gen import dds_gen as gen
import numpy as np
from scipy import signal as sigs
import time
##made only for mathematical MODEL
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

brm = Channel(fs,fc,N,ar,fb,d1)
brm.nd = 0.005
brm.A0 = 0.1
brm.A1 = 1
brm.Theta = -np.pi/3
brm.d0 = 1.009

#sin generator
sine1 = gen(N,fs,1,fb)

#fir filter
filt_coefs = sigs.firwin(500,1/D)
nframes = np.round(fs*T/N).astype(np.int64)
for nf in range (0,nframes):
    s = sine1.gen2()
    r = brm.evaluate(s)

