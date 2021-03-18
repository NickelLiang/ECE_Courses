import numpy as np

def blend(im1, im2, mask):
  mask = mask / 255.
  out = im1 * mask + (1-mask) * im2
  return out
