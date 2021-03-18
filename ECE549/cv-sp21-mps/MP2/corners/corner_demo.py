# Code from Saurabh Gupta
from absl import app, flags
from tqdm import tqdm
import os, sys, numpy as np, cv2, time
from scipy import signal
from skimage.util import img_as_float
from skimage.io import imread
import matplotlib
matplotlib.use('Agg')
from matplotlib import pyplot as plt
from corner_eval import compute_pr
from corner_plot import display_results
from corner_solve import compute_corners

FLAGS = flags.FLAGS
flags.DEFINE_string("output_dir", "output/demo", 
                    "Directory to save results in.")
flags.DEFINE_enum("mode", "benchmark", ["benchmark", "vis"], 
                  "Whether to visualize output on a single image, or benchmark on an image set")
flags.DEFINE_string("imset", "val", 
                    "Image set to use for testing")
flags.DEFINE_string("imname", "draw_cube_17", 
                    "Image set to use for testing")
flags.DEFINE_float("vis_thresh", 0.1*255, 
                    "Threshold value for visualization")

def get_imlist(imset):
  ls = []
  with open(f"data/{imset}/imlist", 'rt') as f:
    for l in f:
      ls.append(l.rstrip())
  return ls

def detect_corners(imlist, fn, out_dir):
  total_time = 0
  for imname in tqdm(imlist):
    I = cv2.imread(os.path.join('data', FLAGS.imset, 'images', f'{imname}.png'))
    start_time = time.time()
    response, corners = fn(I)
    total_time += time.time() - start_time
    out_file_name = os.path.join(out_dir, str(imname)+'.png')
    cv2.imwrite(out_file_name, corners)
  return total_time / len(imlist)

def load_gt(imname):
    gt_path = os.path.join('data', FLAGS.imset, 'points', f'{imname}.npy')
    return np.load(gt_path)

def load_pred(output_dir, imname):
    pred_path = os.path.join(output_dir, '{}.png'.format(imname))
    return img_as_float(imread(pred_path))

def vis(fn, imname, output_dir):
  I = cv2.imread(os.path.join('data', 'vis', str(imname)+'.png'))
  response, corners = fn(I)
  cv2_corners = np.where(corners >= FLAGS.vis_thresh)
  cv2_corners = [cv2.KeyPoint(float(c[1]), float(c[0]), 1.0) for c in np.stack(cv2_corners).T]

  # Visualize the returned response map and corners
  I_corners = cv2.drawKeypoints(I, cv2_corners, None, color=(0, 255, 0))

  I_gray = cv2.cvtColor(cv2.cvtColor(I, cv2.COLOR_BGR2GRAY), cv2.COLOR_GRAY2BGR)
  heatmap_img = cv2.applyColorMap(response, cv2.COLORMAP_PARULA)
  heatmap_img[:] = 0
  heatmap_img[:,:,-1] = response

  wt1, wt2 = 0.5, 0.5
  I_response = wt1 * (I_gray / 2.5 + 150) + wt2 * heatmap_img
  I_response = I_response.astype(np.uint8)

  I_all = cv2.hconcat([I, I_response, I_corners])
  
  # Save the image
  out_name = os.path.join(output_dir, str(imname) + '_vis.png')
  print('Writing visualization to {:s}'.format(out_name))
  cv2.imwrite(out_name, I_all)
 
def main(_):
  output_dir = FLAGS.output_dir
  if not os.path.exists(output_dir):
    os.makedirs(output_dir)

  if FLAGS.mode == 'vis':
    vis_dir = os.path.join(output_dir, 'vis')
    if not os.path.exists(vis_dir):
      os.makedirs(vis_dir)
    fn = compute_corners
    vis(fn, FLAGS.imname, vis_dir)
    
  if FLAGS.mode == 'benchmark':
    imset = FLAGS.imset
    imlist = get_imlist(imset)
    fn = compute_corners 
  
    bench_dir = os.path.join(output_dir, 'bench')
    if not os.path.exists(bench_dir):
      os.makedirs(bench_dir)
    
    print('Running detector:')
    runtime = detect_corners(imlist, fn, bench_dir)
    
    print('Evaluating:')
    ap, precision, recall, prob = compute_pr(
      imlist, load_gt, lambda x: load_pred(bench_dir, x), progress=tqdm)
    out_file_name = os.path.join(output_dir, 'ap.txt')
    with open(out_file_name, 'wt') as f:
      print('{:>20s}: {:<10.6f}'.format('ap', ap))
      print('{:>20s}: {:<10.6f}'.format('runtime (in seconds)', runtime))
      f.write('{:>20s}: {:<10.6f}\n'.format('ap', ap))
      f.write('{:>20s}: {:<10.6f}\n'.format('runtime (in seconds)', runtime))
    
    print('Saving evaluation:')
    out_file_name = os.path.join(output_dir, 'metrics.npz')
    np.savez(out_file_name, precision=precision, recall=recall, 
             ap=ap, runtime=runtime)
    
    fig = plt.figure(figsize=(6,6))
    ax = fig.gca()
    display_results(ax, FLAGS.output_dir, precision, recall, ap)
    fig.savefig(os.path.join(output_dir, 'pr.pdf'), bbox_inches='tight')

if __name__ == '__main__':
  app.run(main)
