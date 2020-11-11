#!/usr/bin/env python3

import numpy as np
import json
import socket
import time
##made only for mathematical MODEL
HOST, PORT = "localhost", 9999 # sets host address and port
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# Connect to server and send data
sock.connect((HOST, PORT))
Fs = 100
N = 1000
t = np.arange(1,1000)/Fs
while(1):
    f0 = 0.3*np.random.ranf(1)-0.1
    dic = {
    "signal" : str(np.sin(2*np.pi*f0*t)),
    "t"      : str(t),   
    "br"     : str(np.abs(f0))
    }
    payload = json.dumps(dic)
    # Create a socket (SOCK_STREAM means a TCP socket)

    sock.sendall(bytes(payload, encoding="utf-8"))
    data = sock.recv(1024)
    print("Received: {}".format(data))
    print(payload)
    time.sleep(1)
