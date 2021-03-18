import numpy as np
import os
import matplotlib.pyplot as plt
import warnings

def z_wall(z=4, f=128, h=256, w=384, cx=192, cy=128):
  x, y = np.meshgrid(np.arange(w), np.arange(h))
  x = x - cx
  y = y - cy

  Z = depth = x - x + z
  N = np.zeros((h, w, 3), dtype=np.float64)
  N[:,:,2] = -1.
  A = np.mod(x // 64 + y // 64, 2) * 0.5 + 0.1
  A[:] = 0.4
  S = A - A
  return Z, N, A, S

def sphere(r=1.2, z=2, specular=False, f=128, h=256, w=384, cx=192, cy=128):
  # Let's assume that camera is at origin looking in the +Z direction. X axis
  # to the right, Y axis downwards.
  # Let's assume that the sphere is at (0, 0, z) and of radius r.
  x, y = np.meshgrid(np.arange(w), np.arange(h))
  x = x - cx
  y = y - cy

  phi = np.arccos(f / np.sqrt(x**2 + y**2 + f**2))
  # equation is rho*2 (1+tan^2(phi)) - 2 rho * z + z*z - r*r = 0
  a = np.tan(phi)**2 + 1
  b = -2 * z
  c = z**2 - r**2
  with warnings.catch_warnings():
    warnings.simplefilter("ignore")
    rho = -b - np.sqrt(b**2 - 4*a*c) 
  rho = rho / 2 / a
  depth = rho
  
  # Calculate the point on the sphere surface
  X = x * depth / f
  Y = y * depth / f
  Z = depth
  N = np.array([X, Y, Z])
  N = np.transpose(N, [1,2,0])
  N = N - np.array([[[0, 0, z]]])
  N = N / np.linalg.norm(N, axis=2, keepdims=True)
  Z[np.isnan(Z)] = np.inf

  # Compute k_d, k_a 
  with warnings.catch_warnings():
    warnings.simplefilter("ignore")
    A = (np.sign(X*Y) > 0) * 0.5 + 0.1
  
  # Set specularity
  if specular:
    S = np.invert(np.isinf(depth)) + 0
  else:
    S = A-A
  return Z, N, A, S

def compose(Z1, N1, A1, S1, Z2, N2, A2, S2):
  ind = np.argmin(np.array([Z1, Z2]), axis=0)
  Z = Z1 + 0
  Z[ind == 1] = Z2[ind == 1]
  A = A1 + 0
  A[ind == 1] = A2[ind == 1]
  S = S1 + 0
  S[ind == 1] = S2[ind == 1]
  N = N1 + 0
  ind = np.repeat(ind[:, :, np.newaxis], 3, axis=2)
  N[ind == 1] = N2[ind == 1]
  return Z, N, A, S

def get_ball(specular):
  Z1, N1, A1, S1 = sphere(specular=specular)
  Z2, N2, A2, S2 = z_wall()
  Z, N, A, S = compose(Z1, N1, A1, S1, Z2, N2, A2, S2)
  return Z, N, A, S
  
if __name__ == '__main__':
  Z1, N1, A1, S1 = sphere(specular=True)
  Z2, N2, A2, S2 = z_wall()
  Z, N, A, S = compose(Z1, N1, A1, S1, Z2, N2, A2, S2)
  
  fig = plt.figure(constrained_layout=False, figsize=(20, 5))
  gs1 = fig.add_gridspec(nrows=1, ncols=4, left=0.05, right=0.95, wspace=0.05, top=0.95, bottom=0.05)
  axes = []
  for i in range(4):
    axes.append(fig.add_subplot(gs1[0,i]))
    axes[-1].set_axis_off()
  
  axes[0].imshow(Z, cmap='gray', vmin=0, vmax=5)
  axes[0].set_title('Depth, Z')
  # visualizing surface normals using a commonly used color map.
  N[:,:,0] = -N[:,:,0]
  axes[1].imshow((-N[:,:,[0,1,2]]+1)/2.)
  axes[1].set_title('Surface normal, N')
  axes[2].imshow(A, cmap='gray', vmin=0, vmax=1)
  axes[2].set_title('Ambient reflection coefficient, $k_a =$ Diffuse reflection coefficient, $k_d$')
  axes[3].imshow(S, cmap='gray', vmin=0, vmax=1)
  axes[3].set_title('Specular reflection coefficient, $k_s$')
  plt.savefig('input.png', bbox_inches='tight')

