# -*- coding: utf-8 -*-
"""
Created on Thu Mar 24 17:25:38 2022

@author: whatf0xx
"""

import numpy as np

a4 = np.loadtxt("./Final_data/Violin_Gaussian.txt", skiprows=1, dtype=str)
data = np.zeros_like(a4, dtype=np.uint8)
for i,e in enumerate(a4):
    data[i] = int(e, 16)
    
dist = np.bincount(data)

import matplotlib.pyplot as plt

plt.plot(dist/np.sum(dist))