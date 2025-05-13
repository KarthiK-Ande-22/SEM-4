
# import pandas as pd
# import numpy as np
# import matplotlib.pyplot as plt

# # Load the CSV file
# file_path = "path_2_telemetry.csv"  # Replace with your actual file path
# data = pd.read_csv(file_path)

# # Convert timestamp to datetime and calculate seconds
# data['timestamp'] = pd.to_datetime(data['timestamp'], errors='coerce')
# data = data.dropna(subset=['timestamp'])
# data['timestamp'] = (data['timestamp'] - data['timestamp'].iloc[0]).dt.total_seconds()

# # Complementary filter coefficient
# alpha = 0.98

# # Initialize variables
# gyro_heading = 0
# fused_heading = 0
# fused_headings = [fused_heading]

# # Sampling time (delta_t) calculation
# delta_t = np.diff(data['timestamp'], prepend=data['timestamp'].iloc[0])

# # Magnetometer-based heading
# mag_heading = np.arctan2(data['mag_y'], data['mag_x'])

# # Loop to fuse gyro and magnetometer data
# for i in range(1, len(data)):
#     # Gyroscope integration for heading (yaw)
#     gyro_heading += data['gyro_z'][i] * delta_t[i]
    
#     # Magnetometer heading at this time step
#     mag_head = mag_heading[i]
    
#     # Fuse using complementary filter
#     fused_heading = alpha * (fused_heading + data['gyro_z'][i] * delta_t[i]) + (1 - alpha) * mag_head
#     fused_headings.append(fused_heading)

# # Plotting the fused heading
# plt.figure(figsize=(10, 5))
# plt.plot(data['timestamp'], np.unwrap(fused_headings), label="Fused Heading (Complementary Filter)")
# plt.xlabel("Time (seconds)")
# plt.ylabel("Heading (radians)")
# plt.title("Fused Heading from IMU and Magnetometer")
# plt.legend()
# plt.grid(True)
# # plt.show()
# plt.savefig("magnetometer_plot.png")






##############################################method2#########################################################


import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# Load dataset
file_path = "path_1_telemetry.csv"  # Update if needed
df = pd.read_csv(file_path)

# Convert timestamp to datetime format
df["timestamp"] = pd.to_datetime(df["timestamp"])
df["dt"] = df["timestamp"].diff().dt.total_seconds().fillna(0)

# Extract magnetometer data
mag_x = df["mag_x"].to_numpy()
mag_y = df["mag_y"].to_numpy()

# Extract gyroscope data (angular velocity in rad/s)
gyro_z = df["gyro_z"].to_numpy()

# Compute heading angle using magnetometer
theta_mag = np.arctan2(mag_y, mag_x)

# Integrate gyroscope data to estimate heading (assuming initial angle is from magnetometer)
theta_gyro = np.zeros_like(theta_mag)
theta_gyro[0] = theta_mag[0]  # Initialize with magnetometer

for i in range(1, len(df)):
    dt = df["dt"].iloc[i]
    theta_gyro[i] = theta_gyro[i-1] + gyro_z[i] * dt

# Apply complementary filter to fuse data
alpha = 0.98  # Weight for gyroscope (adjustable)
theta_fused = alpha * theta_gyro + (1 - alpha) * theta_mag

# Assume constant velocity
v = 0.1  # meters per second (adjust as needed)

# Initialize trajectory arrays
x_mag, y_mag = np.zeros_like(theta_mag), np.zeros_like(theta_mag)
x_fused, y_fused = np.zeros_like(theta_fused), np.zeros_like(theta_fused)

# Compute estimated trajectories
for i in range(1, len(df)):
    dt = df["dt"].iloc[i]
    x_mag[i] = x_mag[i-1] + v * np.cos(theta_mag[i]) * dt
    y_mag[i] = y_mag[i-1] + v * np.sin(theta_mag[i]) * dt
    x_fused[i] = x_fused[i-1] + v * np.cos(theta_fused[i]) * dt
    y_fused[i] = y_fused[i-1] + v * np.sin(theta_fused[i]) * dt

# Plot Heading Estimates
plt.figure(figsize=(10, 5))
plt.plot(df["timestamp"], theta_mag, label="Magnetometer Heading", linestyle="dashed", color="red")
plt.plot(df["timestamp"], theta_fused, label="Fused Heading (Mag + IMU)", linestyle="solid", color="blue")
plt.xlabel("Time")
plt.ylabel("Heading (radians)")
plt.title("Magnetometer vs. Fused Heading Estimation")
plt.legend()
plt.grid()
plt.savefig("heading_comparison.png")
plt.show()


#heading very bad
# import pandas as pd
# import numpy as np
# import matplotlib.pyplot as plt

# # Load dataset
# file_path = "path_2_telemetry.csv"  # Update if needed
# df = pd.read_csv(file_path)

