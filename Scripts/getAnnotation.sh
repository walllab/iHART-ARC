#!/bin/bash

INPUT=$1;
OPT=${2:-"train"}; # train, test, or rdnv for now

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" # Find script path, assuming all scripts are in the same directory
ODIR=$3; #Output dir. Added

# Set Annotation data files etc.
source ${SRC}/setAnnotationEnv.sh $1;

# Get intermediate output files
source ${SRC}/getAnnotation.annovar.sh $1;
source ${SRC}/getAnnotation.gatk.sh    $1;
source ${SRC}/getAnnotation.other.sh   $1;

[[ ! -s $O1 ]] && echo2 "Cannot find ANNOVAR output $O1"       && exit 1;
[[ ! -s $O2 ]] && echo2 "Cannot find GATK output $O2"          && exit 1;
[[ ! -s $O3 ]] && echo2 "Cannot find IG/TCR count output $O3"  && exit 1;
[[ ! -s $O4 ]] && echo2 "Cannot find Trinucleotide output $O4" && exit 1;
[[ ! -s $O5 ]] && echo2 "Cannot find GC content output $O5"    && exit 1;
[[ ! -s $O6 ]] && echo2 "Cannot find GIAB output $O6"          && exit 1;
[[ ! -s $O7 ]] && echo2 "Cannot find isNA output $O7"          && exit 1;
[[ ! -s $O8 ]] && echo2 "Cannot find nSNV output $O8"          && exit 1;

# Make output header
OUT=${ODIR}/${TAG}.out;
printf "Variant_ID\tCLASSIFICATION\t" > $OUT;
printf "AbpartsTCR\tDnaseUwdukeGm12878UniPk\tEncodeCaltechRnaSeqGm12878R2x75\tRecombRate\tReplicationTiming\tSimpleRepeat\tRmsk\tSegDups\tTop10multiallelic\t"  >> $OUT; # $O1 = Annovar
printf "SAMPLE_AD_REF\tSAMPLE_AD_ALT\tSAMPLE_DP\tSAMPLE_GQ\tSAMPLE_ADDP\tDP\tABHet\tABHom\tAN\tBaseQRankSum\tFS\tInbreedingCoeff\t"                             >> $OUT; # $O2 = GATK
printf "MQ\tMQRankSum\tNDA\tNEGATIVE_TRAIN_SITE\tOND\tPOSITIVE_TRAIN_SITE\tQD\tReadPosRankSum\tSOR\tVQSLOD\tIG\t"                                               >> $OUT; # $O2 = GATK + IG
printf "Num_vars_in_IG\tNum_vars_in_TCR_abparts\tTrinucleotide_context\tPCT_GC_content_100bp\t"                                                                 >> $OUT; # $O3 $O4 $O5
printf "All.simplerepeatsnocov\tDecoy.bed\tSuperdupsmerged_all_sort\tSystematic.Sequencing.Errors\tVQSRv2.18_filterABQD_sorted\tVQSRv2.18_filterAlign_sorted\t" >> $OUT; # $O6 = GIAB
printf "VQSRv2.18_filterConflicting\tVQSRv2.18_filterlt2Datasets\tVQSRv2.18_filterMap\tVQSRv2.18_filterSSE\tNum_uncertain_regions\t"                            >> $OUT; # $O6 = GIAB
printf "isIndel\tisDnaseNA\tisEncodeNA\tisRecombRateNA\tisReplicationTimingNA\t"                                                                                >> $OUT; # $O7 = isNA
printf "isABHetNA\tisABHomNA\tisBaseQRankSumNA\tisInbreedingNA\tisMQRankSumNA\tisReadPosRankSumNA\tNum_SNV\n"                                                   >> $OUT; # $O7 = isNA, $O8 = nSNV

# Print contents in order
# - Assume Input file ($1) has [Variant_ID, CLASSIFICATION]
paste <(cut -f1-2 $1) <(cut -f6-14 $O1) <(cut -f2- $O2) <(cut -f2- $O3) $O4 $O5 <(cut -f2- $O6) <(cut -f2- $O7) <(cut -f2- $O8) >> $OUT;

# Recalculate per-sample count columns(nIG, nTCR, and nSNV) if needed (when only one TRUE variant of any pair was kept, in training or test input file)
if [[ $OPT == "train" || $OPT == "test" || $OPT == "rdnv" ]]; then
    source ${SRC}/getAnnotation.adjust.perSampleCounts.sh ${OUT} > ${OUT}.adjust && mv ${OUT}.adjust ${OUT};
fi
