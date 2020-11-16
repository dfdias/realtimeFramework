from scipy import signal as sigs
from matplotlib import  pyplot as plt
import matplotlib.animation as animation
from dds_gen import dds_gen as gen
import time
from window import *
Fs = 100
N = 1000
f0 = 1

sine1 = gen(1000,Fs,1,f0,False)

win = window(N,N*10,'right')
fig = plt.figure()
x = np.arange(0,N*10)/Fs
l, = plt.plot(x,win.get())
plt.show(block = False)


while(1):
    f = sine1.gen2()
    win.put(f)
    l.set_ydata(win.get())
    plt.show()
    plt.pause(0.1)

