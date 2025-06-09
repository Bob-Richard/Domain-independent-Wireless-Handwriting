# Domain-independent-Wireless-Handwriting
Domain-independent Handwriting Trajectory Recovery

Code and data for paper: Domain-independent Handwriting Trajectory Recovery Based on Multiple Wireless Links

Code for gesture recognition experiments in Section V-C, based on the open-source Widar3.0 CSI dataset.

1. Download CSI dataset from https://tns.thss.tsinghua.edu.cn/widar3.0/
2. Copy the CSI data named '20181112' to the current folder (0~9 handwritten digits #Here we have already copied several data for a simple test)
3. Run 'WirelessHandwriting_Htran.m' to perform transformation matrix estimation, trajectory recovery and gesture recognition
4. Run 'WirelessHandwriting_Recognition.m' to get the confusion matrix of the testing dataset
