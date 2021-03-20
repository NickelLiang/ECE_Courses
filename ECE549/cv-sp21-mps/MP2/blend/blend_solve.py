import numpy as np
import scipy
import cv2

import matplotlib
matplotlib.use("TkAgg")
from matplotlib import pyplot as plt

def rgb_2_gray(I):
  I = cv2.cvtColor(I, cv2.COLOR_BGR2GRAY)
  I = I.astype(np.float32)/255.
  return I

def create_laplacian_stack(I, level, sigma_start=1, sigma_mul=np.sqrt(2)):
  assert(level >= 1)

  img = I.copy()
  stack = [img]
  lap_stack = []
  sigma = sigma_start
  for i in range(level):
    img = scipy.ndimage.gaussian_filter(img, sigma)
    stack.append(img)
    sigma = sigma * sigma_mul
    diff = stack[i] - stack[i+1]
    lap_stack.append(diff)

  return lap_stack

def create_gaussian_stack(mask, level, sigma_start=1, sigma_mul=np.sqrt(2)):
  assert(level >= 1)

  img = mask.copy()
  gau_stack = []
  sigma = sigma_start
  for i in range(level):
    img = scipy.ndimage.gaussian_filter(img, sigma)
    gau_stack.append(img)
    sigma = sigma * sigma_mul

  return gau_stack

def combine_pyramid(la, lb, gr):
  assert(len(la) == len(lb))
  assert(len(lb) == len(gr))

  ls = []
  for i in range(len(gr)):
    img = gr[i] * la[i] + (1 - gr[i]) * lb[i]
    ls.append(img)
  
  return ls

def collapse(ls):
  img = ls[0]
  for i in range(1,len(ls)):
    img += ls[i]

  return img

def normalize(I):
  return ((I - np.amin(I)) / np.amax(I - np.amin(I))) * 255.0

def blend(im1, im2, mask):
  # Get grayscale image
  I1 = rgb_2_gray(im1)
  I2 = rgb_2_gray(im2)
  ma = rgb_2_gray(mask)

  level, sigma_start, sigma_mul = 10, 1, np.sqrt(2)

  la = create_laplacian_stack(I1, level, sigma_start, sigma_mul)
  lb = create_laplacian_stack(I2, level, sigma_start, sigma_mul)
  gr = create_gaussian_stack(ma, level, sigma_start, sigma_mul)

  ls = combine_pyramid(la, lb, gr)

  out = collapse(ls)
  out = normalize(out)
  out = np.clip(out, 0, 255)
  out = out.astype(np.uint8)

  return out
