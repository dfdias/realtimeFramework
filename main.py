from dds_gen import dds_gen
import numpy as np
from circbuffer import circbuffer
import circle_fit
from scipy import signal as sigs
from matplotlib import pyplot as plt
from window import window
import scipy.io
import time

import queue



# Simulation mode selection
realtime = False
debug = True
# File reading
mat = scipy.io.loadmat('sintetico.mat')
signal = mat['x']
signal = signal.flatten()


# Variable declaration
N = 1000
D = 100
z = np.array([0])
x = 0
y = 0
r = 0
Nd = round(N / D)
if realtime is False :
    Fs = mat['Fs'][0]
    Fo = mat['Fo']
    Fs = Fs[0]
    Fo = Fo[0]
    Nframes = int(len(signal)/N)
    frametime = N/Fs
else :
    Fs = 1e5
    T = 30  # simulation time
    Nframes = round((Fs * T) / N)
    frametime = N/Fs




# Signal generator
sine1 = dds_gen(N, Fs, 1, Fo, True)

# HighPass Filter
fa = Fs/D
B,A = sigs.butter(1,0.5/(fa/2),btype='high')

# Memory Filter Coefficients
axy = 0.1                                              # coordinates gain
ar = 0.51                                              # radius gain
# Circular Buffer Declaration
buff = circbuffer(Nd,Nd*10,'complex')

# Sliding window Declaration
win = window(int(Nd),int(500*Nd),'right')
# initializing plots
plt.ion()
fig = plt.figure()

# plot2 sliding window
lenX = len(win.get())
t = np.arange(0, lenX)/(Fs/D)
fig2 = plt.figure()
plt2 = plt.plot(t, win.get())
#plt.ylim(-(np.max(np.abs(signal))),(np.max(np.abs(signal))))
plt.ylim(-1,1)

if realtime is False:
# main cycle
    for nf in range (0,Nframes):
        time.time()
        rx = signal[nf*N:(nf+1)*N]
        s = sine1.gen2()
        g = rx*np.conj(s)
        d = sigs.decimate(g, D, 20, ftype='fir', zero_phase=True)
        d.flatten()
        # buffer
        buff.put(d)
        df = buff.get()
        #print(df)
        # Circle Fitting
        auxA = np.real(df)
        auxB = np.imag(df)
        print(auxA)
        P = circle_fit.least_squares_circle([auxA, auxB])
        print(P)
        # low pass memory filter
        x = axy*P[0] + (1-axy)*x
        y = axy*P[1] + (1-axy)*y
        r = ar*P[3] + (1-ar)*r

        # Signal Filtering
        dfit = (np.real(d)-x) + 1j*(np.imag(d)-y)

        # Angle conditioning
        phi = np.angle(dfit)
        phi = np.unwrap(phi)
        phi,z = sigs.lfilter(B, A, phi, zi = z)

        win.put(phi)
        # Plot updates
        plt2[0].set_ydata(win.get())
        fig2.canvas.draw()
        fig2.canvas.flush_events()

       # runtime = time.time()
        time.sleep(frametime)

if realtime is True :
    print("Operating in Realtime") #TBD

        # Plot Update
plt.show()
