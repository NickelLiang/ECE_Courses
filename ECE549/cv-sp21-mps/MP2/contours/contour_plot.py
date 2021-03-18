# Code from Saurabh Gupta
from absl import app, flags
import os, sys, numpy as np, cv2
import matplotlib
matplotlib.use('Agg')
from matplotlib import pyplot as plt

FLAGS = flags.FLAGS
flags.DEFINE_list('dirs', ['output/demo'], 
                  'List of directories to read metrics from')
flags.DEFINE_list('names', ['given-code'], 
                  'Legends')
flags.DEFINE_string('out_file_name', 'plot',
                    'File to save plots to')

def display_results(ax, name, threshold, precision, recall, f1, best_f1, area_pr):
  out_keys = [threshold, f1, best_f1, area_pr]
  out_name = ['threshold', 'overall max F1 score', 'average max F1 score', 'AP']
  for k, n in zip(out_keys, out_name):
    print('{:>24s}: {:<10.6f}'.format(n, k))
  label_str = '[{:0.2f}, {:0.2f}, {:0.2f}] {:s}'.format(
    f1, best_f1, area_pr, name)
  ax.plot(recall, precision, lw=2, label=label_str)
  ax.set_xlim([0,1])
  ax.set_ylim([0,1])
  ax.grid(True)
  ax.legend()
  ax.set_xlabel('Recall')
  ax.set_ylabel('Precision')


def main(_):
  plt.set_cmap('Set2')
  fig = plt.figure(figsize=(6,6))
  ax = fig.gca()
  
  with open(FLAGS.out_file_name + '.txt', 'wt') as f:
    for name, directory in zip(FLAGS.names, FLAGS.dirs):
      print(name)
      data = np.load(os.path.join(directory, 'metrics.npz'))
      display_results(ax, name, data['threshold'], data['precision'],
                      data['recall'], data['f1'], data['best_f1'],
                      data['area_pr'])
      runtime = data['runtime']
      str_ = '== {:>21s}: {:.6f}, {:.6f}, {:<.6f}, {:<.6f}'.format(
        name, data['f1'], data['best_f1'], data['area_pr'], runtime)
      print(str_)
      f.write(str_ + '\n')
  
  fig.savefig(FLAGS.out_file_name + '.pdf', bbox_inches='tight')
  fig.savefig(FLAGS.out_file_name + '.png', bbox_inches='tight')

if __name__ == '__main__':
  app.run(main)
