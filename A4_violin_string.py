# -*- coding: utf-8 -*-

"""
Created on Mon May 20 12:00:18 2019
@author: whatf
"""

import numpy as np

raw_data = np.loadtxt("./violin_A4(1).txt", dtype=str)
flattened_data = np.zeros(np.size(raw_data))

for i, d in enumerate(raw_data):
    for j, e in enumerate(d):
        if j % 2 == 0:
            flattened_data[j+i*16] = int(e, 16)
        else:
            flattened_data[j+i*16] = int(e, 16)*256
            
combined_data = np.zeros(256)

for i in range(256):
    combined_data[i] = flattened_data[2*i] + flattened_data[2*i + 1]
    
import matplotlib

matplotlib.rcParams['mathtext.fontset'] = 'stix'
matplotlib.rcParams['font.family'] = 'STIXGeneral'
matplotlib.rcParams['font.size'] = 12

t_estimate = 0.02 * np.arange(0, 256, 1) #time, us

import matplotlib.pyplot as plt

fig = plt.figure()
ax = plt.axes()

ax.plot(t_estimate, combined_data)
ax.set_xlabel("Time (ms)")
ax.set_ylabel("Amplitude (a.u.)")

from scipy.fftpack import fft, fftshift

fft_data = fftshift(fft(combined_data))
plt.figure()
plt.plot(abs(fft_data))