# -*- coding: utf-8 -*-

"""
Created on Mon May 20 12:00:18 2019
@author: whatf
"""

import numpy as np

raw_data = np.loadtxt("./Final_data/Unfiltered_violin.txt", dtype=str)
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
matplotlib.rcParams['font.size'] = 10

t_estimate = 0.0325 * np.arange(0, 256, 1) #time, ms

import matplotlib.pyplot as plt

fig, ax = plt.subplots(2, 1, figsize=(3.5, 4.8))

from scipy.fftpack import fft, fftshift

cheat_data = np.array(50 * list(combined_data[34:106]))
fft_data = fftshift(fft(cheat_data))
sampling_rate = 30800
freq = 0.5 * sampling_rate * np.linspace(-1.0, 1.0, 50*len(combined_data[34:106]))

ax[0].plot(freq, abs(fft_data), label="Unfiltered")
ax[0].set_xlim(000, 1500)
ax[0].set_ylim(0, 1e6)
ax[0].vlines(480, 0, 1e6, linestyle="dashed", color="#dd3333", label="Cut-off frequency")

ax[0].set_xlabel("Frequency (Hz)")
ax[0].set_ylabel("Fourier amplitude (a.u.)")



raw_data = np.loadtxt("./Final_data/Filtered_violin.txt", dtype=str)
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
    
ax[1].plot(t_estimate, combined_data, 'b.', linestyle="dashed", markersize=3.0)
ax[1].hlines(1000, -0.1, 8.4, linestyle='dashed')
#ax.hlines(1000, 0, 5, linestyle='dashed')
ax[1].set_xlabel("Time (ms)")
ax[1].set_ylabel("Amplitude (a.u.)")

cheat_data = np.array(50 * list(combined_data[33:106]))
fft_data = fftshift(fft(cheat_data))
sampling_rate = 30800
freq = 0.5 * sampling_rate * np.linspace(-1.0, 1.0, 50*len(combined_data[33:106]))

ax[0].plot(freq, abs(fft_data), label="Filtered")
ax[0].legend()
fig.tight_layout(rect=(0,0,0.98,0.98), pad=0.1)
fig.savefig("Filtering.eps")