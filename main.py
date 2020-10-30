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
while(1):
    dic = {
    "signali" : str(np.random.ranf(1000)),
    "signalq" : str(np.random.ranf(1000)),
    "br" : str(0.3*np.random.ranf(1)-0.1)
    }
    payload = json.dumps(dic)
    # Create a socket (SOCK_STREAM means a TCP socket)

    sock.sendall(bytes(payload, encoding="utf-8"))
    data = sock.recv(1024)
    print("Received: {}".format(data))
    print(payload)
    time.sleep(1)
