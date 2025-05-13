import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import least_squares

# Load dataset
file_path = "path_1_telemetry.csv"  # Update the file path
df = pd.read_csv(file_path)

# Convert timestamp to datetime format
df["timestamp"] = pd.to_datetime(df["timestamp"])
df["dt"] = df["timestamp"].diff().dt.total_seconds().fillna(0)

# Extract magnetometer data
mag_x = df["mag_x"].to_numpy(dtype=np.float64)
mag_y = df["mag_y"].to_numpy(dtype=np.float64)
mag_z = df["mag_z"].to_numpy(dtype=np.float64)

# Hard-Iron Offset Correction (Bias Removal)
offset_x = np.mean(mag_x)
offset_y = np.mean(mag_y)
offset_z = np.mean(mag_z)

mag_x_corrected = mag_x - offset_x
mag_y_corrected = mag_y - offset_y
mag_z_corrected = mag_z - offset_z

# Soft-Iron Correction using Ellipse Fitting
def ellipse_residuals(params, x, y):
    """Residual function for least squares fitting."""
    a, b, d, x0, y0 = params  # Ellipse parameters
    x_adj = x - x0
    y_adj = y - y0
    return (x_adj / a) ** 2 + (y_adj / b) ** 2 - 1

# Initial guess for ellipse parameters
params_initial = [np.std(mag_x_corrected), np.std(mag_y_corrected), 0, np.mean(mag_x_corrected), np.mean(mag_y_corrected)]
result = least_squares(ellipse_residuals, params_initial, args=(mag_x_corrected, mag_y_corrected))
a, b, d, x0, y0 = result.x

# Apply soft-iron correction
mag_x_calibrated = (mag_x_corrected - x0) / a
mag_y_calibrated = (mag_y_corrected - y0) / b
mag_z_calibrated = mag_z_corrected  # Assume Z-axis remains unchanged

# Extract gyroscope data
gyro_z = df["gyro_z"].to_numpy()

# Compute heading angle using magnetometer
theta_mag = np.arctan2(mag_y_calibrated, mag_x_calibrated)

# Integrate gyroscope data to estimate heading
theta_gyro = np.zeros_like(theta_mag)
theta_gyro[0] = theta_mag[0]  # Initialize with magnetometer

for i in range(1, len(df)):
    dt = df["dt"].iloc[i]
    theta_gyro[i] = theta_gyro[i-1] + gyro_z[i] * dt

# Apply complementary filter to fuse data
alpha = 0.98  # Weight for gyroscope (adjustable)
theta_fused = alpha * theta_gyro + (1 - alpha) * theta_mag

# Assume constant velocity for trajectory estimation
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
plt.plot(df["timestamp"], theta_mag, label="Calibrated Magnetometer Heading", linestyle="dashed", color="red")
plt.plot(df["timestamp"], theta_fused, label="Fused Heading (Mag + IMU)", linestyle="solid", color="blue")
plt.xlabel("Time")
plt.ylabel("Heading (radians)")
plt.title("Magnetometer vs. Fused Heading Estimation (After Calibration)")
plt.legend()
plt.grid()
plt.savefig("heading_comparison_calibrated.png")
plt.show()
