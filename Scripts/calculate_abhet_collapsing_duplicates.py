#!/usr/bin/env python
"""
Recalculate ABHet manually and collapse duplicate samples (e.g. WB/LCL or MZ_twin pairs if and only if concordant).
"""
# (c) Lee-kai Wang 2017-03-29

from __future__ import print_function
import argparse
from os.path import basename
from collections import defaultdict
from itertools import compress

def get_gatk_abhet_from_info_field(info_field):
  info_dict = dict()
  for i in info_field.split(';'):
    info_dict[i.split('=')[0]] = i.split('=')[-1]
  return info_dict.get('ABHet')

def get_manual_abhet_from_genotypes(fmt_field, genotypes):
  fmt_list = fmt_field.split(':')
  ad_index = fmt_list.index('AD')
  gq_index = fmt_list.index('GQ')
  dp_index = fmt_list.index('DP')

  ratioHom = 0.0
  ratioHet = 0.0
  weightHom = 0.0
  weightHet = 0.0
  overallNonDipoid = 0.0
  size = len(genotypes)

  for i in genotypes:
    genotype = i.split(':')[0]
    if genotype != './.':
      ad = i.split(':')[ad_index]
      gq = i.split(':')[gq_index]
      dp = i.split(':')[dp_index]

      counts = [int(x) for x in ad.split(',')]
      if counts == []:
        continue

      n_allele = len(counts)
      count_sum = sum(counts)
      pTrue = 1.0 - 10.0 ** (-float(gq)/float(10));

      if genotype in ('0/1', '1/0'):
        otherCount = count_sum - counts[0] - counts[1]
        if counts[0] + counts[1] == 0:
          continue
        ratioHet += pTrue*float(counts[0])/(counts[0] + counts[1])
        weightHet += pTrue
        overallNonDipoid += float(otherCount)/(float(count_sum * size))

      if genotype in ('0/0', '1/1'):
        alleleIdx = (0 if genotype == '0/0' else 1)
        alleleCount = counts[alleleIdx]
        bestOtherCount = 0
        for index, count in enumerate(counts):
          if index == alleleIdx:
            continue
          if count > bestOtherCount:
            bestOtherCount = count
        otherCount = count_sum - alleleCount

        # if 0 in (counts[:2]):
        #   continue

        if alleleCount + bestOtherCount == 0:
          pass
          # print('warning, allele count is 0 in genotype:', i)
        else:
          ratioHom += pTrue*float(alleleCount)/(alleleCount + bestOtherCount)
          weightHom += pTrue
          overallNonDipoid += float(otherCount)/(float(count_sum * size))

  if weightHet != 0:
    return "{0:.3f}".format(ratioHet/weightHet)
  else:
    return 'NA'

def get_manual_abhet_from_genotypes_without_samples(fmt, genotypes, header_sample_list, samples_to_exclude):
  inclusion_mask = [i not in samples_to_exclude for i in header_sample_list]
  return get_manual_abhet_from_genotypes(fmt, list(compress(genotypes, inclusion_mask)))

parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter, description=__doc__)
parser.add_argument('--variants', help='tab separated: chrom, pos, ref, alt, comma-separated list of TRUE samples. If empty, will use all variants in VCF and exclude no samples')
parser.add_argument('--vcf', required=True, help='vcf from which to calculate abhet')
parser.add_argument('--samples_to_exclude_when_true', help="list of samples (e.g. WB or MZ_twin) to exclude when concordant = TRUE")
parser.add_argument('--output_dir', required=True, help='output dir')
args = parser.parse_args()

if args.variants:
  output_filename = basename(args.variants)
else:
  output_filename = basename(args.vcf)

if output_filename.endswith('.txt') or output_filename.endswith('.vcf'):
  output_filename = output_filename[:-4]
output_filename += '_with_abhet_recalculation.txt'

samples_to_exclude_when_true = set()
if args.samples_to_exclude_when_true:
  with open(args.samples_to_exclude_when_true) as f:
    for l in f:
      samples_to_exclude_when_true.add(l.strip())

variant_dict = dict()
if args.variants:
  with open(args.variants) as f:
    for l in f:
      chrom, pos, ref, alt, sample_string = l.strip('\n').split('\t')
      if chrom.startswith('X') or chrom.startswith('Y'):
        chrom = chrom[0]
      variant_dict['_'.join((chrom, pos, ref, alt))] = sample_string.split(',') # list of TRUE samples

with open(args.output_dir.rstrip('/') + '/' + output_filename, 'w') as output_filestream:
  output_filestream.write('\t'.join(['chr', 'pos', 'snp_id', 'ref', 'alt', 'gatk_abhet', 'manual_abhet', 'samples_excluded', 'adjusted_abhet']) + '\n')
  with open(args.vcf) as f:
    for l in f:
      line_list = l.strip('\n').split('\t')
      if l.startswith('#'):
        if l.startswith('#CHR'):
          header_sample_list = line_list[9:]
        continue
      chrom, pos, snp_id, ref, alt = line_list[:5]
      if chrom.startswith('X') or chrom.startswith('Y'):
        chrom = chrom[0]
      variant_key = '_'.join((chrom, pos, ref, alt))

      if variant_dict:
        if variant_key not in variant_dict:
          continue
        # exclude samples if they are concordant, only if they are in our predesignated list (we have chosen to exclude WB or MZ_twin of proband)
        concordant_samples = variant_dict[variant_key]
        samples_to_exclude = sorted(samples_to_exclude_when_true.intersection(concordant_samples))
      else:
        samples_to_exclude = []

      info_field = line_list[7]
      fmt_field = line_list[8]
      genotypes = line_list[9:]

      gatk_abhet = get_gatk_abhet_from_info_field(info_field)
      manual_abhet = get_manual_abhet_from_genotypes(fmt_field, genotypes)
      adjusted_abhet = get_manual_abhet_from_genotypes_without_samples(fmt_field, genotypes, header_sample_list, samples_to_exclude)
      output_filestream.write('\t'.join([chrom, pos, snp_id, ref, alt, gatk_abhet if gatk_abhet else 'None', manual_abhet, ','.join(samples_to_exclude) if samples_to_exclude else 'NA', adjusted_abhet]) + '\n')
