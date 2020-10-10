
from dds_gen import dds_gen
import numpy as np
import scipy as sc
from scipy import constants as const

class Channel:

    def __init__ (self,fs,fc,N,ar,fb,d1):
        #gets dds gen object initialized
        self.fc = fc
        self.fs = fs
        self.N = N
        self.ar = ar
        self.fb = fb
        self.d1 = d1
        self.Theta = 0
        self.d0 = 0 
        self.nd = 0 
        self.A0 = 1
        self.A1 = 1
        
        self.gen = dds_gen(N,self.fs,self.ar,self.fb)
        self.wavelen = const.c/self.fc
        self.t = np.arange(0,self.N-1)/self.fs
        self.theta1 = np.remainder(-4*np.pi*self.d1/self.wavelen,2*np.pi)
        

    def evaluate(self,x):
        b=self.gen.gen2(self.N)
        phase = np.remainder(-4*np.pi*self.d0/self.wavelen - self.Theta,2*np.pi)
        phase += -4*np.pi*b/self.wavelen
        n = self.nd*(np.transpose(np.random.randn(1,self.N)) +np.transpose(1j*np.random.randn(1,self.N)))
        y = x*(self.A0*np.exp(1j*phase) + self.A1*np.exp(1j*self.theta1))+n
        return y