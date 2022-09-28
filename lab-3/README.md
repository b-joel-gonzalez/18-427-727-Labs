Lab 3 code

## How to run
1. Connect the LibreVNA to your computer
2. Start the LibreVNA-GUI and make sure that the SCPI server is enabled (Window->Preferences->General). The examples use the default port (19542).
3. Use python3 to run radiation_pattern.py

libreVNA.py has all the functions that interact with the VNA device

retrieve_trace_data.py is a simple example to test reading S11 data

radiation_pattern.py reads the S21 data to measure and plot the antenna pattern

See lab manual for further detail on what packages to install!
