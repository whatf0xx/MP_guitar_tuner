# -*- coding: utf-8 -*-
"""
Created on Thu Mar 24 10:41:26 2022

@author: whatf0xx
"""

import serial

with serial.Serial() as ser:
    ser.baudrate = 9600
    ser.port = 'COM7'
    ser.timeout=10
    ser.open()
    
import numpy as np

length = 50
vals = np.zeros(length, dtype = np.uint8)

for i in range(length):
    with serial.Serial() as ser:
        ser.baudrate = 9600
        ser.port = 'COM7'
        ser.timeout=10
        ser.open()
        line = ser.read_until(b'\n\r')
        
    line = line.decode('ascii')
    print(line)
    try:
        line = int(line, 16)
        vals[i] = line
    except:
        i -= 1


#%%

dist = np.bincount(vals)

import matplotlib.pyplot as plt

plt.plot(dist)
#plt.plot(dist1)
plt.xlim(50, 72)