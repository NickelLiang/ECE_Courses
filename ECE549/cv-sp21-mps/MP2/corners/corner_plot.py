# Code from Saurabh Gupta
from absl import app, flags
import os, sys, numpy as np, cv2
import matplotlib
matplotlib.use('Agg')
from matplotlib import pyplot as plt

FLAGS = flags.FLAGS
flags.DEFINE_list("dirs", ["output/demo"], 
                  "List of directories to read metrics from")
flags.DEFINE_list("names", ["demo"], 
                  "Legends")
flags.DEFINE_string("out_file_name", "plot",
                    "File to save plots to")

def display_results(ax, name, precision, recall, ap):
  label_string ='[{:0.2f}] {:s}'.format(ap, name)
  ax.plot(recall, precision, lw=2, label=label_string) 
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
      data = np.load(os.path.join(directory, 'metrics.npz'))
      display_results(ax, name, data['precision'], data['recall'], data['ap'])
      ap = data['ap']
      runtime = data['runtime']
      print('{:>20s}: {:<10.6f}, {:<10.6f}'.format(name, ap, runtime))
      f.write('{:>20s}: {:<10.6f} {:<10.6f}\n'.format(name, ap, runtime))
  
  fig.savefig(FLAGS.out_file_name + '.pdf', bbox_inches='tight')
  fig.savefig(FLAGS.out_file_name + '.png', bbox_inches='tight')

if __name__ == '__main__':
  app.run(main)
