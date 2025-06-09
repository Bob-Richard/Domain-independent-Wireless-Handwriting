# Domain-independent-Wireless-Handwriting
Code and data for paper: Domain-independent Handwriting Trajectory Recovery Based on Multiple Wireless Links<br>
Link: https://ieeexplore.ieee.org/document/11024134


# 1. Prototype Experiment
## Dataset
Data for prototype experiments in Section V-A. <br>
6 positions (P1 ~ P6), each folder contains 1 preamble gesture and 50 tested gestures.<br>
The tested gesture patterns include 5 digits (G0 ~ G4) and 5 Greek letters (GA ~ GB), each gesture is performed 5 times.

For each position:
* ``Preamble.mat``
  * H: Frequency response of the preamble gesture (4Rx-2Tx).
* ``Gx.mat``
  * H_gestures: Frequency responses of 5 Gx gestures.
  * v_gestures: Ground truth of 3D velocities.

## Code
* ``Wireless_Handwriting.m``: Perform trajectory recovery.

# 2. Demonstration Video
* ``Demonstration_Video.mp4``: Real-time gesture trajectory recovery and recongnition in a disturbed scenario, see also Section V-B for more details.

# 3. Gesture Recognition
* ``Demonstration_Video.mp4``:

# 4. Citation
Our article has been published as Access area on IEEE Xplore.<br>

```text
@ARTICLE{11024134,
  author={Wang, Yuxin and Tian, Yafei and Peng, Rui},
  journal={IEEE Transactions on Wireless Communications}, 
  title={Domain-independent Handwriting Trajectory Recovery Based on Multiple Wireless Links}, 
  year={2025},
  doi={10.1109/TWC.2025.3574255}}

```




