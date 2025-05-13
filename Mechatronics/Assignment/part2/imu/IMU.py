# import pandas as pd
# import numpy as np
# import matplotlib.pyplot as plt

# # Load the CSV file
# # Load the CSV file
# file_path = "path_2_telemetry.csv"  # Replace with your actual file path
# data = pd.read_csv(file_path)






# # Check if the file was loaded correctly
# if data.empty:
#     print("Error: CSV file is empty or not loaded properly.")
#     exit()



# # Convert timestamp to datetime
# data['timestamp'] = pd.to_datetime(data['timestamp'], errors='coerce')

# # Drop rows where timestamp could not be converted
# data = data.dropna(subset=['timestamp'])

# # Convert timestamp to seconds (relative to the first timestamp)
# data['timestamp'] = (data['timestamp'] - data['timestamp'].iloc[0]).dt.total_seconds()

# # Check if the data is now clean
# print(data['timestamp'].head(10))
# print("Number of valid timestamps:", len(data))

# # Check again if the data is empty after dropping NaNs
# if data.empty:
#     print("Error: No valid timestamps found after cleaning the data.")
#     exit()

# # Convert timestamp to seconds (assuming it's in milliseconds)
# data['timestamp'] = data['timestamp'] / 1000.0

# # Initialize velocity and position arrays
# velocity_x = [0]
# velocity_y = [0]
# position_x = [0]
# position_y = [0]
# orientation = [0]  # Initial orientation (theta)

# # Sampling time (delta_t) calculation
# delta_t = np.diff(data['timestamp'].values, prepend=data['timestamp'].values[0])

# # Motion estimation loop
# for i in range(1, len(data)):
#     # Get gyroscope data (angular velocity around the z-axis)
#     gyro_z = data['gyro_z'].iloc[i] if 'gyro_z' in data.columns else 0
#     orientation.append(orientation[-1] + gyro_z * delta_t[i])
    
#     # Get acceleration data (in x and y directions)
#     accel_x = data['accel_x'].iloc[i] if 'accel_x' in data.columns else 0
#     accel_y = data['accel_y'].iloc[i] if 'accel_y' in data.columns else 0
    
#     # Integrate acceleration to get velocity
#     vx = velocity_x[-1] + accel_x * delta_t[i]
#     vy = velocity_y[-1] + accel_y * delta_t[i]
#     velocity_x.append(vx)
#     velocity_y.append(vy)
    
#     # Integrate velocity to get position (considering orientation)
#     dx = vx * delta_t[i] * np.cos(orientation[-1])
#     dy = vy * delta_t[i] * np.sin(orientation[-1])
#     position_x.append(position_x[-1] + dx)
#     position_y.append(position_y[-1] + dy)

# # Plotting the reconstructed trajectory
# plt.figure(figsize=(8, 8))
# plt.plot(position_x, position_y, label="Reconstructed Path")
# plt.xlabel("X Position (m)")
# plt.ylabel("Y Position (m)")
# plt.title("IMU-Based Reconstructed Trajectory")
# plt.grid(True)
# plt.legend()
# plt.savefig("IMU_plot_method0.png")

#################################################################method1##################################################

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# Load the CSV file
file_path = "path_1_telemetry.csv"  # Replace with your actual file path
data = pd.read_csv(file_path)

# Check if the file was loaded correctly
if data.empty:
    print("Error: CSV file is empty or not loaded properly.")
    exit()

# Convert timestamp to datetime and drop invalid timestamps
data['timestamp'] = pd.to_datetime(data['timestamp'], errors='coerce')
data = data.dropna(subset=['timestamp'])
data['timestamp'] = (data['timestamp'] - data['timestamp'].iloc[0]).dt.total_seconds()

# Check if the data is clean
if data.empty:
    print("Error: No valid timestamps found after cleaning the data.")
    exit()

# Initialize arrays for velocity and displacement
velocity_x = [0]
velocity_y = [0]
position_x = [0]
position_y = [0]

# Sampling time (delta_t) calculation
delta_t = np.diff(data['timestamp'].values, prepend=data['timestamp'].values[0])

# Integrate accelerometer readings to estimate displacement
for i in range(1, len(data)):
    # Get acceleration data (in x and y directions)
    accel_x = data['accel_x'].iloc[i] if 'accel_x' in data.columns else 0
    accel_y = data['accel_y'].iloc[i] if 'accel_y' in data.columns else 0
    
    # Integrate acceleration to get velocity
    vx = velocity_x[-1] + accel_x * delta_t[i]
    vy = velocity_y[-1] + accel_y * delta_t[i]
    velocity_x.append(vx)
    velocity_y.append(vy)
    
    # Integrate velocity to get displacement
    dx = vx * delta_t[i]
    dy = vy * delta_t[i]
    position_x.append(position_x[-1] + dx)
    position_y.append(position_y[-1] + dy)

