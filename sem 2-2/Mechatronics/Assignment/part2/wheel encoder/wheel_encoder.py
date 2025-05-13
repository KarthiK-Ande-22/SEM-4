import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# Load the CSV file
file_path = "path_1_telemetry.csv"  
df = pd.read_csv(file_path)

# Convert timestamp to datetime format
df["timestamp"] = pd.to_datetime(df["timestamp"])
df["dt"] = df["timestamp"].diff().dt.total_seconds().fillna(0)

# Given parameters
encoder_resolution = 0.000095  
inner_track_width = 0.09  
outer_track_width = 0.12  
track_width = (inner_track_width + outer_track_width) / 2  

# Compute left and right track distances
df["left_distance"] = df["left_encoder_count"].diff().fillna(0) * encoder_resolution
df["right_distance"] = df["right_encoder_count"].diff().fillna(0) * encoder_resolution

# Compute center displacement and change in orientation
df["d_center"] = (df["left_distance"] + df["right_distance"]) / 2
df["d_theta"] = (df["right_distance"] - df["left_distance"]) / track_width

# Initialize position variables
x, y, theta = [0], [0], [0]

# Compute trajectory
for i in range(1, len(df)):
    new_theta = theta[-1] + df.loc[i, "d_theta"]
    new_x = x[-1] + df.loc[i, "d_center"] * np.cos(new_theta)
    new_y = y[-1] + df.loc[i, "d_center"] * np.sin(new_theta)
    
    x.append(new_x)
    y.append(new_y)
    theta.append(new_theta)

# Convert lists to dataframe columns
df["x"], df["y"] = x, y

# Extract initial heading from CSV (first value of heading column)
initial_heading_deg = df["heading"].iloc[0]  # Get first heading value
initial_heading_rad = np.radians(initial_heading_deg)  # Convert to radians

# --- APPLY ROTATION ---
x_rotated = np.cos(initial_heading_rad) * df["x"] - np.sin(initial_heading_rad) * df["y"]
y_rotated = np.sin(initial_heading_rad) * df["x"] + np.cos(initial_heading_rad) * df["y"]

# --- PLOT ---
plt.figure(figsize=(8, 6))
plt.plot(x_rotated, y_rotated, marker="o", linestyle="-", color="blue", label="Rotated Trajectory")
plt.xlabel("X Position (m)")
plt.ylabel("Y Position (m)")
plt.title(f"Rotated Vehicle Trajectory (by {initial_heading_deg}°)")
plt.legend()
plt.grid()

# Save and show the rotated plot
plt.savefig("rotated_trajectory_plot.png")
plt.show()