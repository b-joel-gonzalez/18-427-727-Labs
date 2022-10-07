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

"""
# probes S11 to find the center frequency of the antenna (across 2-3GHz)
def get_center_frequency(vna):
    # switch to VNA mode, setup the sweep parameters
    print("Setting up the sweep...")
    vna.cmd(":DEV:MODE VNA")
    vna.cmd(":VNA:SWEEP FREQUENCY")
    vna.cmd(":VNA:STIM:LVL -10")
    vna.cmd(":VNA:ACQ:IFBW 100")
    vna.cmd(":VNA:ACQ:AVG 1")
    vna.cmd(":VNA:ACQ:POINTS 501")
    vna.cmd(":VNA:FREQuency:START 2000000000")
    vna.cmd(":VNA:FREQuency:STOP 3000000000")
    
    # wait for the sweep to finish
    print("Waiting for the sweep to finish...")
    while vna.query(":VNA:ACQ:FIN?") == "FALSE":
        time.sleep(0.1)

    # return the frequency at which S11 is lowest (i.e. center frequency of antenna)
    print("Reading trace data...")
    freq = vna.query(":VNA:TRACE:MINAmplitude? S11")

    return freq[0]
"""

# gets S21 (radiation) data at a specified frequency
def get_radiation_data(vna, freq):
    # switch to VNA mode, setup the sweep parameters
    print("Setting up the sweep...")
    vna.cmd(":DEV:MODE VNA")
    vna.cmd(":VNA:SWEEP FREQUENCY")
    vna.cmd(":VNA:STIM:LVL 10")
    vna.cmd(":VNA:ACQ:IFBW 100")
    vna.cmd(":VNA:ACQ:AVG 5")
    vna.cmd(":VNA:ACQ:POINTS 251")
    vna.cmd(":VNA:FREQuency:START " + freq)
    vna.cmd(":VNA:FREQuency:STOP " + freq)

    # wait for the sweep to finish
    print("Waiting for the sweep to finish...")
    while vna.query(":VNA:ACQ:FIN?") == "FALSE":
        time.sleep(0.1)

    # grab the data of trace S21
    print("Reading trace data...")
    data = vna.query(":VNA:TRACE:DATA? S21")

    # Returned data is just a string containing all the measurement points.
    # Parsing the data returns a list containing frequency/complex tuples
    # Returns a complex number at the center frequency
    S21 = vna.parse_trace_data(data)
    return S21[0][1]

# plots the radiation pattern, given the S21 measurements
def plot_pattern(data, N):
    # get S21 in dB, normalizing the data to 0 dB
    magnitudes = [abs(val) for val in data]
    gains = [20*math.log10(mag) for mag in magnitudes]
    max_gain = max(gains)
    normalized_gains = [(gain - max_gain) for gain in gains]
    
    print(normalized_gains) # prints all data points

    # plot polar radiation pattern
    fig = plt.figure(layout='constrained')
    ax = fig.add_subplot(1, 2, 1, projection='polar', theta_offset=np.pi/2)
    ax.plot(np.linspace(0, 2 * np.pi, N), normalized_gains)
    ax.set_rlabel_position(0)
    ax.text(0.5, 0.5, "dB", transform=ax.transAxes) 
    plt.show() # be sure to save your plot using the GUI!

def main():
    vna = device_setup() # set up the vna device connection
    
    # look at the S11 plot in the GUI, then enter the center frequency
    freq = input("What is the measured center frequency of your patch antenna? Enter 2GHz as 2000000000, for example:\n")
    print("The center frequency is: " + freq)
    
    # take N measurements of S21, rotating antenna each iteration for 360 degree pattern
    N = 36 #  36 for 10 degrees
    data = [0] * N 
    angle = int(360 / N)
    
    print("Taking " + str(N) + " measurements, once every " + str(angle) + " degrees...")
    
    for x in range(N):
        input("Press key when ready to take measurement at " + str(x * angle) + " degrees...") # give time to adjust antenna angle
        S21 = get_radiation_data(vna, freq)
        data[x] = S21
        print(S21)

    # plot the radiation pattern from S21 data
    plot_pattern(data, N)
        
if __name__ == '__main__':
    main()