# Plotting the reconstructed displacement trajectory
plt.figure(figsize=(8, 8))
plt.plot(position_x, position_y, label="Reconstructed Path")
plt.xlabel("X Displacement (m)")
plt.ylabel("Y Displacement (m)")
plt.title("Estimated Displacement from Accelerometer Data")
plt.grid(True)
plt.legend()
plt.savefig("IMU_plot_before_calibration.png")

# first prompt

# import pandas as pd
# import numpy as np
# import matplotlib.pyplot as plt
# from scipy.signal import butter, filtfilt

# # Load the CSV file
# file_path = "path_2_telemetry.csv"  # Replace with your actual file path
# data = pd.read_csv(file_path)

# # Convert timestamp to datetime and drop invalid timestamps
# data['timestamp'] = pd.to_datetime(data['timestamp'], errors='coerce')
# data = data.dropna(subset=['timestamp'])
# data['timestamp'] = (data['timestamp'] - data['timestamp'].iloc[0]).dt.total_seconds()

# # Sampling time (delta_t) calculation
# delta_t = np.diff(data['timestamp'].values, prepend=data['timestamp'].values[0])

# # ---------------- Step 1: Define Calibration Functions ----------------

# def remove_bias(accel_series):
#     """ Remove sensor bias using mean of first few stationary readings. """
#     bias = np.mean(accel_series[:50])  # Assume first 50 samples are at rest
#     return accel_series - bias

# def scale_correction(accel_series, expected_range=16):
#     """ Normalize data based on expected sensor range. """
#     sensor_max = max(abs(accel_series))  # Find max absolute reading
#     return accel_series * (expected_range / sensor_max)

# def high_pass_filter(data, cutoff=0.1, fs=10):
#     """ Apply a high-pass filter to remove drift effects. """
#     nyquist = 0.5 * fs
#     normal_cutoff = cutoff / nyquist
#     b, a = butter(1, normal_cutoff, btype='high', analog=False)
#     return filtfilt(b, a, data)

# # ---------------- Step 2: Calibration ----------------

# # Check if acceleration columns exist, else assume zeros
# if 'accel_x' in data.columns and 'accel_y' in data.columns:
#     data['accel_x_raw'] = data['accel_x']
#     data['accel_y_raw'] = data['accel_y']

#     # Step 1: Remove Bias
#     data['accel_x'] = remove_bias(data['accel_x'])
#     data['accel_y'] = remove_bias(data['accel_y'])

#     # Step 2: Scale Correction
#     data['accel_x'] = scale_correction(data['accel_x'])
#     data['accel_y'] = scale_correction(data['accel_y'])

#     # Step 3: Apply High-Pass Filter
#     data['accel_x'] = high_pass_filter(data['accel_x'])
#     data['accel_y'] = high_pass_filter(data['accel_y'])

# # ---------------- Step 3: Path Reconstruction ----------------

# def integrate_motion(accel_x, accel_y, delta_t):
#     """ Double integration to compute displacement from acceleration. """
#     velocity_x, velocity_y = [0], [0]
#     position_x, position_y = [0], [0]

#     for i in range(1, len(accel_x)):
#         # Integrate acceleration to get velocity
#         vx = velocity_x[-1] + accel_x[i] * delta_t[i]
#         vy = velocity_y[-1] + accel_y[i] * delta_t[i]
#         velocity_x.append(vx)
#         velocity_y.append(vy)

#         # Integrate velocity to get displacement
#         dx = vx * delta_t[i]
#         dy = vy * delta_t[i]
#         position_x.append(position_x[-1] + dx)
#         position_y.append(position_y[-1] + dy)

#     return position_x, position_y

# # Path without calibration
# pos_x_raw, pos_y_raw = integrate_motion(data['accel_x_raw'], data['accel_y_raw'], delta_t)

# # Path with calibration
# pos_x_calib, pos_y_calib = integrate_motion(data['accel_x'], data['accel_y'], delta_t)

# # ---------------- Step 4: Plot Results ----------------

# plt.figure(figsize=(10, 5))

