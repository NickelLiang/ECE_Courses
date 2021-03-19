import numpy as np
from scipy import signal
from scipy import ndimage
import cv2

# import matplotlib
# matplotlib.use("TkAgg")
# from matplotlib import pyplot as plt

def conv_demo(I):
  dx = signal.convolve2d(I, np.array([[-1, 0, 1]]), mode='same')
  dy = signal.convolve2d(I, np.array([[-1, 0, 1]]).T, mode='same')
  return dx, dy

def conv_part1(I):
  dx = signal.convolve2d(I, np.array([[-1, 0, 1]]), mode='same', boundary='symm')
  dy = signal.convolve2d(I, np.array([[-1, 0, 1]]).T, mode='same', boundary='symm')
  return dx, dy 

def conv_part2(I, pts=3, sigma=3):
  assert(pts%2 == 1)
  gaussian = signal.windows.gaussian(pts, sigma).reshape((1,-1))
  assert(gaussian.shape == (1, pts))
  filter1d = np.gradient(gaussian, axis=1)
  dx = signal.convolve2d(I, filter1d, mode='same', boundary='symm')
  dy = signal.convolve2d(I, filter1d.T, mode='same', boundary='symm')
  return dx, dy

def conv_part2_simple(I, sigma=0.5):
  smoothed = ndimage.gaussian_filter(I, sigma)
  dx = signal.convolve2d(smoothed, np.array([[-1, 0, 1]]), mode='same', boundary='symm')
  dy = signal.convolve2d(smoothed, np.array([[-1, 0, 1]]).T, mode='same', boundary='symm')
  return dx, dy

# return edge gradient direction in degree
def edge_direction(dx, dy):
  return np.degrees(np.arctan2(-dy, dx))

# debug function to obtain image show edge direction on edge, filter out unnecessay info
def draw_edge_dir(mag, rad):
  threshold = np.mean(mag)+np.std(mag)
  return np.ma.masked_where(mag <= threshold, rad)

def interpolation_1d(a, b, alpha):
  return alpha * b + (1 - alpha) * a

# # non-maximum suppression
def nms_interpolation(mag, rad, dx, dy, cc = True):
  edg = np.zeros(mag.shape)
  # print(np.amin(rad), np.amax(rad))
  rad[rad < 0] += 180
  # print(np.amin(rad), np.amax(rad))
  for i in range(1, mag.shape[0]-1):
    for j in range(1, mag.shape[1]-1):
      if (rad[i,j] >= 0 and rad[i,j] <= 45):
        if cc: # Counter-Clockwise Angle
          # index 0 is closer, index 1 is further
          pos = np.array([mag[i,j+1], mag[i-1,j+1]])
          neg = np.array([mag[i,j-1], mag[i+1,j-1]])
        else: # Clockwise Angle
          pos = np.array([mag[i,j+1], mag[i+1,j+1]])
          neg = np.array([mag[i,j-1], mag[i-1,j-1]])
        # use derivative and magnitude to estimate distance closer to axis
        alpha = np.absolute(dy[i,j]/mag[i,j])
      elif (rad[i,j] > 45 and rad[i,j] <= 90):
        if cc:
          pos = np.array([mag[i-1,j], mag[i-1,j+1]])
          neg = np.array([mag[i+1,j], mag[i+1,j-1]])
        else:
          pos = np.array([mag[i+1,j], mag[i+1,j+1]])
          neg = np.array([mag[i-1,j], mag[i-1,j-1]])
        alpha = np.absolute(dx[i,j]/mag[i,j])
      elif (rad[i,j] > 90 and rad[i,j] <= 135):
        if cc:
          pos = np.array([mag[i-1,j], mag[i-1,j-1]])
          neg = np.array([mag[i+1,j], mag[i+1,j+1]])
        else:
          pos = np.array([mag[i+1,j], mag[i+1,j-1]])
          neg = np.array([mag[i-1,j], mag[i-1,j+1]])
        alpha = np.absolute(dx[i,j]/mag[i,j])
      else: # 135 to 180
        if cc:
          pos = np.array([mag[i,j-1], mag[i-1,j-1]])
          neg = np.array([mag[i,j+1], mag[i+1,j+1]])
        else:
          pos = np.array([mag[i,j-1], mag[i+1,j-1]])
          neg = np.array([mag[i,j+1], mag[i-1,j+1]])
        alpha = np.absolute(dy[i,j]/mag[i,j])
      
      if (mag[i,j] >= interpolation_1d(neg[0], neg[1], alpha) and mag[i,j] >= interpolation_1d(pos[0], pos[1], alpha)):
        edg[i,j] = mag[i,j]
      else:
        edg[i,j] = 0
  return edg

def compute_edges_dxdy(I):
  """Returns the norm of dx and dy as the edge response function."""
  I = cv2.cvtColor(I, cv2.COLOR_BGR2GRAY)
  I = I.astype(np.float32)/255.
  
  dx, dy = conv_part2(I, 25, 4)
  # dx, dy = conv_part2_simple(I, 3)

  direction = edge_direction(dx, dy)
  
  mag = np.sqrt(dx**2 + dy**2)
  mag = mag / 1.5
  mag = mag * 255.

  mag = nms_interpolation(mag, direction, dx, dy, cc=True)
  # For better visualization
  # mag = ((mag - np.amin(mag)) / np.amax(mag - np.amin(mag))) * 255.0
  
  mag = np.clip(mag, 0, 255)
  mag = mag.astype(np.uint8)

  return mag