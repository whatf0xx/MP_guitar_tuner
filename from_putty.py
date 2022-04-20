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

import matplotlib

matplotlib.rcParams['mathtext.fontset'] = 'stix'
matplotlib.rcParams['font.family'] = 'STIXGeneral'
matplotlib.rcParams['font.size'] = 10

import matplotlib.pyplot as plt

fig = plt.figure(figsize=(3.5, 2.1))
ax = plt.axes()

ax.bar(np.arange(len(dist)), dist/np.sum(dist))

def Gaussian(x, mu, sigma):
    return 1/(np.sqrt(2*np.pi) * sigma) * np.exp(- (x-mu)**2 / (2*sigma**2))

ax.set_xlim(50, 80)

xpts = np.linspace(50, 80, 200)
ax.plot(xpts, Gaussian(xpts, np.argmax(dist), 0.6), color="#dd3333",
         linestyle="dashed")

ax.set_xlabel("Points within wave period $n$")
ax.set_ylabel("Normalised frequency")

fig.tight_layout(rect=(0, 0, 0.98, 0.98), pad=0.1)
fig.savefig("440_histogram.eps")

#%%

a4 = np.loadtxt("./Final_data/Violin_Gaussian.txt", skiprows=1, dtype=str)
data = np.zeros_like(a4, dtype=np.uint8)
for i,e in enumerate(a4):
    data[i] = int(e, 16)
    
dist = np.bincount(data)

import matplotlib

matplotlib.rcParams['mathtext.fontset'] = 'stix'
matplotlib.rcParams['font.family'] = 'STIXGeneral'
matplotlib.rcParams['font.size'] = 10

import matplotlib.pyplot as plt

fig = plt.figure(figsize=(3.5, 2.1))
ax = plt.axes()

ax.bar(np.arange(len(dist)), dist/np.sum(dist))

def Gaussian(x, mu, sigma):
    return 1/(np.sqrt(2*np.pi) * sigma) * np.exp(- (x-mu)**2 / (2*sigma**2))

ax.set_xlim(50, 80)

xpts = np.linspace(50, 80, 200)
ax.plot(xpts, Gaussian(xpts, np.argmax(dist), 1.5), color="#dd3333",
         linestyle="dashed")

ax.set_xlabel("Points within wave period $n$")
ax.set_ylabel("Normalised frequency")

fig.tight_layout(rect=(0, 0, 0.98, 0.98), pad=0.1)
fig.savefig("violin_hist.eps")