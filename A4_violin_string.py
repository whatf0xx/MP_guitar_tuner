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

fig = plt.figure(figsize=(3.5, 2.1))
ax = plt.axes()

ax.plot(t_estimate, combined_data, 'b.', linestyle="dashed", markersize=3.0)
ax.hlines(1000, -0.1, 8.4, linestyle='dashed')
#ax.hlines(1000, 0, 5, linestyle='dashed')
ax.set_xlabel("Time (ms)")
ax.set_ylabel("Amplitude (a.u.)")

# from scipy.fftpack import fft, fftshift

# fig = plt.figure()
# ax = plt.axes()

# fft_data = fftshift(fft(combined_data))
# sampling_rate = 30303
# freq = 0.5 * sampling_rate * np.linspace(-1.0, 1.0, len(combined_data))

# ax.plot(freq, abs(fft_data))
# ax.set_xlim(-100, 5000)

fig.tight_layout(rect=(0, 0, 0.98, 0.98), pad=0.1)
fig.savefig("unfiltered-violin-form.eps")