import numpy as np


class circbuffer:

    def __init__(self,framelen,nframes,type):
        if type == 'floating' :
            dtype = np.double
        else:
            dtype = np.cdouble
        self.p1 = 0
        self.nframes = nframes
        self.framelen = framelen
        self.buffer = np.zeros((self.framelen,self.nframes),dtype=dtype)

    def put(self,frame):
        self.buffer[:,self.p1] = frame
        self.p1 = np.mod(self.p1+1, self.nframes)

    def get(self):

        idx = np.arange(self.p1, self.p1+self.nframes)
        idx = np.mod(idx, self.nframes)
        a = self.buffer[:, idx]
        return a.flatten('F')