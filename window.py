import numpy as np

class window:

    def __init__(self,framelen,windowlen,dir):
        self.framelen = framelen
        self.windowlen = windowlen
        self.window = np.zeros(windowlen)
        self.dir = dir 

    def put(self,frame):
        end = self.windowlen 
        framelen = self.framelen
        if self.dir == 'right':
            aux = self.window[0:end-framelen]
            self.window[0:framelen] = frame
            self.window[framelen:] = aux

    def get(self):
        return self.window        

