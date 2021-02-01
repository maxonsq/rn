#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Jan 22 17:06:47 2021

@author: k
"""
import numpy as np
from plotly.offline import plot
import plotly.graph_objs as go

import pandas as pd

import sys
from tkinter import *
from tkinter.filedialog import askopenfilename   


#import data from file with GUI
fname = "unassigned"
def openFile():
    global fname
    fname = askopenfilename()
    root.destroy()
if __name__ == '__main__':
    root = Tk()
    Button(root, text='=┏( ^o^)┛->File Open', command = openFile).pack(fill=X)
    mainloop()
    print (fname)

#give the data frame
data03 = pd.read_csv(fname, sep=" ", header=None)
data03.columns = ['lon','lat','gh_fa','fa','ba2000','ba2300','ba2670','gh_su_track']
# data03 = pd.read_csv(fname, sep=" ", header=None)
# data03.columns = ['lon','lat']

# df[::10] #downsampling


#Apply RDP method
import rdp

def angle(dir):
    """
    Returns the angles between vectors.

    Parameters:
    dir is a 2D-array of shape (N,M) representing N vectors in M-dimensional space.

    The return value is a 1D-array of values of shape (N-1,), with each value
    between 0 and pi.

    0 implies the vectors point in the same direction
    pi/2 implies the vectors are orthogonal
    pi implies the vectors point in opposite directions
    """
    dir2 = dir[1:]
    dir1 = dir[:-1]
    return np.arccos((dir1*dir2).sum(axis=1)/(
        np.sqrt((dir1**2).sum(axis=1)*(dir2**2).sum(axis=1))))

tolerance = 0.005 #0.01
min_angle = np.pi*0.1 #0.22

# points=np.array([data03.lon[0:2000], data03.lat[0:2000]]).T
points=np.array([data03.lon, data03.lat]).T

x=points[:,0]
y=points[:,1]

# Use the Ramer-Douglas-Peucker algorithm to simplify the path
# http://en.wikipedia.org/wiki/Ramer-Douglas-Peucker_algorithm
# Python implementation: https://github.com/sebleier/RDP/

simplified = np.array(rdp.rdp(points.tolist(), tolerance))

sx = simplified[:,0]
sy = simplified[:,1]

# compute the direction vectors on the simplified curve
directions = np.diff(simplified, axis=0)
theta = angle(directions)
# Select the index of the points with the greatest theta
# Large theta is associated with greatest change in direction.
idx = np.where(theta>min_angle)[0]+1


# Create Figure
fig = go.Figure()
fig.add_trace(go.Scatter(
                    x=data03.lon,
                    y=data03.lat,
                    mode='lines',
                    name='all_track'))
fig.add_trace(go.Scatter(
                    x=x,
                    y=y,
                    mode='lines',
                    name='part'))
fig.add_trace(go.Scatter(
                    x=sx,
                    y=sy,
                    mode='lines+markers',
                    name='simplized'))
fig.add_trace(go.Scatter(
                    x=sx[idx],
                    y=sy[idx],
                    mode='markers',
                    name='cut_points',
                    marker=dict(
                        color='Red',
                        size=12)
                    ))

cut_position=np.array([sx[idx],sy[idx]]).T
np.savetxt('position.txt',cut_position,fmt ='%.8f')

# Set title
fig.update_layout(
    title_text="Track [unit]")

#plot
plot(fig, auto_open=True)