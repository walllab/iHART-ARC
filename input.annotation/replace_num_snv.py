# -*- coding: utf-8 -*-
"""
Take an annotation.out from Jae's pipeline and replace Num_SNV, Num_vars_in_IG, and Num_vars_in_TCR_abparts
"""

from __future__ import print_function

__author__ = "Lee-kai Wang"

import argparse
from os.path import basename

parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter, description=__doc__)
parser.add_argument('--input', required=True, help='input annotation.out file')
parser.add_argument('--replacement_file', required=True, help='participant_id\tbio_seq_source\tde_novo_snv\tde_novo_ig\tde_novo_tcr')
parser.add_argument('--output_dir', required=True, help='output_dir')
args = parser.parse_args()

output_filename = basename(args.input)
if output_filename.endswith('txt'):
  output_filename = output_filename[:-4]
output_filename += '_replaced.txt'

replacement_dict = dict()
with open(args.replacement_file) as f:
  for l in f:
    participant_id, bio_seq_source, num_snv, ig, tcr = l.strip().split('\t')[:5]
    replacement_dict[participant_id] = (num_snv, ig, tcr)

with open(args.output_dir.rstrip('/') + '/' + output_filename, 'w') as output_filestream:
  with open(args.input) as f:
    for l in f:
      if l.startswith('Variant_ID'):
        output_filestream.write(l)
        continue
      line_list = l.strip().split('\t')
      output_line_list = line_list[:]
      
      variant_id = line_list[0]
      participant_id = variant_id.split('.')[-1]

      if participant_id not in replacement_dict:
        # it's not one of the parents (in this case) that we care about
        continue

      output_line_list[34] = replacement_dict[participant_id][1]
      output_line_list[35] = replacement_dict[participant_id][2]
      output_line_list[60] = replacement_dict[participant_id][0]
      output_filestream.write('\t'.join(output_line_list) + '\n')
