import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy.spatial.transform import Rotation
from mpl_toolkits.mplot3d import Axes3D

def calculate_trajectory_from_imu(csv_file):
    # Load data from CSV
    data = pd.read_csv(csv_file)
    
    # Extract relevant columns
    timestamps = data['timestamp'].values
    accel_x = data['accel_x'].values
    accel_y = data['accel_y'].values
    accel_z = data['accel_z'].values
    gyro_x = data['gyro_x'].values
    gyro_y = data['gyro_y'].values
    gyro_z = data['gyro_z'].values
    imu_temp = data['imu_temp'].values
    
    # Calculate time differences between samples
    dt = np.diff(timestamps)
    # Handle possible zero dt values and add a value for the first sample
    dt = np.insert(dt, 0, 0.01)  # Assuming 0.01s for first sample if unknown
    dt = np.where(dt <= 0, 0.01, dt)  # Replace zero or negative dt with 0.01s
    
    # System constants
    g = 9.81  # gravity constant (m/s^2)
    
    # Calibration parameters (to be determined through calibration)
    # Temperature sensitivity coefficients
    k_ax, k_ay, k_az = 0, 0, 0  # Accelerometer temperature coefficients
    k_gx, k_gy, k_gz = 0, 0, 0  # Gyroscope temperature coefficients
    T_ref = np.mean(imu_temp)  # Use mean temperature as reference
    
    # Estimate biases by averaging first few samples (assuming vehicle is stationary)
    num_calibration_samples = min(100, len(timestamps))
    accel_x_bias = np.mean(accel_x[:num_calibration_samples])
    accel_y_bias = np.mean(accel_y[:num_calibration_samples])
    accel_z_bias = np.mean(accel_z[:num_calibration_samples]) - g  # Assuming z-axis is aligned with gravity
    
    gyro_x_bias = np.mean(gyro_x[:num_calibration_samples])
    gyro_y_bias = np.mean(gyro_y[:num_calibration_samples])
    gyro_z_bias = np.mean(gyro_z[:num_calibration_samples])
    
    # Initialize storage for trajectory
    num_samples = len(timestamps)
    
    # Quaternion representation of orientation (w, x, y, z)
    quaternion = np.zeros((num_samples, 4))
    quaternion[0] = [1, 0, 0, 0]  # Initial orientation (identity)
    
    # Position, velocity
    position = np.zeros((num_samples, 3))
    velocity = np.zeros((num_samples, 3))
    
    # Variables for odometry calculation
    total_distance = 0
    odometry = np.zeros(num_samples)
    
    # Variables for ZUPT
    is_stationary = np.zeros(num_samples, dtype=bool)
    accel_threshold = 0.1  # m/s^2
    gyro_threshold = 0.05  # rad/s
    
    # Calculate trajectory
    for i in range(1, num_samples):
        # Apply temperature compensation and bias removal
        current_temp = imu_temp[i]
        
        # Temperature compensation for accelerometer
        accel_x_comp = accel_x[i] - (k_ax * (current_temp - T_ref))
        accel_y_comp = accel_y[i] - (k_ay * (current_temp - T_ref))
        accel_z_comp = accel_z[i] - (k_az * (current_temp - T_ref))
        
        # Temperature compensation for gyroscope
        gyro_x_comp = gyro_x[i] - (k_gx * (current_temp - T_ref))
        gyro_y_comp = gyro_y[i] - (k_gy * (current_temp - T_ref))
        gyro_z_comp = gyro_z[i] - (k_gz * (current_temp - T_ref))
        
        # Bias removal
        accel_x_unbiased = accel_x_comp - accel_x_bias
        accel_y_unbiased = accel_y_comp - accel_y_bias
        accel_z_unbiased = accel_z_comp - accel_z_bias
        
        gyro_x_unbiased = gyro_x_comp - gyro_x_bias
        gyro_y_unbiased = gyro_y_comp - gyro_y_bias
        gyro_z_unbiased = gyro_z_comp - gyro_z_bias
        
        # Update orientation using gyroscope data
        # Get previous quaternion
        q_prev = quaternion[i-1]
        
        # Angular velocity in rad/s
        omega = np.array([gyro_x_unbiased, gyro_y_unbiased, gyro_z_unbiased])
        
        # Quaternion derivative calculation (using small angle approximation)
        omega_quat = np.array([0, omega[0], omega[1], omega[2]])
        q_dot = 0.5 * quaternion_multiply(q_prev, omega_quat)
        
        # Integrate quaternion
        current_dt = dt[i]
        q_new = q_prev + q_dot * current_dt
        
        # Normalize quaternion
        q_new = q_new / np.linalg.norm(q_new)
        quaternion[i] = q_new
        
        # Convert quaternion to rotation matrix
        rotation_matrix = quaternion_to_rotation_matrix(q_new)
        
        # Gravity compensation
        gravity_nav = np.array([0, 0, g])
        gravity_body = rotation_matrix.T @ gravity_nav
        
        # Remove gravity from accelerometer readings
        accel_body = np.array([accel_x_unbiased, accel_y_unbiased, accel_z_unbiased])
        accel_body_no_gravity = accel_body - gravity_body
        
        # Transform acceleration to navigation frame
        accel_nav = rotation_matrix @ accel_body_no_gravity
        
        # Detect if vehicle is stationary for ZUPT
        accel_magnitude = np.linalg.norm(accel_body)
        gyro_magnitude = np.linalg.norm(omega)
        
        is_stationary[i] = (abs(accel_magnitude - g) < accel_threshold) and (gyro_magnitude < gyro_threshold)
        
        # Apply ZUPT
        if is_stationary[i]:
            velocity[i] = np.zeros(3)
        else:
            # Integrate acceleration to get velocity
            velocity[i] = velocity[i-1] + accel_nav * current_dt
        
        # Integrate velocity to get position
        position[i] = position[i-1] + velocity[i-1] * current_dt + 0.5 * accel_nav * current_dt**2
        
        # Calculate incremental distance for odometry
        delta_d = np.linalg.norm(position[i] - position[i-1])
        total_distance += delta_d
        odometry[i] = total_distance
    
    return {
        'timestamps': timestamps,
        'position': position,
        'velocity': velocity,
        'quaternion': quaternion,
        'odometry': odometry,
        'is_stationary': is_stationary
    }

