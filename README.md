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
![Fig.1.1 The process to obtain the correlation peak of received signal and PRN code](https://github.com/Togure/GNSS-SDR/blob/main/figues/1.1.jpg)

***Step 1: Synchronous Demodulation Intermediate Frequency (IF) Signal to Obtain Received Signal:*** 

First, the received GNSS signal undergoes down-conversion to shift it from the radio frequency (RF) to the intermediate frequency (IF). This is achieved by mixing the received signal with a carrier signal generated by a local oscillator to remove the carrier frequency, retaining the pseudo-random noise (PRN) code and navigation data (Nav data) modulated on the IF.
The demodulated IF signal contains the modulated information of the PRN code and navigation data, which can be represented in both the time and frequency domains. 

***Step 2: Obtaining the Frequency Domain Representation of the PRN Code and Navigation Data:*** 
Using the Fast Fourier Transform (FFT), the IF signal in the time domain is converted to the frequency domain, yielding its frequency domain representation. This step helps analyze the frequency components of the signal and provides a foundation for subsequent correlation calculations. Fig.1.1.(d) is the time domain plot of received IF signal, let the remove carrier range as IF±j*500Hz(j = 1,2,…14), Fig.1.(e) shows the frequency domain plot of the received signal post carrier remove (take j equals 1 as an example).

***Step 3: Calculating the Frequency Domain Representation of Each PRN Code:*** 
For each possible satellite PRN code, it is similarly transformed from the time domain to the frequency domain using FFT, resulting in its frequency domain representation (denoted as b). The frequency domain representation of the PRN code reflects its frequency characteristics. Fig.1.1.(a) is the i-th PRN code (1023 chips, 58000 sampling per code). The sampling per chip
equals 56.7 (58000/1023), which can be verified in the zoom in figure in Fig.1.1.(b).

***Step 4: Computing the Product of a and b in the Frequency Domain::*** 


In the frequency domain, the frequency domain representation of the IF signal Fig.1.1.(e) is multiplied point-by-point with the frequency domain representation of the PRN code Fig.1.1.(c). This operation corresponds to the convolution of the signals in the time domain, which characterizes the correlation between the original IF signal and the specific PRN code. 

By applying the Inverse Fast Fourier Transform (IFFT) to the frequency domain product, the result is converted back to the time domain, yielding the correlation function. The peak position of the correlation function indicates the optimal alignment time between the signal and the PRN code, thereby determining the code phase. Fig.1.1.(f) is the correlation plot of 58000 samples and 28 search frequency bins for i-th PRN code. Fig.1.1.(g) records the peak value of the i-th PRN correlation plot.

Please note the following points in the program:
(1) To ensure the accuracy of the correlation peak and avoid errors introduced by noise, we selected two adjacent 1 ms segments (PRN code duration) from the received signal and performed the operation described in Figure 1(e) simultaneously. Then, each element in Figure 1(f) is assigned the maximum correlation coefficient from the two segments. 
(2) In addition to identifying the maximum correlation peak, we also searched for the second-largest correlation peak. If the ratio of the maximum correlation peak to the second-largest correlation peak satisfies Pmax_1/Pmax_2>1.5, and the two peaks are not too close to each other, the maximum correlation peak is considered meaningful, and the corresponding satellite is successfully acquired. Fig.1.2 shows the difference of the correlation peak of acquired and not acquired satellite.
![Fig.1.2 The difference of the correlation peak of acquired and not acquired satellite](https://github.com/Togure/GNSS-SDR/blob/main/figues/1.2.jpg)

***Step 5:Correlation Analysis:***
The maximum value of the correlation function reflects the degree of match between the original IF signal and the PRN code. By detecting the correlation peak, it is possible to determine whether the PRN code corresponds to the currently received satellite signal and to further estimate the Doppler shift and code phase of the signal.
This process is repeated until the PRN codes of all visible satellites are identified, and their Doppler shifts and code phases are initially estimated. 

**Results**:
Fig.1.3 is the result of acquisition results of urban dataset and opensky dataset.
![Fig.1.3 The result of acquisition results of urban and opensky dataset.](https://github.com/Togure/GNSS-SDR/blob/main/figues/1.3.jpg)

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
