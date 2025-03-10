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

### **Objective**: Process the IF data using a GNSS SDR and generate the initial acquisition results.

### **Steps**:

![Fig.1.1 The process to obtain the correlation peak of received signal and PRN code](https://github.com/Togure/GNSS-SDR/blob/main/figues/1.1.jpg)  
Fig.1.1 The process to obtain the correlation peak of received signal and PRN code


**Step 1: Synchronous Demodulation Intermediate Frequency (IF) Signal to Obtain Received Signal:**

First, the received GNSS signal undergoes down-conversion to shift it from the radio frequency (RF) to the intermediate frequency (IF). This is achieved by mixing the received signal with a carrier signal generated by a local oscillator to remove the carrier frequency, retaining the pseudo-random noise (PRN) code and navigation data (Nav data) modulated on the IF.  
The demodulated IF signal contains the modulated information of the PRN code and navigation data, which can be represented in both the time and frequency domains. 

**Step 2: Obtaining the Frequency Domain Representation of the PRN Code and Navigation Data:**

Using the Fast Fourier Transform (FFT), the IF signal in the time domain is converted to the frequency domain, yielding its frequency domain representation. This step helps analyze the frequency components of the signal and provides a foundation for subsequent correlation calculations. Fig.1.1.(d) is the time domain plot of received IF signal, let the remove carrier range as IF±j*500Hz(j = 1,2,…14), Fig.1.(e) shows the frequency domain plot of the received signal post carrier remove (take j equals 1 as an example).

**Step 3: Calculating the Frequency Domain Representation of Each PRN Code:**

For each possible satellite PRN code, it is similarly transformed from the time domain to the frequency domain using FFT, resulting in its frequency domain representation (denoted as b). The frequency domain representation of the PRN code reflects its frequency characteristics. Fig.1.1.(a) is the i-th PRN code (1023 chips, 58000 sampling per code). The sampling per chip equals 56.7 (58000/1023), which can be verified in the zoom in figure in Fig.1.1.(b).

**Step 4: Computing the Product of a and b in the Frequency Domain:**

In the frequency domain, the frequency domain representation of the IF signal Fig.1.1.(e) is multiplied point-by-point with the frequency domain representation of the PRN code Fig.1.1.(c). This operation corresponds to the convolution of the signals in the time domain, which characterizes the correlation between the original IF signal and the specific PRN code. 

By applying the Inverse Fast Fourier Transform (IFFT) to the frequency domain product, the result is converted back to the time domain, yielding the correlation function. The peak position of the correlation function indicates the optimal alignment time between the signal and the PRN code, thereby determining the code phase. Fig.1.1.(f) is the correlation plot of 58000 samples and 28 search frequency bins for i-th PRN code. Fig.1.1.(g) records the peak value of the i-th PRN correlation plot.

***Note that these methods are used to ensure the reliability and robustness of the results:***

***(1) To ensure the accuracy of the correlation peak and avoid errors introduced by noise, we selected two adjacent 1 ms segments (PRN code duration) from the received signal and performed the operation described in Figure 1(e) simultaneously. Then, each element in Figure 1(f) is assigned the maximum correlation coefficient from the two segments.***

***(2) In addition to identifying the maximum correlation peak, we also searched for the second-largest correlation peak. If the ratio of the maximum correlation peak to the second-largest correlation peak satisfies Pmax_1/Pmax_2>1.5, and the two peaks are not too close to each other, the maximum correlation peak is considered meaningful, and the corresponding satellite is successfully acquired. Fig.1.2 shows the difference of the correlation peak of acquired and not acquired satellite.***

![Fig.1.2 The difference of the correlation peak of acquired and not acquired satellite](https://github.com/Togure/GNSS-SDR/blob/main/figues/1.2.jpg)  
Fig.1.2 The difference of the correlation peak of acquired and not acquired satellite

**Step 5: Correlation Analysis:**

The maximum value of the correlation function reflects the degree of match between the original IF signal and the PRN code. By detecting the correlation peak, it is possible to determine whether the PRN code corresponds to the currently received satellite signal and to further estimate the Doppler shift and code phase of the signal.  
This process is repeated until the PRN codes of all visible satellites are identified, and their Doppler shifts and code phases are initially estimated. 

### **Results:**
![Fig.1.3 The result of acquisition results of urban and opensky dataset.](https://github.com/Togure/GNSS-SDR/blob/main/figues/1.3.jpg)  
Fig.1.3 is the result of acquisition results of urban dataset and opensky dataset.
In the urban dataset, satellite 1,3,11,18 can be acquired.
In the open sky dataset, satellite 16,22,26,27,31 can be acquired.



## Task 2 – Signal Tracking

### **Objective**: Adapt the tracking loop (DLL) to generate correlation plots and analyze tracking performance. Discuss the impact of urban interference on correlation peaks.

### **Steps**:
The tracking loop in GNSS signal processing is a critical component of the receiver, used to precisely track the carrier frequency and pseudo-random code phase of satellite signals. The tracking loop typically consists of two main parts: the carrier tracking loop (PLL) and the code tracking loop (DLL). The carrier tracking loop is responsible for tracking the carrier frequency and phase of the signal, while the code tracking loop tracks the phase of the pseudo-random code.

**Step 1: Tracking Process and Components:**

During the tracking process, the receiver first down-converts the input signal and performs correlation calculations based on the initial carrier frequency and code phase information obtained during the acquisition phase. The down-conversion process brings the signal to the baseband, and the correlator calculates the correlation between the signal and the locally generated pseudo-random code. The correlator outputs are divided into multiple branches, typically including Early, Prompt, and Late branches, which are used to calculate the code phase error. The carrier tracking loop adjusts the frequency and phase of the local carrier by calculating the phase error of the signal to maintain synchronization with the received signal. Specificilly,  codeError = (sqrt(I_E * I_E + Q_E * Q_E) - sqrt(I_L * I_L + Q_L * Q_L)) / (sqrt(I_E * I_E + Q_E * Q_E) + sqrt(I_L * I_L + Q_L * Q_L)), which indicates the carrier frequency drift.


**Step 2: Feedback Control and Real-Time Adjustment:**

The core of the tracking loop lies in its feedback control mechanism, which continuously adjusts the locally generated carrier and pseudo-random code to align with the received signal. The error signals are smoothed by loop filters to reduce noise impact and generate control signals to adjust the local oscillator and code generator. This process operates in real-time, typically updated at millisecond intervals, to ensure tracking accuracy and stability.

**Step 3: Design Considerations and Applications:**

The design of the tracking loop must consider multiple factors, such as loop bandwidth and damping ratio, which directly affect the dynamic performance and noise resistance of the loop. By appropriately setting these parameters, stable tracking performance can be maintained in dynamic environments and under noise interference. Ultimately, the carrier frequency, code phase, and other information output by the tracking loop are used for subsequent navigation calculations to determine the receiver's position, velocity, and time.


**Results**:
![Fig.1.3 The result of acquisition results of urban and opensky dataset.](https://github.com/Togure/GNSS-SDR/blob/main/figues/2.1.jpg)  

Fig.2.1.(a) The correlation result of open sky dataset.

Fig.2.1.(b) shows the correlation plots and analyzes tracking performance in an open sky area. As time changes, the correlation results vary little, with the raw DLL discriminator and filtered DLL maintaining around 0, showing no significant change. 

![Fig.1.3 The result of acquisition results of urban and opensky dataset.](https://github.com/Togure/GNSS-SDR/blob/main/figues/2.2.jpg)  

Fig.2.2.(b) The correlation result of open sky dataset.

Fig.2.2.(b) presents the correlation plots and analyzes tracking performance in an urban area. As time changes, the correlation results fluctuate, with the filtered DLL discriminator approximately at -2.5. Fig.2.2.(a) and Fig.2.1.(a) show the average correlation results of different channels within 20 seconds. The magnitudes of the early and late signals differ little.

![Fig.1.3 The result of acquisition results of urban and opensky dataset.](https://github.com/Togure/GNSS-SDR/blob/main/figues/2.3.jpg)  

Fig.2.3 The correlation result of open sky dataset.


In order to discuss the impact of urban multipath on the correlation peak, we used different early-late offset correlators with a step size of 0.01 chips. The results are shown in Fig.2.2.

---

## Task 3 – Navigation Data Decoding
### **Objective**: Decode the navigation message and extract key parameters, such as ephemeris data, for at least one satellite.

### **Steps**:
After the tracking step in GNSS signal processing, the receiver successfully locks onto the satellite signal and demodulates the navigation data bitstream. The next critical step is the extraction and compilation of ephemeris data, which is essential for position calculation. Below is a brief overview of how ephemeris information is compiled:

**Step 1: Navigation Data Frame Decoding:**

Navigation data is transmitted in fixed-format frames and subframes. Each subframe contains specific information, such as time, satellite status, and ephemeris data.
The receiver identifies the start of each subframe from the demodulated bitstream and decodes the data according to the protocol (e.g., the GPS L1 C/A signal protocol). Corresponding to the I_P in the trackresults.

![.](https://github.com/Togure/GNSS-SDR/blob/main/figues/3.2.jpg)  

Fig.3.1 Bits of navigation message

**Step 2: Ephemeris Data Extraction:**

Ephemeris data is typically distributed across multiple subframes. For example, in GPS, ephemeris information is located in Subframe 2 and Subframe 3.
The receiver extracts ephemeris parameters from these subframes, including orbital parameters (e.g., semi-major axis, eccentricity, inclination) and time correction parameters.

**Step 3: Data Validation and Error Correction:**

Navigation data includes parity bits (e.g., parity check) to detect transmission errors.
If errors are detected, the receiver can correct them using error correction algorithms or by waiting for the next frame of data.

**Step 4: Ephemeris Information Compilation:**

The extracted ephemeris parameters are compiled into a format used internally by the receiver to calculate the satellite's position and velocity.
These parameters are typically stored as Keplerian orbital elements and combined with time information to predict the satellite's precise position.

### **Results**:

We take PRN16 in the open sky dataset as an example to analyze the ephemeris information

Table 1 Ephemeris information of PRN 16.

| Parameters                  | Remark                                                                 | Value                     |
|-----------------------------|------------------------------------------------------------------------|---------------------------|
| weekNumber                  | The week number of the satellite's launch, which determines the timeliness of the data. | 1155                      |
| IODE_sf2 / IODE_sf3        | Issue of Data for Ephemeris, which ensures that the most recent ephemeris data is used. |    9                      |
| e (Eccentricity)                  | Describes the shape of the satellite's orbit, influencing position calculations.| 0.0122962790774181    |
| sqrtA (Square Root of Semi-Major Axis) | The shape of the satellite's orbit, influencing position calculations. | 5153.77132225037       |
| M_0 (Mean Anomaly at Reference Time) | Used to calculate the satellite's position in its orbit, directly affecting its altitude. | 0.718116855169473       |
| i_0 (Inclination Angle)    | Describes the tilt of the satellite's orbit, affecting visibility.    | 0.971603403113095      |
| omega_0 (Longitude of Ascending Node) | The initial position of the satellite's orbit, influencing orbit calculations. | -1.67426142885170       |
| omega (Argument of Perigee) | Describes the rotation of the satellite's orbit, affecting position changes. | 0.679609496852005      |
| omegaDot (Rate of Change of the Argument of Perigee) | Describes the dynamic characteristics of the orbit, impacting precise positioning. | -8.01283376668916e-09     |
| T_GD (Time Group Delay)    | Corrects the delay between the satellite clock and standard time, ensuring time accuracy. | -1.02445483207703e-08      |


---

## Task 4 – Position and Velocity Estimation
**Objective**: Use pseudorange measurements from tracking to implement the Weighted Least Squares (WLS) algorithm and compute the user's position and velocity.

**Step 1: Problem Description**

Using pseudorange measurements from satellite tracking, implement the Weighted Least Squares (WLS) algorithm to compute the user's position and velocity. Plot the results, compare them with ground truth, and analyze the impact of multipath effects on the WLS solution.


**Step 2: Data Preparation**

Collect pseudorange measurements from satellite tracking. Obtain satellite positions and velocities. Acquire ground truth data for user position and velocity. Construct the weight matrix based on measurement uncertainties.


**Step 3: WLS Algorithm Implementation**

*Position Estimation*: Linearize the pseudorange observation equations. Use WLS to iteratively solve for user position and clock bias until convergence.

*Velocity Estimation*: Linearize the Doppler observation equations, use WLS to iteratively solve for user velocity and clock drift until convergence.

In the WLS, we consider the elevation as the weights coefficient to use WLS, i.e.

```matlab
weight(i) = sin(el(i))^2;
......
W = diag(weight)；
C = W'*W;
x = (A'*C*A)\(A'*C*omc);
......

```

**Step 4: Plot Results**

Plot the estimated user position and velocity over time, and overlay the ground truth data for comparison.


**Step 5: Compare Results**

Calculate the Root Mean Square Error (RMSE) for position and velocity, and analyze the deviations between estimated values and ground truth.

**Results**:

![.](https://github.com/Togure/GNSS-SDR/blob/main/figues/4.1.jpg)  

Fig.4.1 is the result of open sky dataset. (a) shows the estimated velocity result. (b) is the positioning error. (c) is the positioning plot and sky-plot.
(d) is the CDF of  horizontal velocity error of LS and WLS. (e) CDF of positioning error of LS and WLS. 

 ![.](https://github.com/Togure/GNSS-SDR/blob/main/figues/4.2.jpg)  
 
Fig.4.2 is the result of urban. (a) shows the estimated velocity result. (b) is the positioning error. (c) is the positioning plot and sky-plot.
(d) is the CDF of positioning error of LS and WLS. 

The difference between WLS and LS is not obvious enough. The difference between WLS and LS is not obvious enough. The ninetieth of the horizontal positioning accuracy is about 100 meters.
The ninetieth of the horizontal positioning accuracy is about 10 meters.By conparison, in the urban area, the positioning accuracy is obvious worse than open-sky area. 
 


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
