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

fig = plt.figure(figsize=(2.0, 3.0))
ax = plt.axes()
ax.set_axis_off()

steps = []
arrows = []

def hw_step(x, y, w, h):
    return patches.Rectangle((x, y), w, h,
                             linewidth=1, edgecolor='r', facecolor='none')

steps.append(hw_step(0.05, 0.7, 0.86, 0.2))
ax.text(0.07, 0.72, "Microphone:\nSound wave converted to\nanalogue electrical signal")

arrows.append(patches.Arrow(0.5, 0.68, 0, -0.15, width=0.1))

steps.append(hw_step(0.05, 0.37, 0.85, 0.14))
ax.text(0.07, 0.39, "Passive filter:\n$f_\mathrm{{cut-off}}$ = 480 Hz")

arrows.append(patches.Arrow(0.5, 0.35, 0, -0.15, width=0.1))

steps.append(hw_step(0.05, 0.11, 0.85, 0.08))
ax.text(0.07, 0.13, "Connection to A0 pin")

steps_patch = [ax.add_patch(s) for s in steps]
arrows_patch = [ax.add_patch(a) for a in arrows]
fig.tight_layout()

fig.savefig("hw_diagram.eps")