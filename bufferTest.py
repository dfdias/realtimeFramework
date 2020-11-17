import time
import numpy as np
from circbuffer import circbuffer

F= 4;
N = 10;
buff = circbuffer(N,F,'floating')
x= np.arange(1, 100)
n = np.arange(0, 40, 10)

for i in n:
    b =x[i:i+10]
    print(b)
    buff.put(b)
    a = buff.get()
    print(a)
    time.sleep(1)



