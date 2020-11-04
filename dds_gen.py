import numpy as np
from matplotlib import pyplot as plt

class dds_gen:
    
    def __init__(self, n, fa, ar, f0, cplx):
        self.N = n
        self.ar = ar
        self.fs = fa
        self.f0 = f0
        self.cplx = cplx    #sets complex output
        self.IniPhase = 0
        self.pastT = 0
        self.sintable = self.wavetable()
        if n < fa/f0 :
            print("insuficient resolution, using alternate method") 
            self.low_freq = True
        else :
            self.low_freq = False

    def setIniPhase(self,phi):
        self.IniPhase = phi
        
    def getIniPhase(self):
        return self.IniPhase
    
    def wavetable(self):
        a = np.arange(0,self.N)
        if self.cplx is True:
            return np.exp(2*1j*np.pi*a/self.N,dtype=np.cdouble)
        else:
            return np.sin(2*np.pi*a/self.N)


    def gen(self,f0,NumSamp):
     
        N = self.N
    
        #asserts that the ratio is a rational number
        if self.cplx is True:
            x = np.zeros(NumSamp,dtype=np.cdouble)
        else:
            x = np.zeros(NumSamp)
        sintable = self.sintable
        IncPhase = (f0/self.fs)*N 
        n = 0
        phi = self.IniPhase
        for n in range(NumSamp) :
            x[n] = sintable[int(np.round(phi))]
            phi += IncPhase
            if phi > N-1:
                phi = phi - N
        self.IniPhase = phi
        #x = x*self.ar
        return x
    
    
    def gen2(self):
        
        if self.low_freq is False :
            N = self.N
            #asserts that the ratio is a rational number
            if self.cplx is True:
                x = np.zeros(N, dtype=np.cdouble)
            else:
                x = np.zeros(N)
            sintable = self.sintable
            IncPhase = (self.f0/self.fs)*N 
            n = 0
            phi = self.IniPhase
            for n in range(N) :
                x[n] = sintable[int(np.round(phi))]
                phi += IncPhase
                if phi > N-1:
                    phi = phi - N
            self.IniPhase = phi
        else:
            t = np.arange(self.pastT,self.pastT+self.N)/self.fs
            x = self.ar*np.cos(2+np.pi*t*self.f0+self.IniPhase)
            self.IniPhase = np.fmod(2*np.pi*self.f0*(self.pastT/self.fs)+self.IniPhase,2*np.pi)
            self.pastT = t[-1]

        return x
    
    def gen_threaded(self, f0, NumSamp,q):
        while(1):
            if q.empty() is True :
                #print('here')
                a = self.gen(f0,NumSamp)
                q.put(a)

        
    
    def dumb_gen(self,f0,NumSamp,IniPhase):
        N = self.N
        #asserts that the ratio is a rational number
        x = np.zeros(NumSamp)
        sintable = self.sintable
        IncPhase = (f0/self.fs)*N 
        n = 0;
        phi = IniPhase
        for n in range(NumSamp-1) :
            x[n] = self.sintable[int(np.round(phi))]
            phi += IncPhase
            if phi > N-1:
                phi = phi - N
        return x,phi    