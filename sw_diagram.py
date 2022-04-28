# -*- coding: utf-8 -*-
"""
Created on Thu Apr 28 15:46:12 2022

@author: hf4218
"""

import matplotlib

matplotlib.rcParams['mathtext.fontset'] = 'stix'
matplotlib.rcParams['font.family'] = 'STIXGeneral'
matplotlib.rcParams['font.size'] = 10

import matplotlib.pyplot as plt
import matplotlib.patches as patches

fig = plt.figure(figsize=(5.0, 3.0))
ax = plt.axes()
ax.set_axis_off()
ax.set_xlim(0, 1)
ax.set_ylim(0, 1)

steps = []
arrows = []

def sw_step(x, y, w, h):
    return patches.Rectangle((x, y), w, h,
                             linewidth=1, edgecolor='blue', facecolor='none')

steps.append(sw_step(0.02, 0.92, 0.19, 0.08))
ax.text(0.03, 0.94, "Perform ADC")

arrows.append(patches.Arrow(0.12, 0.9, 0, -0.07, width=0.03))

steps.append(sw_step(0, 0.74, 0.24, 0.08))
ax.text(0.01, 0.76, "Low byte to RAM")
steps.append(sw_step(0, 0.66, 0.24, 0.08))
ax.text(0.01, 0.68, "High nib. to RAM")

ax.plot([0.22, 0.26], [0.62, 0.62], 'black', linewidth=0.8)
ax.plot([0.26, 0.26], [1.0, 0.62], 'black', linewidth=0.8)
ax.plot([0.22, 0.26], [1, 1], 'black', linewidth=0.8)

ax.text(0.27, 0.76, "x256\nFSR0")

arrows.append(patches.Arrow(0.12, 0.64, 0, -0.07, width=0.03))

steps.append(sw_step(0.02, 0.44, 0.2, 0.12))
ax.text(0.03, 0.45, "Iterate through\nstored data")

arrows.append(patches.Arrow(0.12, 0.42, 0, -0.07, width=0.03))

steps.append(sw_step(0.01, 0.27, 0.22, 0.07))
ax.text(0.02, 0.28, "Below threshold?")

arrows.append(patches.Arrow(0.12, 0.25, 0, -0.07, width=0.03))

steps.append(sw_step(0.01, 0.1, 0.23, 0.07))
ax.text(0.02, 0.11, "Above threshold?")

ax.plot([0.22, 0.26], [0.05, 0.05], 'black', linewidth=0.8)
ax.plot([0.26, 0.26], [0.4, 0.05], 'black', linewidth=0.8)
ax.plot([0.22, 0.26], [0.4, 0.4], 'black', linewidth=0.8)

ax.text(0.27, 0.2, "Identifies\nrising edge")

ax.text(0.05, 0.02, "$\mathit{{Next \\ column}}$")

steps_patch = [ax.add_patch(s) for s in steps]
arrows_patch = [ax.add_patch(a) for a in arrows]
fig.tight_layout()

fig.savefig("sw_diagram.eps")