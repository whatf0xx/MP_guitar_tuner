# -*- coding: utf-8 -*-
"""
Created on Thu Apr 28 15:46:12 2022

@author: hf4218
"""

import matplotlib

matplotlib.rcParams['mathtext.fontset'] = 'stix'
matplotlib.rcParams['font.family'] = 'STIXGeneral'
matplotlib.rcParams['font.size'] = 8

import matplotlib.pyplot as plt
import matplotlib.patches as patches

fig = plt.figure(figsize=(2.0, 3.0))
ax = plt.axes()
ax.set_axis_off()
ax.set_xlim(0, 1)
ax.set_ylim(0, 1)

circuit = []

def c_step(x, y, w, h):
    return patches.Rectangle((x, y), w, h,
                             linewidth=0.8, edgecolor='black',
                             facecolor='none')

ax.plot([0.9, 0.9], [0.98, 0.1], 'black', linewidth=0.8)
ax.text(0.85, 0.99, "Gnd.")

ax.plot([0.85, 0.95], [0.1, 0.1], 'black', linewidth=0.8)
ax.plot([0.87, 0.93], [0.08, 0.08], 'black', linewidth=0.8)
ax.plot([0.89, 0.91], [0.06, 0.06], 'black', linewidth=0.8)

circuit.append(c_step(0, 0.7, 0.25, 0.3))
ax.text(0.08, 0.95, "Mic.")

ax.plot([0.25, 0.3], [0.94, 0.94], 'black', linewidth=0.8)
ax.text(0.3, 0.93, "V$_\mathrm{{in}}$")

ax.plot([0.25, 0.9], [0.88, 0.88], 'black', linewidth=0.8)
ax.text(0.12, 0.87, "Gain")

ax.plot([0.25, 0.9], [0.82, 0.82], 'black', linewidth=0.8)
ax.text(0.13, 0.8, "A/R")

ax.plot([0.25, 0.3], [0.76, 0.76], 'black', linewidth=0.8)
ax.text(0.13, 0.74, "Out")

ax.plot([0.3, 0.3], [0.76, 0.56], 'black', linewidth=0.8)
circuit.append(c_step(0.28, 0.41, 0.04, 0.15))
ax.text(0.34, 0.47, "300 $\Omega$")

ax.plot([0.3, 0.3], [0.41, 0.2], 'black', linewidth=0.8)

ax.plot([0.3, 0.55], [0.3, 0.3], 'black', linewidth=0.8)
ax.plot([0.55, 0.55], [0.33, 0.27], 'black', linewidth=0.8)
ax.plot([0.58, 0.58], [0.33, 0.27], 'black', linewidth=0.8)
ax.plot([0.58, 0.9], [0.3, 0.3], 'black', linewidth=0.8)

ax.text(0.51, 0.35, "1 $\mu$F")

ax.plot([0.1, 0.3], [0.2, 0.2], 'black', linewidth=0.8)
circuit.append(patches.Circle([0.09, 0.2], 0.01,
                              linewidth=0.8, edgecolor='black',
                              facecolor='none'))

ax.text(0.02, 0.23, "A0 pin")

circuit_patch = [ax.add_patch(c) for c in circuit]
fig.tight_layout()

fig.savefig("circuit_diagram.eps")