#!/usr/bin/env python3

import socket
import time
import queue
import threading
import subprocess, signal
import os
def RX(queue,s):
    HOST = 'localhost'  # Standard loopback interface address (localhost)
    PORT = 3030        # Port to listen on (non-privileged ports are > 1023)
    JSPORT = 3031
    s.bind((HOST, PORT))
    s.listen()
    conn, addr = s.accept()
    with conn:
        print('Connected by', addr)
        while True:
            data = conn.recv(1024) 
            #print(data)  
            queue.put(data)

def TX(queue,sock):
    while True:
        while True:
            try :
                if queue.empty() is False:
                    data = queue.get()
                    sock.sendall(data)
                break
            except:
                sock = connect(sock)

def connect(sock):
    HOST = 'localhost'  # Standard loopback interface address (localhost)
    PORT = 3030        # Port to listen on (non-privileged ports are > 1023)
    JSPORT = 3031
    sock.close() 
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    while True:
        try :
            sock.connect((HOST,JSPORT))
            print("reconnected")
            break
        except OSError:
            print("reconnecting")
    return sock

procname = "MATLAB"
print("finding existing matlab processes")
p = subprocess.Popen(['ps', '-A'], stdout=subprocess.PIPE)
out, err = p.communicate()
for line in out.splitlines():
    if procname.encode('utf-8')  in line:
        pid = int(line.split(None, 1)[0])
        os.kill(pid, signal.SIGKILL)
        print("Matlab process Killed")
    if "matlab".encode('utf-8')  in line:
        pid = int(line.split(None, 1)[0])
        os.kill(pid, signal.SIGKILL)
        print("Matlab process Killed")
time.sleep(30)
print("setting up threads and sockets")

HOST = 'localhost'  # Standard loopback interface address (localhost)
PORT = 3030        # Port to listen on (non-privileged ports are > 1023)
JSPORT = 3031
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
while True :
    try :
        sock.connect((HOST,JSPORT))
        break
    except OSError :
        print("waiting for connection")
print("Connected")    
q  = queue.Queue()
t1 = threading.Thread(target=RX, args=(q,s))
t2 = threading.Thread(target=TX, args=(q,sock))
t1.start()
t2.start()
print("Threads started. Sockets up and Running")
print("Starting Matlab")
C = ['matlab','-nodesktop','-nosplash','-r',"cd '/home/duarte/centi/'; bioradarJNV",'&']
cmd = ""
for row in C:
    cmd +=row + " "
print(cmd)
subprocess.run(C) 
print("Launched Matlab")    


