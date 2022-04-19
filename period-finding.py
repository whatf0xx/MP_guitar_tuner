# -*- coding: utf-8 -*-
"""
Created on Tue Apr 19 15:43:09 2022

@author: whatf
"""

import numpy as np

raw_data = np.loadtxt("./Final_data/Unfiltered_sine.txt", dtype=str)
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

ax.set_xlim(5, 8.4)
ax.plot(t_estimate, combined_data, 'b.', markersize=2.6)
ax.hlines(1000, -0.1, 8.4, linestyle='dashed')
ax.vlines((t_estimate[176], t_estimate[247]), [600, 600], [1400, 1400],
          linestyle="dashed", color="#dd3333")

ax.text(7.78, 1045, "(A)")
ax.text(6.72, 885, "(B)")
ax.text(5.48, 1045, "(C)")
ax.set_xlabel("Time (ms)", labelpad=2)
ax.set_ylabel("Amplitude (a.u.)", labelpad=2)
fig.tight_layout(rect=(0, 0, 0.98, 0.98), pad=0.1)
fig.savefig("period-finding.eps")