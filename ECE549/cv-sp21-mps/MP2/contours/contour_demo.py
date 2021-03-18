# Code from Saurabh Gupta
from tqdm import tqdm
import os, sys, numpy as np, cv2
sys.path.insert(0, 'pybsds')
from scipy import signal
from skimage.util import img_as_float
from skimage.io import imread
from pybsds.bsds_dataset import BSDSDataset
from pybsds import evaluate_boundaries
import matplotlib
matplotlib.use('Agg')
from matplotlib import pyplot as plt
import json
import time
from absl import flags, app
from contour_plot import display_results

from contour_solve import compute_edges_dxdy

FLAGS = flags.FLAGS
flags.DEFINE_string('output_dir', 'output/demo', 'directory to save results.')
flags.DEFINE_string('imset', 'val', 'image set to use for testing')

N_THRESHOLDS = 99

def get_imlist(imset):
  imlist = np.loadtxt(f'data/{imset}/imlist')
  return imlist.astype(np.int)

def detect_edges(imlist, fn, out_dir):
  total_time = 0
  for imname in tqdm(imlist):
    I = cv2.imread(os.path.join('data', FLAGS.imset, 'images', str(imname)+'.jpg'))
    start_time = time.time()
    mag = fn(I)
    total_time += time.time() - start_time
    out_file_name = os.path.join(out_dir, str(imname)+'.png')
    cv2.imwrite(out_file_name, mag)
  return total_time / len(imlist)

def load_gt_boundaries(imname):
    gt_path = os.path.join('data', FLAGS.imset, 'groundTruth', '{}.mat'.format(imname))
    return BSDSDataset.load_boundaries(gt_path)

def load_pred(output_dir, imname):
    pred_path = os.path.join(output_dir, '{}.png'.format(imname))
    return img_as_float(imread(pred_path))

def save_results(out_file_name, threshold_results, overall_result, runtime):
  res = np.array(threshold_results)
  recall = res[:,1]
  precision = res[recall>0.01,2]
  recall = recall[recall>0.01]
  threshold = overall_result.threshold
  f1 = overall_result.f1
  best_f1 = overall_result.best_f1
  area_pr = overall_result.area_pr
  np.savez(out_file_name, precision=precision, recall=recall, 
           area_pr=area_pr, best_f1=best_f1, f1=f1, runtime=runtime,
           threshold=threshold)
  return threshold, precision, recall, f1, best_f1, area_pr

def main(_):
  fn = compute_edges_dxdy
  imlist = get_imlist(FLAGS.imset)
  
  output_dir = FLAGS.output_dir
  if not os.path.exists(output_dir):
    os.makedirs(output_dir)
  
  bench_dir = os.path.join(FLAGS.output_dir, 'bench')
  if not os.path.exists(bench_dir):
    os.makedirs(bench_dir)

  print('Running detector:')
  runtime = detect_edges(imlist, fn, bench_dir)

  print('Evaluating:')
  sample_results, threshold_results, overall_result = \
    evaluate_boundaries.pr_evaluation(N_THRESHOLDS, imlist, 
                                      load_gt_boundaries, 
                                      lambda x: load_pred(bench_dir, x),
                                      fast=True, progress=tqdm)
  print('Save results:')
  out_file_name = os.path.join(FLAGS.output_dir, 'metrics.npz')
  threshold, precision, recall, f1, best_f1, area_pr = \
    save_results(out_file_name, threshold_results, overall_result, runtime)
  
  fig = plt.figure(figsize=(6,6))
  ax = fig.gca()
  display_results(ax, FLAGS.output_dir, threshold, precision, recall, f1, best_f1, area_pr)
  print('{:>24s}: {:<10.6f}'.format('runtime (in seconds)', runtime))

  fig.savefig(os.path.join(output_dir + '_pr.pdf'), bbox_inches='tight')
  
if __name__ == '__main__':
  app.run(main)
