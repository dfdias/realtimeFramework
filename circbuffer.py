import numpy as np


class circbuffer:

    def __init__(self,len,N):
        self.p1 = 0
        self.len = len
        self.N = N
        self.buffer = np.zeros(self.N,self.len)

    def put(self,frame):
        self.buffer[:,self.p1] = frame
        self.p1 = np.mod(self.p1+1, self.len)

    def get(self):

        idx = self.p1:1:self.p1+self.len
        idx = np.mod(idx,self.len)
        a = self.buffer[:,idx]
        return a[:]