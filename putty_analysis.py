# -*- coding: utf-8 -*-
"""
Created on Fri Mar 25 14:40:20 2022

@author: whatf0xx
"""

import numpy as np

n = np.arange(437, 448, 1)
data = np.zeros_like(n, dtype=np.float32)

for ei, i in enumerate(n):
    f = np.loadtxt(f"./Final_data/{i}_sine.txt", skiprows=1, dtype=str)
    d = np.zeros_like(f, dtype=np.uint8)
    for i,e in enumerate(f):
        d[i] = int(e, 16)
        
    #dist = np.bincount(d)
    data[ei] = np.mean(d)
    
import matplotlib.pyplot as plt

plt.plot(n, data, 'bo')