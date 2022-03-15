# -*- coding: utf-8 -*-

"""
Created on Mon May 20 12:00:18 2019
@author: whatf
"""

import numpy as np

raw_data = np.loadtxt("./output2.txt", dtype=str)
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
    
import matplotlib.pyplot as plt

plt.plot(combined_data)