# # Plot without calibration
# plt.subplot(1, 2, 1)
# plt.plot(pos_x_raw, pos_y_raw, label="Raw Data Path", color='red')
# plt.xlabel("X Displacement (m)")
# plt.ylabel("Y Displacement (m)")
# plt.title("Path Without Calibration")
# plt.grid(True)
# plt.legend()

# # Plot with calibration
# plt.subplot(1, 2, 2)
# plt.plot(pos_x_calib, pos_y_calib, label="Calibrated Data Path", color='blue')
# plt.xlabel("X Displacement (m)")
# plt.ylabel("Y Displacement (m)")
# plt.title("Path With Calibration")
# plt.grid(True)
# plt.legend()

# plt.tight_layout()
# plt.savefig("IMU_calibrated_vs_raw.png")

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import butter, filtfilt

# Load the CSV file
file_path = "path_1_telemetry.csv"  # Replace with your actual file path
data = pd.read_csv(file_path)

# Convert timestamp to datetime and drop invalid timestamps
data['timestamp'] = pd.to_datetime(data['timestamp'], errors='coerce')
data = data.dropna(subset=['timestamp'])
data['timestamp'] = (data['timestamp'] - data['timestamp'].iloc[0]).dt.total_seconds()

# Sampling time (delta_t) calculation
delta_t = np.diff(data['timestamp'].values, prepend=data['timestamp'].values[0])

# ---------------- Step 1: Define Improved Calibration Functions ----------------

def remove_bias(sensor_series, window_size=500):
    """ Remove IMU bias using a moving average over a larger stationary window. """
    bias = np.mean(sensor_series[:window_size])  # Use first 500 samples for better bias estimate
    return sensor_series - bias

def apply_low_pass_filter(data, cutoff=1, fs=10):
    """ Apply a low-pass filter to reduce high-frequency noise. """
    nyquist = 0.5 * fs
    normal_cutoff = cutoff / nyquist
    b, a = butter(1, normal_cutoff, btype='low', analog=False)
    return filtfilt(b, a, data)

def remove_gravity(accel_x, accel_y, accel_z):
    """ Estimate gravity direction and subtract it from accelerometer readings. """
    g_x = np.mean(accel_x[:500])
    g_y = np.mean(accel_y[:500])
    g_z = np.mean(accel_z[:500])
    
    accel_x -= g_x
    accel_y -= g_y
    accel_z -= g_z
    return accel_x, accel_y, accel_z

# ---------------- Step 2: Apply Calibration ----------------

if all(col in data.columns for col in ['accel_x', 'accel_y', 'accel_z', 'gyro_x', 'gyro_y', 'gyro_z']):
    data['accel_x_raw'] = data['accel_x']
    data['accel_y_raw'] = data['accel_y']
    data['accel_z_raw'] = data['accel_z']

    # Step 1: Remove Bias
    data['accel_x'] = remove_bias(data['accel_x'])
    data['accel_y'] = remove_bias(data['accel_y'])
    data['accel_z'] = remove_bias(data['accel_z'])

    # Step 2: Gravity Compensation
    data['accel_x'], data['accel_y'], data['accel_z'] = remove_gravity(data['accel_x'], data['accel_y'], data['accel_z'])

    # Step 3: Apply Low-Pass Filter to Reduce Noise
    data['accel_x'] = apply_low_pass_filter(data['accel_x'])
    data['accel_y'] = apply_low_pass_filter(data['accel_y'])
    data['accel_z'] = apply_low_pass_filter(data['accel_z'])

# ---------------- Step 3: Improved Motion Integration ----------------

def integrate_motion(accel_x, accel_y, delta_t):
    """ Use trapezoidal integration to compute displacement. """
    velocity_x, velocity_y = [0], [0]
    position_x, position_y = [0], [0]

    for i in range(1, len(accel_x)):
        # Trapezoidal integration for better accuracy
        vx = velocity_x[-1] + 0.5 * (accel_x[i] + accel_x[i-1]) * delta_t[i]
        vy = velocity_y[-1] + 0.5 * (accel_y[i] + accel_y[i-1]) * delta_t[i]
        velocity_x.append(vx)
        velocity_y.append(vy)

        dx = vx * delta_t[i]
        dy = vy * delta_t[i]
        position_x.append(position_x[-1] + dx)
        position_y.append(position_y[-1] + dy)

    return position_x, position_y

# Path reconstruction
pos_x_calib, pos_y_calib = integrate_motion(data['accel_x'], data['accel_y'], delta_t)

# ---------------- Step 4: Plot Corrected Path ----------------

