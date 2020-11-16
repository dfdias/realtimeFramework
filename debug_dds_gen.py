from dds_gen import dds_gen
from matplotlib import pyplot as plt
import numpy as np

fs = 100
f0 = 1
ar = 1


gen = dds_gen(1000,fs,ar,f0,False)


s = gen.gen2()

plt.figure(1)
plt.plot(s,'.')
plt.show()