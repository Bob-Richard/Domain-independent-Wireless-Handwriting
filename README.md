# Domain-independent-Wireless-Handwriting
Code and data for paper: Domain-independent Handwriting Trajectory Recovery Based on Multiple Wireless Links<br>

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
* ``Demonstration_Video.mp4``: Real-time gesture trajectory recovery and recongnition in a disturbed scenario with commercial 5G-NR signals, see also Section V-B for more details.

# 3. Gesture Recognition
Code for gesture recognition experiments in Section V-C.<br>
* ``WirelessHandwriting_Htran.m``: Perform transformation matrix estimation, trajectory recovery and gesture recognition.
* ``WirelessHandwriting_Recognition.m``: Get the confusion matrix of the testing dataset.

# 4. Citation
Our article has been published as Early Access on IEEE Xplore: https://ieeexplore.ieee.org/document/11024134<br>
If you find our work helpful for your research, we would really appreciate it if you could cite the following paper.
```text
@ARTICLE{twcwyx2025,
  author={Wang, Yuxin and Tian, Yafei and Peng, Rui},
  journal={IEEE Transactions on Wireless Communications}, 
  title={Domain-independent Handwriting Trajectory Recovery Based on Multiple Wireless Links}, 
  year={2025},
  doi={10.1109/TWC.2025.3574255}}
```

An earlier version of this paper was presented in part at the 16th International Conference on Wireless Communications and Signal Processing (WCSP2024), Hefei, China, in October 2024.<br>
In the conference paper, we validate the the proposed method with commercial LTE signals.
```text
@INPROCEEDINGS{wcspwyx2024,
  author={Wang, Yuxin and Peng, Rui and Tian, Yafei},
  booktitle={2024 16th International Conference on Wireless Communications and Signal Processing (WCSP)}, 
  title={3D Handwriting Trajectory Recovery by Wireless Sensing with Commercial LTE Signals}, 
  year={2024},
  pages={752-757},
  doi={10.1109/WCSP62071.2024.10827566}}
```






