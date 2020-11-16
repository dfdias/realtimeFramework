from Channel import Channel
from dds_gen import dds_gen
import numpy as np
from circbuffer import circbuffer
from circle_fit import hyper_fit
from scipy import signal as sigs
from matplotlib import  pyplot as plt
import time
from queue import Queue as q

# Variable declaration
Fs = 1e5
N = 1000
D = 100
z = 0
# Simulation mode selection
realtime = False
debug = True
T = 30                                                  # simulation time
Nframes = np.round((Fs*T)/N)

# Signal generator
sine1 = dds_gen(N, Fs, 1, 10e3, True)

# HighPass Filter
fa = Fs/D
B,A = sigs.butter(1,0.5/(fa/2),btype='high')

# Memory Filter Coefficients
axy = 0.5                                              # coordinates gain
ar = 0.5                                               # radius gain
# Circular Buffer Declaration
buff = circbuffer(100, 10)

# initializing plots

if realtime is False:
# main cycle
    for nf in range (0,Nframes):
        s = sine1.gen2()
        g = rx@np.conj(s)
        d = sigs.decimate(g, D, 20, ftype='fir', zero_phase=True)

        # buffer
        buff.put(d)
        df = buff.get()

        # Circle Fitting
        auxA = np.real(df)
        auxB = np.imag(df)
        P = hyper_fit([auxA, auxB])

        # low pass memory filter
        x = axy*P[0] + (1-axy)*x
        y = axy*P[1] + (1-axy)*y
        r = ar*P[3] + (1-ar)*r

        # Signal Filtering
        dfit = (np.real(d)-x) + 1j*(np.imag(d)-y)

        # Angle conditioning
        phi = np.angle(dfit)
        phi = np.unwrap(phi)
        phi,z = sigs.lfilter(B, A, phi, zi=z)

        # Window put

if realtime is True :
    print("Operating in Realtime") #TBD

        # Plot Update
plt.show()
