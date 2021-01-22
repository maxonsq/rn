#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Jan 22 17:06:47 2021

@author: k
"""
import numpy as np
from plotly.offline import plot
import plotly.graph_objs as go

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
    Button(root, text='File Open', command = openFile).pack(fill=X)
    mainloop()
    print (fname)

data01 = np.loadtxt(fname,delimiter='\t',unpack=True)


# Create Figure
fig = go.Figure()
fig.add_trace(go.Scatter(
                    y=data01[1,:],
                    mode='lines',
                    name='araara'))
fig.add_trace(go.Scatter(
                    y=data01[2,:],
                    mode='lines',
                    name='oyaoya'))

# Set title
fig.update_layout(
    title_text="koreha sample [unit]")

#plot
plot(fig, auto_open=True)