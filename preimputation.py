# -*- coding: utf-8 -*-
"""
Do the imputation first (replacing NA with mean), outside the model for memory reasons (for use with large input data sets).
To do: when a column is all NAs, we should consider replacing them with some value (otherwise the classifier may fail).
"""

__author__ = "Lee-kai Wang"

import argparse
from os.path import basename

na_values = ('NA', 'NaN', 'nan')

def is_number(s):
  try:
    float(s)
    return True
  except ValueError:
    return False

class Column(object):
  def __init__(self, column_name):
    self.column_name = column_name
    self.count_values = 0
    self.sum = float(0)
    self.count_na = 0
    self.count_other_values = 0

  def increment(self, field):
    if field in na_values:
      self.count_na += 1
    elif is_number(field):
      self.sum += float(field)
      self.count_values += 1
    else:
      self.count_other_values += 1

  def has_string_values(self):
    return self.count_other_values > 0

  def has_na_values(self):
    return self.count_na > 0

  def requires_imputation(self):
    return self.has_na_values() and not self.has_string_values()

  def get_mean(self):
    if self.count_values == 0:
      return 'NA' # this will cause a crash downstream, but we can't put in 0s either
    return self.sum / self.count_values

parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter, description=__doc__)
parser.add_argument('--input_annotation', required=True, help='input annotation')
parser.add_argument('--output_dir', required=True, help='output dir')
args = parser.parse_args()

output_filename = basename(args.input_annotation)
if output_filename.endswith('.txt'):
  output_filename = output_filename[:-4]
output_filename += '_imputed.txt'

columns = []
with open(args.input_annotation) as f:
  for column_name in f.readline().strip().split('\t'):
    columns.append(Column(column_name))
  for l in f:
    for index, field in enumerate(l.strip().split('\t')):
      columns[index].increment(field)

columns_requiring_imputation = []
columns_with_na_numeric_and_other_mixed_values = []
columns_with_only_missing_values = []

for index, c in enumerate(columns):
  if c.requires_imputation():
    columns_requiring_imputation.append(index)
  if c.has_string_values() and c.has_na_values() and c.sum > 0:
    columns_with_na_numeric_and_other_mixed_values.append(c.column_name)
  if c.requires_imputation() and c.count_values == 0:
    columns_with_only_missing_values.append(index)

if columns_with_na_numeric_and_other_mixed_values:
  assert False, 'WARNING, some columns have mixed values and NAs: ' + ', '.join(columns_with_na_numeric_and_other_mixed_values)

print 'Imputing: ' + ', '.join(columns[index].column_name for index in columns_requiring_imputation)
print 'These columns have only missing values: ' + ', '.join(columns[index].column_name for index in columns_with_only_missing_values)

with open(args.output_dir.rstrip('/') + '/' + output_filename, 'w') as output_filestream:
  with open(args.input_annotation) as f:
    output_filestream.write(f.readline()) # header
    for l in f:
      line_list = l.strip().split('\t')
      for index in columns_requiring_imputation:
        if line_list[index] in na_values:
          line_list[index] = str(columns[index].get_mean())
      output_filestream.write('\t'.join(line_list) + '\n')
