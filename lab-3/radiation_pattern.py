#!/usr/bin/env python3

import time
import math
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from libreVNA import libreVNA

# connects to the VNA
def device_setup():
    # Create the control instance
    vna = libreVNA('localhost', 19542)

    # Quick connection check (should print "LibreVNA-GUI")
    print(vna.query("*IDN?"))

    # Make sure we are connecting to a device (just to be sure, with default settings the LibreVNA-GUI auto-connects)
    vna.cmd(":DEV:CONN")
    dev = vna.query(":DEV:CONN?")
    if dev == "Not connected":
        print("Not connected to any device, aborting")
        exit(-1)
    else:
        print("Connected to "+dev)
    return vna

# gets S21 data at a specified frequency
def get_S21_data(vna):
    # switch to VNA mode, setup the sweep parameters
    print("Setting up the sweep...")
    vna.cmd(":DEV:MODE VNA")
    vna.cmd(":VNA:SWEEP FREQUENCY")
    vna.cmd(":VNA:STIM:LVL -10")
    vna.cmd(":VNA:ACQ:IFBW 100")
    vna.cmd(":VNA:ACQ:AVG 5")
    vna.cmd(":VNA:ACQ:POINTS 251")
    vna.cmd(":VNA:FREQuency:START 2500000000") # CHANGE THIS FREQUENCY
    vna.cmd(":VNA:FREQuency:STOP 2500000000") # CHANGE THIS FREQUENCY

    # wait for the sweep to finish
    print("Waiting for the sweep to finish...")
    while vna.query(":VNA:ACQ:FIN?") == "FALSE":
        time.sleep(0.1)

    # grab the data of trace S21
    print("Reading trace data...")
    data = vna.query(":VNA:TRACE:DATA? S21")

    # Returned data is just a string containing all the measurement points.
    # Parsing the data returns a list containing frequency/complex tuples
    # Returns complex number
    S21 = vna.parse_trace_data(data)
    return S21[0][1]

# plots the radiation pattern, given the S21 measurements
def plot_pattern(data):
    # get S21 in dB, with interpolation to go from 24 -> 360 points
    magnitudes = [abs(val) for val in data]
    interpolated_mags = pd.Series([i if i else np.nan for i in magnitudes]).interpolate().tolist()
    gains = [20*math.log10(mag) for mag in interpolated_mags]
    
    print(gains)

    # plot polar pattern and normalized pattern
    fig = plt.figure(layout='constrained')
    ax = fig.add_subplot(1, 2, 1, projection='polar', theta_offset=np.pi/2)
    ax.plot(np.linspace(0, 2 * np.pi, 360), gains)
    plt.show()
    

def main():
    vna = device_setup()
    
    # take N measurements of S21, rotating antenna each iteration for 360 degree pattern
    data = [0] * 360
    N = 24
    angle = int(360 / N)
    
    for x in range(N):
        input("Press key when ready to take measurement...")
        S21 = get_S21_data(vna)
        data[x * angle] = S21
        print(S21)

    # plot the radiation pattern
    plot_pattern(data)
        
if __name__ == '__main__':
    main()
