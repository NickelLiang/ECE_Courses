import numpy as np
from generate_scene import get_ball
import matplotlib.pyplot as plt

# specular exponent
k_e = 50

# Normalize a ndarray
def normalize(arr):
  norm = np.linalg.norm(arr, axis=2)
  norm = norm.reshape((norm.shape[0],norm.shape[1],1))
  return arr / norm
  
def render(Z, N, A, S, 
           point_light_loc, point_light_strength, 
           directional_light_dirn, directional_light_strength,
           ambient_light, k_e):
  # To render the images you will need the camera parameters, you can assume
  # the following parameters. (cx, cy) denote the center of the image (point
  # where the optical axis intersects with the image, f is the focal length.
  # These parameters along with the depth image will be useful for you to
  # estimate the 3D points on the surface of the sphere for computing the
  # angles between the different directions.
  h, w = A.shape
  cx, cy = w / 2, h /2
  f = 128.

  # Ambient Term
  I = A * ambient_light
  
  # Diffuse Term  
  pixel_loc = np.full_like(N, 0)
  for i in range(N.shape[0]):
    for j in range(N.shape[1]):
      # i for y-axis, j for x-axis
      pixel_loc[i][j][0] = (j-cx)*Z[i][j]/f
      pixel_loc[i][j][1] = (i-cy)*Z[i][j]/f
      pixel_loc[i][j][2] = Z[i][j]
  
  # Create v_i for directional light
  v_i_dir = np.full_like(N, 0)
  v_i_dir[:] = directional_light_dirn[0]

  # Create v_i for point light
  v_i_pnt = np.full_like(N, 0)
  v_i_pnt = point_light_loc[0] - pixel_loc
  v_i_pnt = normalize(v_i_pnt)

  # Calculate diffuse terms
  diffuse_pnt = point_light_strength * np.maximum(np.sum(v_i_pnt * N, axis = 2), 0)
  diffuse_dir = directional_light_strength * np.maximum(np.sum(v_i_dir * N, axis = 2), 0)

  # Add to the image
  I = I + A * (diffuse_pnt + diffuse_dir).reshape(A.shape)
  
  # Specular Term
  # Create v_r, which is points looking back to our camera
  v_r = pixel_loc.copy()
  v_r = -v_r
  v_r = normalize(v_r)
  
  # Create s_i for directional and point light
  s_i_dir = np.full_like(N, 0)
  s_i_pnt = np.full_like(N, 0)
  for i in range(N.shape[0]):
    for j in range(N.shape[1]):
      # Extract normal for a single pixel
      n = N[i][j].reshape(3,1)
      # Compute the common part of both s_i
      common = (2*n.dot(n.T) - np.identity(3))
      # Calculate s_i for point light
      s_i_pnt[i][j] = common.dot(v_i_pnt[i][j])
      # Calculate s_i for directional light
      s_i_dir[i][j] = common.dot(v_i_dir[i][j])

  # Normalize s_i
  s_i_pnt = normalize(s_i_pnt)
  s_i_dir = normalize(s_i_dir)
  
  # Calculate specular terms
  specular_pnt = point_light_strength * np.maximum(np.sum(s_i_pnt * v_r, axis = 2), 0) ** k_e
  specular_dir = directional_light_strength * np.maximum(np.sum(s_i_dir * v_r, axis = 2), 0) ** k_e
  
  # Add to the image
  I = I + S * (specular_pnt + specular_dir).reshape(S.shape)

  # Post processing
  I = np.minimum(I, 1)*255
  I = I.astype(np.uint8)
  I = np.repeat(I[:,:,np.newaxis], 3, axis=2)
  return I

def main():
  for specular in [True, False]:
    # get_ball function returns:
    # - Z (depth image: distance to scene point from camera center, along the
    # Z-axis)
    # - N is the per pixel surface normals (N[:,:,0] component along X-axis
    # (pointing right), N[:,:,1] component along Y-axis (pointing down),
    # N[:,:,2] component along Z-axis (pointing into the scene)),
    # - A is the per pixel ambient and diffuse reflection coefficient per pixel,
    # - S is the per pixel specular reflection coefficient.
    Z, N, A, S = get_ball(specular=specular)

    # Strength of the ambient light.
    ambient_light = 0.5
    
    # For the following code, you can assume that the point sources are located
    # at point_light_loc and have a strength of point_light_strength. For the
    # directional light sources, you can assume that the light is coming _from_
    # the direction indicated by directional_light_dirn, and with strength
    # directional_light_strength. The coordinate frame is centered at the
    # camera, X axis points to the right, Y-axis point down, and Z-axis points
    # into the scene.
    
    # Case I: No directional light, only point light source that moves around
    # the object. 
    point_light_strength = [1.5]
    directional_light_dirn = [[1, 0, 0]]
    directional_light_strength = [0.0]
    
    fig, axes = plt.subplots(4, 4, figsize=(15,10))
    axes = axes.ravel()[::-1].tolist()
    for theta in np.linspace(0, np.pi*2, 16): 
      point_light_loc = [[10*np.cos(theta), 10*np.sin(theta), -3]]
      I = render(Z, N, A, S, point_light_loc, point_light_strength, 
                 directional_light_dirn, directional_light_strength,
                 ambient_light, k_e)
      ax = axes.pop()
      ax.imshow(I)
      ax.set_axis_off()
    plt.savefig(f'specular{specular:d}_move_point.png', bbox_inches='tight')
    plt.close()

    # Case II: No point source, just a directional light source that moves
    # around the object.
    point_light_loc = [[0, -10, 2]]
    point_light_strength = [0.0]
    directional_light_strength = [2.5]
    
    fig, axes = plt.subplots(4, 4, figsize=(15,10))
    axes = axes.ravel()[::-1].tolist()
    for theta in np.linspace(0, np.pi*2, 16): 
      directional_light_dirn = [np.array([np.cos(theta), np.sin(theta), .1])]
      directional_light_dirn[0] = \
        directional_light_dirn[0] / np.linalg.norm(directional_light_dirn[0])
      I = render(Z, N, A, S, point_light_loc, point_light_strength, 
                 directional_light_dirn, directional_light_strength,
                 ambient_light, k_e) 
      ax = axes.pop()
      ax.imshow(I)
      ax.set_axis_off()
    plt.savefig(f'specular{specular:d}_move_direction.png', bbox_inches='tight')
    plt.close()

if __name__ == '__main__':
  main()
