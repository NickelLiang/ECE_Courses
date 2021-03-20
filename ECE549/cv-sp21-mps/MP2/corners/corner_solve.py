import numpy as np
import scipy
import cv2

# import matplotlib
# matplotlib.use("TkAgg")
# from matplotlib import pyplot as plt

def rgb_2_gray(I):
  I = cv2.cvtColor(I, cv2.COLOR_BGR2GRAY)
  I = I.astype(np.float32)/255.
  return I

def gradient(I, gtype='conv'):
  if (gtype == 'sobel'):
    dx = scipy.ndimage.sobel(I, 0)
    dy = scipy.ndimage.sobel(I, 1)
  elif (gtype == 'conv'):
    dx = scipy.signal.convolve2d(I, np.array([[-1, 0, 1]]), mode='same', boundary='symm')
    dy = scipy.signal.convolve2d(I, np.array([[-1, 0, 1]]).T, mode='same', boundary='symm')
  elif (gtype == 'numpy'):
    dy, dx = np.gradient(I)
  return dx, dy

def gaussian_kernel(I, sigma):
  return scipy.ndimage.gaussian_filter(I, sigma)

def normalize(I):
  return (I / np.amax(I)) * 255.0

def get_response(I, k, sigma, gtype='conv'):
  dx, dy = gradient(I, gtype)
  i_xx = gaussian_kernel(dx**2, sigma)
  i_yy = gaussian_kernel(dy**2, sigma)
  i_xy = gaussian_kernel(dx*dy, sigma)

  det = i_xx * i_yy - i_xy**2
  trace = i_xx + i_yy
  r = det - k * (trace**2)

  assert(r.shape == I.shape)
  return r

def threshold_nms(response, window=15):
  # window need to be larger than 3 and odd
  assert(window%2 == 1)
  assert(window >= 3)

  offset = int((window - 1) / 2)

  corners = np.zeros(response.shape)
  for i in range(offset, response.shape[0]-offset):
    for j in range(offset, response.shape[1]-offset):
      region = response[i-offset:i+offset+1, j-offset:j+offset+1]
      if (np.amax(region) == response[i,j]):
        corners[i,j] = response[i,j]
      else:
        corners[i,j] = 0

  return corners

def compute_corners(I):
  # Currently this code proudces a dummy corners and a dummy corner response
  # map, just to illustrate how the code works. Your task will be to fill this
  # in with code that actually implements the Harris corner detector. You
  # should return th ecorner response map, and the non-max suppressed corners.
  # Input:
  #   I: input image, H x W x 3 BGR image
  # Output:
  #   response: H x W response map in uint8 format
  #   corners: H x W map in uint8 format _after_ non-max suppression. Each
  #   pixel stores the score for being a corner. Non-max suppressed pixels
  #   should have a low / zero-score.
  
  
  # k, sigma, w, gtype = 0.05, 1, 7, 'numpy'
  # k, sigma, w, gtype = 0.05, 3, 15, 'numpy'
  # k, sigma, w, gtype = 0.04, 1, 7, 'numpy'
  # k, sigma, w, gtype = 0.06, 1, 7, 'numpy'
  # k, sigma, w, gtype = 0.05, 0.85, 3, 'numpy'
  # k, sigma, w, gtype = 0.05, 0.85, 3, 'sobel'
  # k, sigma, w, gtype = 0.05, 0.85, 3, 'conv'
  
  # Best visualization with 37073
  k, sigma, w, gtype = 0.05, 0.85, 7, 'conv'

  I = rgb_2_gray(I)

  response = get_response(I, k, sigma, gtype)
  response = normalize(response)
  response = np.clip(response, 0, 255)

  # corners = response
  corners = threshold_nms(response, w)
  corners = np.clip(corners, 0, 255)

  response = response.astype(np.uint8)
  corners = corners.astype(np.uint8)
  
  return response, corners
