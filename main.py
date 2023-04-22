# Echo server program
# Use with Test02 and Test03 in processing4 sockets
import socket
import time
import math
from threading import Thread
from threading import Event
import numpy as np

event1 = Event()
event2 = Event()

HOST = ''                 # Symbolic name meaning all available interfaces
PORT = 50007              # Arbitrary non-privileged port
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind((HOST, PORT))
s.listen(1)
conn, addr = s.accept()
print('Connected by', addr)

class message():
    bufferSize = 10
    buffer = np.zeros((2, 10))

    def __init__(self, bufferSize = 10):
        self.bufferSize = bufferSize
        self.buffer = np.zeros((2, 10))

message_out = message(bufferSize = 10)

def tcpSendBuffer(string):
    #print(string)
    try:
        print("DEBUG: thread_send_buffer -> tcpSendBuffer(message_out) -> try conn.send(message)")
        conn.send(string.encode())
    except Exception:
        print("DEBUG: thread_send_buffer -> tcpSendBuffer(message_out) -> exception, conn.close()")
        conn.close()
        print("Disconnected...")
        # When it is disconnected it returns 1 so in call you can break and finish the program or continue
        return(1)    
    
    print("DEBUG: thread_send_buffer -> tcpSendBuffer(message_out) -> Sent. Waiting for response ... ")
    # Wait for response
    timeout = 300
    while True:
        try:
            data = conn.recv(1024)
        except Exception:
            print("DEBUG: thread_send_buffer -> tcpSendBuffer(message_out) -> exception, conn.close()")
            conn.close()
            print("Disconnected...")
            # When it is disconnected it returns 1 so in call you can break and finish the program or continue
            return(1) 

        if(data):
            print("DEBUG: thread_send_buffer -> tcpSendBuffer(message_out) -> Response recieved, event1.set() ")
            event1.set()
            break
        if(timeout <= 0):
            print("DEBUG: thread_send_buffer -> tcpSendBuffer(message_out) -> timeout, conn.close()")
            conn.close()
            print("Disconnected...")
            # When it is disconnected it returns 1 so in call you can break and finish the program or continue
            return(1)    

    # If everything is ok, return 0
    return(0)

class signal():
    x = 0
    y = 0
    a = 0
    f = 0.0
    b = 0

    def __init__(self, a, f, b):
        self.a = a
        self.f = f
        self.b = b

signal_1 = signal(a=200,f=1.5,b=300)


def thread_send_buffer():
    print("DEBUG: thread_send_buffer -> start")
    while True:
        print("DEBUG: thread_send_buffer -> buffer to string")
        string = ""
        # Buffer to String
        i = 0
        while (i < message_out.bufferSize - 1):
            string = string + str(int(message_out.buffer[0][i])) + "," + str(int(message_out.buffer[1][i])) + ","
            i += 1
        
        string = string + str(int(message_out.buffer[0][i])) + "," + str(int(message_out.buffer[1][i])) + "\n"
        print("DEBUG: thread_send_buffer -> string = " + string)

        # Wait for buffer to be ready
        print("DEBUG: thread_send_buffer -> Wait for buffer to be ready")
        while True:
            if(event2.is_set()):
                print("DEBUG: thread_send_buffer -> event2.is_set()")
                event2.clear()
                break
        
        print("DEBUG: thread_send_buffer -> tcpSendBuffer(message_out)")
        if(tcpSendBuffer(string)):
            break



def thread_calculate_buffer():
    print("DEBUG: thread_calculate_buffer -> start")
    cont = 0
    while True:
        print("DEBUG: thread_calculate_buffer -> event2.set()")
        # Tell thread_send_buffer that the buffer is ready
        event2.set()
        
            # Calculating buffer
        i = 0
        while (i < message_out.bufferSize):
            print("DEBUG: thread_calculate_buffer -> calculating ", i)

            # XY Coordinates
            message_out.buffer[0][i], message_out.buffer[1][i] = calculateXY(cont)
            
            # Increments
            i += 1
            cont+=0.1
        
        print("DEBUG: thread_calculate_buffer -> buffer calculated", message_out.buffer)
        # Wait for notification from client to recalculate buffer
        while True:
            if(event1.is_set()):
                event1.clear()
                break


def calculateXY(cont):
    
    X = int(signal_1.a*math.sin(signal_1.f*cont))  + signal_1.b
    Y = int(signal_1.a*math.cos(signal_1.f*cont)*math.sin(signal_1.f*cont)) + signal_1.b

    return X, Y
     


def main():
    t1 = Thread(target=thread_calculate_buffer)
    t2 = Thread(target=thread_send_buffer)
    event1.set()
    event2.clear()
    t1.start()
    t2.start()

    t1.join()
    t2.join()


if __name__ == "__main__":
    main()