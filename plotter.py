from matplotlib import pyplot as plt
import numpy as np
import scipy.signal as sig
class plotter :

    def __init__(self,Fs):

        self.Fs = Fs

    def proc(self,q):
        plt.ion()
        a = q.get()
       # %f, pxx = sig.welch(a, self.Fs,nperseg = 512)##
        fig2 = plt.figure()
        plt2 = plt.plot(a)
        while True:
            a = q.get()
            #%pxx, f = sig.welch(a, self.Fs)
            plt2[0].set_ydata(a)
            #plt2[0].set_xdata(f)
            fig2.canvas.draw()
            fig2.canvas.flush_events()