plt.figure(figsize=(6, 6))
plt.plot(pos_x_calib, pos_y_calib, label="Calibrated IMU Path", color='blue')
plt.xlabel("X Displacement (m)")
plt.ylabel("Y Displacement (m)")
plt.title("IMU Path with Improved Calibration")
plt.grid(True)
plt.legend()

plt.savefig("IMU_calibrated_vs_raw.png")



##############################################method2#########################################################



# import numpy as np
# import pandas as pd
# import matplotlib.pyplot as plt
# from mpl_toolkits.mplot3d import Axes3D  # Import 3D plotting

# # Load CSV File
# data = pd.read_csv('path_2_telemetry.csv')  # Ensure the file has correct column names

# # Constants
# dt = 0.01  # Time step in seconds (assuming 100 Hz sampling rate)
# g = 9.81  # Gravity in m/s²
# alpha = 0.001  # Damping factor to reduce drift

# # Convert data to numpy arrays
# accel_x = data['accel_x'].to_numpy()
# accel_y = data['accel_y'].to_numpy()
# gyro_z = np.radians(data['gyro_z'].to_numpy())  # Convert yaw rate to radians
# imu_temp = data['imu_temp'].to_numpy()

# # Correct for temperature-based drift (Simple Linear Model)
# k1, k2 = 0.0001, 0.0001  # Calibration coefficients for temp correction
# gyro_z_corrected = gyro_z - k1 * (imu_temp - np.mean(imu_temp))
# accel_x_corrected = accel_x - k2 * (imu_temp - np.mean(imu_temp))
# accel_y_corrected = accel_y - k2 * (imu_temp - np.mean(imu_temp))

# # Initialize variables
# num_samples = len(accel_x)
# yaw = np.zeros(num_samples)
# velocity = np.zeros((num_samples, 2))  # [vx, vy]
# position = np.zeros((num_samples, 2))  # [x, y]

# # Compute yaw, velocity, and position
# for i in range(1, num_samples):
#     # Integrate yaw (only from corrected gyro)
#     yaw[i] = yaw[i-1] + gyro_z_corrected[i] * dt  
    
#     # Rotate acceleration to global frame
#     acc_global_x = accel_x_corrected[i] * np.cos(yaw[i]) - accel_y_corrected[i] * np.sin(yaw[i])
#     acc_global_y = accel_x_corrected[i] * np.sin(yaw[i]) + accel_y_corrected[i] * np.cos(yaw[i])
    
#     # Integrate acceleration to get velocity (with damping factor)
#     velocity[i, 0] = (velocity[i-1, 0] + acc_global_x * dt) * (1 - alpha)
#     velocity[i, 1] = (velocity[i-1, 1] + acc_global_y * dt) * (1 - alpha)
    
#     # Integrate velocity to get position
#     position[i, 0] = position[i-1, 0] + velocity[i, 0] * dt
#     position[i, 1] = position[i-1, 1] + velocity[i, 1] * dt

# # Save estimated values to CSV
# output_df = pd.DataFrame({
#     'yaw': np.degrees(yaw), 
#     'velocity_x': velocity[:, 0], 'velocity_y': velocity[:, 1],
#     'position_x': position[:, 0], 'position_y': position[:, 1]
# })
# output_df.to_csv('estimated_motion_imu.csv', index=False)

# # Plot the results
# fig = plt.figure(figsize=(12, 10))

# # 2D Trajectory Plot (X vs Y)
# ax1 = fig.add_subplot(2, 1, 1)
# ax1.plot(position[:, 0], position[:, 1], label="2D Trajectory", color='b')
# ax1.set_xlabel('X Position (m)')
# ax1.set_ylabel('Y Position (m)')
# ax1.set_title('Estimated 2D Trajectory (IMU Data)')
# ax1.legend()
# ax1.grid(True)

# # 3D Trajectory Plot (X, Y, Yaw)
# ax2 = fig.add_subplot(2, 1, 2, projection='3d')
# ax2.plot(position[:, 0], position[:, 1], np.degrees(yaw), label="3D Trajectory (Yaw)", color='r')
# ax2.set_xlabel('X Position (m)')
# ax2.set_ylabel('Y Position (m)')
# ax2.set_zlabel('Yaw (Degrees)')
# ax2.set_title('Estimated 3D Trajectory (IMU Data)')
# ax2.legend()
# ax2.grid(True)

# plt.tight_layout()
# # plt.savefig('trajectory_2d_3d_plot_imu.png')
# plt.savefig("IMU_plot_method2.png")
 
