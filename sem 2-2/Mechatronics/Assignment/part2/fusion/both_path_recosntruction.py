import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

def run_ekf(file_path, color, label):
    df = pd.read_csv(file_path)
    df["timestamp"] = pd.to_datetime(df["timestamp"])
    df["dt"] = df["timestamp"].diff().dt.total_seconds().fillna(0.01)

    gyro_z = np.radians(df["gyro_z"].to_numpy())
    mag_x = df["mag_x"].to_numpy()
    mag_y = df["mag_y"].to_numpy()
    left_enc = df["left_encoder_count"].diff().fillna(0) * 0.000095
    right_enc = df["right_encoder_count"].diff().fillna(0) * 0.000095

    x = np.array([0, 0, 0, 0, 0])  # [x, y, theta, v_x, v_y]
    P = np.eye(5) * 0.1
    Q = np.diag([0.01, 0.01, 0.01, 0.1, 0.1])
    R = np.diag([0.05, 0.05, 0.1])

    estimated_states = []

    for i in range(1, len(df)):
        dt = df.loc[i, "dt"]
        F = np.eye(5)
        F[0, 3] = dt
        F[1, 4] = dt
        x = F @ x
        x[2] += gyro_z[i] * dt

        P = F @ P @ F.T + Q

        d_center = (left_enc[i] + right_enc[i]) / 2
        theta_meas = np.arctan2(mag_y[i], mag_x[i])
        
        H = np.zeros((3, 5))
        H[0, 0] = 1
        H[1, 1] = 1
        H[2, 2] = 1
        
        z = np.array([x[0] + d_center * np.cos(x[2]),
                      x[1] + d_center * np.sin(x[2]),
                      theta_meas])
        
        y_k = z - H @ x
        S = H @ P @ H.T + R
        K = P @ H.T @ np.linalg.inv(S)
        x = x + K @ y_k
        P = (np.eye(5) - K @ H) @ P

        estimated_states.append(x.copy())

    estimated_states = np.array(estimated_states)
    result_df = pd.DataFrame({
        "timestamp": df["timestamp"].iloc[1:],
        "x": estimated_states[:, 0] * 100,  # Scale up if needed
        "y": estimated_states[:, 1] * 100,
        "theta": np.degrees(estimated_states[:, 2]),
    })

    result_df.to_csv(f"fused_trajectory_{label}.csv", index=False)

    # --- Extract first heading from CSV ---
    initial_heading_deg = df["heading"].iloc[0]  # Get first heading value
    initial_heading_rad = np.radians(initial_heading_deg)  # Convert to radians
    print(f"Path {label}: Rotating by {initial_heading_deg:.2f} degrees")

    # --- Apply rotation transformation ---
    x_rotated = np.cos(initial_heading_rad) * result_df["x"] - np.sin(initial_heading_rad) * result_df["y"]
    y_rotated = np.sin(initial_heading_rad) * result_df["x"] + np.cos(initial_heading_rad) * result_df["y"]

    # Plot rotated trajectory
    plt.plot(x_rotated, y_rotated, label=f"Rotated Path {label} ({initial_heading_deg:.2f}°)", 
             color=color, linewidth=2)

plt.figure(figsize=(10, 8))
run_ekf("path_1_telemetry.csv", "blue", "1")
run_ekf("path_2_telemetry.csv", "red", "2")

# Auto-adjust to actual data range
plt.xlabel("X Position (m)")
plt.ylabel("Y Position (m)")
plt.title("Rotated Fused Sensor Trajectories using EKF")
plt.legend()
plt.grid()
plt.savefig("rotated_fused_trajectories.png")
plt.show()
