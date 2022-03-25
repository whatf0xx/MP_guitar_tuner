# -*- coding: utf-8 -*-
"""
Created on Thu Mar 24 17:25:38 2022

@author: whatf0xx
"""

import numpy as np

a4 = np.loadtxt("./Final_data/440_sine.txt", skiprows=1, dtype=str)
data = np.zeros_like(a4, dtype=np.uint8)
for i,e in enumerate(a4):
    data[i] = int(e, 16)
    
dist = np.bincount(data)

import matplotlib.pyplot as plt

plt.plot(dist/np.sum(dist))

sh = np.loadtxt("./Final_data/445_sine.txt", skiprows=1, dtype=str)
sh_data = np.zeros_like(sh, dtype=np.uint8)
for i,e in enumerate(sh):
    sh_data[i] = int(e, 16)
    
sh_dist = np.bincount(sh_data)

plt.plot(sh_dist/np.sum(sh_dist))

plt.xlim(50, 85)

fl = np.loadtxt("./Final_data/435_sine.txt", skiprows=1, dtype=str)
fl_data = np.zeros_like(fl, dtype=np.uint8)
for i,e in enumerate(fl):
    fl_data[i] = int(e, 16)
    
fl_dist = np.bincount(fl_data)

plt.plot(fl_dist/np.sum(fl_dist))