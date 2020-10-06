
import dds_gen from dds_gen
import numpy as np
import scipy as sc
class channel


    def __init__ (self,Fs,Fc,N,ar,Fb,d1):
        #gets dds gen object initialized
        self.Fc = Fc
        self.Fs = Fs
        self.N = N
        self.ar = ar
        self.Fb = Fb
        self.d1 = d1
        
        self.Theta = 0
        self.d0 = 0 
        self.nd = 0 
        self.A0 = 1
        self.A1 = 1
        
        self.gen = dds_gen(N,Fs,self.ar)
        self.wavelen = sc.c/Fc       
        self.t = np.arange(0,self.N-1)/self.Fs 
        self.theta1 = np.remainder(-4*np.pi*self.d1/self.wavelen,2*np.pi)
        

    def evaluate(x)
        b=self.gen2(self.N)
        phase = np.remainder(-4*np.pi*self.d0/self.wavelen - self.Theta,2*np.pi)
        phase += -4*np.pi*b/self.wavelen
        n = self.nd*(np.transpose(np.random.randn(1,self.N)) +np.transpose(1*j*np.random.randn(1,self.N)))
        y = x*(self.A0*np.exp(1*j*phi) + self.A1*exp(1*j*self.theta1))+n