def quaternion_multiply(q1, q2):
    """
    Multiply two quaternions
    q1, q2: quaternions in format [w, x, y, z]
    """
    w1, x1, y1, z1 = q1
    w2, x2, y2, z2 = q2
    
    w = w1*w2 - x1*x2 - y1*y2 - z1*z2
    x = w1*x2 + x1*w2 + y1*z2 - z1*y2
    y = w1*y2 - x1*z2 + y1*w2 + z1*x2
    z = w1*z2 + x1*y2 - y1*x2 + z1*w2
    
    return np.array([w, x, y, z])

def quaternion_to_rotation_matrix(q):
    """
    Convert quaternion to rotation matrix
    q: quaternion in format [w, x, y, z]
    """
    w, x, y, z = q
    
    # Pre-compute repeated terms
    xx = x*x
    xy = x*y
    xz = x*z
    xw = x*w
    
    yy = y*y
    yz = y*z
    yw = y*w
    
    zz = z*z
    zw = z*w
    
    # Construct rotation matrix
    R = np.array([
        [1 - 2*(yy + zz), 2*(xy - zw), 2*(xz + yw)],
        [2*(xy + zw), 1 - 2*(xx + zz), 2*(yz - xw)],
        [2*(xz - yw), 2*(yz + xw), 1 - 2*(xx + yy)]
    ])
    
    return R

def plot_trajectory(trajectory_data):
    """
    Plot the trajectory in 3D
    """
    position = trajectory_data['position']
    
    fig = plt.figure(figsize=(12, 10))
    
    # 3D trajectory
    ax1 = fig.add_subplot(221, projection='3d')
    ax1.plot(position[:, 0], position[:, 1], position[:, 2])
    ax1.set_xlabel('X (m)')
    ax1.set_ylabel('Y (m)')
    ax1.set_zlabel('Z (m)')
    ax1.set_title('3D Trajectory')
    
    # 2D trajectory (top view)
    ax2 = fig.add_subplot(222)
    ax2.plot(position[:, 0], position[:, 1])
    ax2.set_xlabel('X (m)')
    ax2.set_ylabel('Y (m)')
    ax2.set_title('2D Trajectory (Top View)')
    ax2.grid(True)
    
    # Velocity magnitude
    ax3 = fig.add_subplot(223)
    velocity = trajectory_data['velocity']
    velocity_magnitude = np.linalg.norm(velocity, axis=1)
    ax3.plot(trajectory_data['timestamps'], velocity_magnitude)
    ax3.set_xlabel('Time (s)')
    ax3.set_ylabel('Velocity (m/s)')
    ax3.set_title('Velocity Magnitude')
    ax3.grid(True)
    
    # Odometry
    ax4 = fig.add_subplot(224)
    ax4.plot(trajectory_data['timestamps'], trajectory_data['odometry'])
    ax4.set_xlabel('Time (s)')
    ax4.set_ylabel('Distance (m)')
    ax4.set_title('Cumulative Distance (Odometry)')
    ax4.grid(True)
    
    plt.tight_layout()
    plt.show()
    
    return fig

# Example usage
if __name__ == "__main__":
    # Replace with your CSV file path
    csv_file = "vehicle_data.csv"
    
    try:
        # Calculate trajectory
        trajectory_data = calculate_trajectory_from_imu(csv_file)
        
        # Plot results
        plot_trajectory(trajectory_data)
        
        # Print final position and distance
        final_position = trajectory_data['position'][-1]
        total_distance = trajectory_data['odometry'][-1]
        
        print(f"Final position (X, Y, Z): {final_position[0]:.2f}, {final_position[1]:.2f}, {final_position[2]:.2f} meters")
        print(f"Total distance traveled: {total_distance:.2f} meters")
        
    except Exception as e:
        print(f"Error processing the CSV file: {e}")