# # Convert timestamp to datetime format
# df["timestamp"] = pd.to_datetime(df["timestamp"])
# df["dt"] = df["timestamp"].diff().dt.total_seconds().fillna(0)

# # Extract magnetometer data (convert to float64 for safe arithmetic)
# mag_x = df["mag_x"].to_numpy(dtype=np.float64)
# mag_y = df["mag_y"].to_numpy(dtype=np.float64)
# mag_z = df["mag_z"].to_numpy(dtype=np.float64)  # Assuming mag_z exists

# # **Magnetometer Calibration**
# # Compute hard-iron offsets (bias)
# mag_x_min, mag_x_max = np.min(mag_x), np.max(mag_x)
# mag_y_min, mag_y_max = np.min(mag_y), np.max(mag_y)
# mag_z_min, mag_z_max = np.min(mag_z), np.max(mag_z)

# offset_x = (mag_x_max + mag_x_min) / 2
# offset_y = (mag_y_max + mag_y_min) / 2
# offset_z = (mag_z_max + mag_z_min) / 2

# # Apply hard-iron correction
# mag_x_corrected = mag_x - offset_x
# mag_y_corrected = mag_y - offset_y
# mag_z_corrected = mag_z - offset_z

# # mag_x_corrected = mag_x 
# # mag_y_corrected = mag_y 
# # mag_z_corrected = mag_z 

# # Compute soft-iron scaling factors
# scale_x = (mag_x_max - mag_x_min) / 2
# scale_y = (mag_y_max - mag_y_min) / 2
# scale_z = (mag_z_max - mag_z_min) / 2

# # Apply soft-iron correction
# mag_x_calibrated = mag_x_corrected / scale_x
# mag_y_calibrated = mag_y_corrected / scale_y
# mag_z_calibrated = mag_z_corrected / scale_z



# # Extract gyroscope data (angular velocity in rad/s)
# gyro_z = df["gyro_z"].to_numpy()

# # Compute heading angle using calibrated magnetometer data
# theta_mag = np.arctan2(mag_y_calibrated, mag_x_calibrated)

# # Integrate gyroscope data to estimate heading (assuming initial angle is from magnetometer)
# theta_gyro = np.zeros_like(theta_mag)
# theta_gyro[0] = theta_mag[0]  # Initialize with magnetometer

# for i in range(1, len(df)):
#     dt = df["dt"].iloc[i]
#     theta_gyro[i] = theta_gyro[i-1] + gyro_z[i] * dt

# # Apply complementary filter to fuse data
# alpha = 0.98  # Weight for gyroscope (adjustable)
# theta_fused = alpha * theta_gyro + (1 - alpha) * theta_mag

# # Assume constant velocity
# v = 0.1  # meters per second (adjust as needed)

# # Initialize trajectory arrays
# x_mag, y_mag = np.zeros_like(theta_mag), np.zeros_like(theta_mag)
# x_fused, y_fused = np.zeros_like(theta_fused), np.zeros_like(theta_fused)

# # Compute estimated trajectories using calibrated magnetometer data
# for i in range(1, len(df)):
#     dt = df["dt"].iloc[i]
#     x_mag[i] = x_mag[i-1] + v * np.cos(theta_mag[i]) * dt
#     y_mag[i] = y_mag[i-1] + v * np.sin(theta_mag[i]) * dt
#     x_fused[i] = x_fused[i-1] + v * np.cos(theta_fused[i]) * dt
#     y_fused[i] = y_fused[i-1] + v * np.sin(theta_fused[i]) * dt

# # Plot Heading Estimates
# plt.figure(figsize=(10, 5))
# plt.plot(df["timestamp"], theta_mag, label="Calibrated Magnetometer Heading", linestyle="dashed", color="red")
# plt.plot(df["timestamp"], theta_fused, label="Fused Heading (Mag + IMU)", linestyle="solid", color="blue")
# plt.xlabel("Time")
# plt.ylabel("Heading (radians)")
# plt.title("Magnetometer vs. Fused Heading Estimation (After Calibration)")
# plt.legend()
# plt.grid()
# plt.savefig("heading_comparison_calibrated.png")
# plt.show()

# # Plot Estimated Trajectories
# plt.figure(figsize=(8, 6))
# plt.plot(x_mag, y_mag, label="Calibrated Magnetometer-Based Trajectory", color="red", linestyle="dashed")
# plt.plot(x_fused, y_fused, label="Fused Trajectory (Magnetometer + IMU)", color="blue")
# plt.xlabel("X Position (m)")
# plt.ylabel("Y Position (m)")
# plt.title("Estimated Trajectory: Magnetometer vs. Fused (After Calibration)")
# plt.legend()
# plt.grid()
# plt.savefig("trajectory_comparison_calibrated.png")
# plt.show()

