# GNSS-SDR
assignment for AAE6102

# AAE6102 Assignment 1

## Satellite Communication and Navigation (2024/25 Semester 2)

### The Hong Kong Polytechnic University  
**Department of Aeronautical and Aviation Engineering**  

**Due Date:** 13 March 2025  

## Overview  
This assignment focuses on processing **GNSS Software-Defined Receiver (SDR) signals** to develop a deeper understanding of **GNSS signal processing**. Students will analyze **two real Intermediate Frequency (IF) datasets** collected in different environments: **open-sky** and **urban**. The urban dataset contains **multipath and non-line-of-sight (NLOS) effects**, which can degrade positioning accuracy.

### Dataset Information  

| Environment | Carrier Frequency | IF Frequency | Sampling Frequency | Data Format | Ground Truth Coordinates | Data Length | Collection Date (UTC) |
|------------|------------------|--------------|-------------------|------------|-----------------------|------------|-----------------|
| Open-Sky  | 1575.42 MHz | 4.58 MHz | 58 MHz | 8-bit I/Q samples | (22.328444770087565, 114.1713630049711) | 90 seconds | 14/10/2021 12.21pm|
| Urban     | 1575.42 MHz | 0 MHz | 26 MHz | 8-bit I/Q samples | (22.3198722, 114.209101777778) | 90 seconds | 07/06/2019 04.49am |

![image](https://github.com/IPNL-POLYU/AAE6102-assignments/blob/main/Picture1.png)

## Assignment Tasks  

### **Task 1 – Acquisition**  
Process the **IF data** using a **GNSS SDR** and generate the initial acquisition results.

### **Task 2 – Tracking**  
Adapt the **tracking loop (DLL)** to generate **correlation plots** and analyze the tracking performance. Discuss the impact of urban interference on the correlation peaks. *(Multiple correlators must be implemented for plotting the correlation function.)*

### **Task 3 – Navigation Data Decoding**  
Decode the **navigation message** and extract key parameters, such as **ephemeris data**, for at least one satellite.

### **Task 4 – Position and Velocity Estimation**  
Using **pseudorange measurements** from tracking, implement the **Weighted Least Squares (WLS)** algorithm to compute the **user's position and velocity**.  
- Plot the user **position** and **velocity**.  
- Compare the results with the **ground truth**.  
- Discuss the impact of **multipath effects** on the WLS solution.

### **Task 5 – Kalman Filter-Based Positioning**  
Develop an **Extended Kalman Filter (EKF)** using **pseudorange and Doppler measurements** to estimate **user position and velocity**.


# Solution

## Task 1 – Signal Acquisition
**Objective**: Process the IF data using a GNSS SDR and generate the initial acquisition results.

**Steps**:
1. Read IF data from open-sky and urban dataset.
2. Display the details of the original data of different databases from time domain, frequency domain and histogram.
3. Display the correlation peak of acquisition.
4. Display the acquisition result of different satellite.
**Results**:
- Acquisition results plot (insert image here).

---

## Task 2 – Signal Tracking
**Objective**: Adapt the tracking loop (DLL) to generate correlation plots and analyze tracking performance. Discuss the impact of urban interference on correlation peaks.

**Steps**:
1. Implement multiple correlators to plot the correlation function.
2. Generate correlation plots and analyze the impact of multipath effects on correlation peaks.

**Results**:
- Correlation plots (insert image here).
- Discussion on the impact of urban interference on correlation peaks.

---

## Task 3 – Navigation Data Decoding
**Objective**: Decode the navigation message and extract key parameters, such as ephemeris data, for at least one satellite.

**Steps**:
1. Decode the navigation message.
2. Extract ephemeris data.

**Results**:
- Decoded navigation message (insert image here).
- Extracted ephemeris data (insert image here).

---

## Task 4 – Position and Velocity Estimation
**Objective**: Use pseudorange measurements from tracking to implement the Weighted Least Squares (WLS) algorithm and compute the user's position and velocity.

**Steps**:
1. Implement the WLS algorithm.
2. Plot the user's position and velocity.
3. Compare the results with the ground truth.
4. Discuss the impact of multipath effects on the WLS solution.

**Results**:
- User position and velocity plots (insert image here).
- Comparison of WLS results with ground truth (insert image here).
- Discussion on the impact of multipath effects on the WLS solution.

---

## Task 5 – Kalman Filter-Based Positioning
**Objective**: Develop an Extended Kalman Filter (EKF) using pseudorange and Doppler measurements to estimate the user's position and velocity.

**Steps**:
1. Implement the EKF algorithm.
2. Estimate the user's position and velocity.

**Results**:
- EKF-based position and velocity plots (insert image here).

---

## Conclusion
Summarize the key findings and results of the assignment. Discuss the impact of different environments (open-sky vs. urban) on GNSS signal processing, particularly the effects of multipath and NLOS on positioning accuracy.
