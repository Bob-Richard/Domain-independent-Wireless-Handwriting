# Domain-independent-Wireless-Handwriting
Domain-independent Handwriting Trajectory Recovery
Code and data for paper: Domain-independent Handwriting Trajectory Recovery Based on Multiple Wireless Links

# Dataset
Data for prototype experiments in Section V-A.

6 positions (P1 ~ P6), each folder contains 1 preamble gesture and 50 tested gestures.

The tested gesture patterns include 5 digits (G0 ~ G4) and 5 Greek letters (GA ~ GB), each gesture is performed 5 times.

For each position:
* ``Preamble.mat``
  * H: Frequency response of the preamble gesture (4Rx-2Tx).
* ``Gx.mat``
  * H_gestures: Frequency responses of 5 Gx gestures.
  * v_gestures: Ground truth of 3D velocities.

# Code

Script:
* ``Wireless_Handwriting.m``: Extract dynamic path of each wireless link.

Full code will be updated soon...

# Demonstration Video

* ``Demonstration_Video.mp4``: Real-time gesture trajectory recovery and recongnition in a disturbed scenario, see also Section V-B for more details.




