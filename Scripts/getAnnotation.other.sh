#!/bin/bash

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" # Find script path, assuming all scripts are in the same directory
source ${SRC}/setAnnotationEnv.sh $1 $2;

#--- 4. Trinucleotide  ---------------------------------------------------
I4=${ODIR}/${TAG}.i.tri
O4=${ODIR}/${TAG}.o.tri

function tri_in() {
    $AWK -F'.' '{ print $1"\t"($2 -2)"\t"($2 +1) }' $1;
}
function tri_out() {
    $BED getfasta -fi $REFG -bed $1  -tab -fo stdout |\
        $AWK 'BEGIN{ FS="\t" };   # Convert 64 trinucleotide categories into 32
              { tri = $2;
                switch ($2) {
                   case "GAA": tri= "CTT"; break
                   case "GAC": tri= "CTG"; break
                   case "GAG": tri= "CTC"; break
                   case "GAT": tri= "CTA"; break
                   case "GCA": tri= "CGT"; break
                   case "GCC": tri= "CGG"; break
                   case "GCG": tri= "CGC"; break
                   case "GCT": tri= "CGA"; break
                   case "GGA": tri= "CCT"; break
                   case "GGC": tri= "CCG"; break
                   case "GGG": tri= "CCC"; break
                   case "GGT": tri= "CCA"; break
                   case "GTA": tri= "CAT"; break
                   case "GTC": tri= "CAG"; break
                   case "GTG": tri= "CAC"; break
                   case "GTT": tri= "CAA"; break
                   case "TAA": tri= "ATT"; break
                   case "TAC": tri= "ATG"; break
                   case "TAG": tri= "ATC"; break
                   case "TAT": tri= "ATA"; break
                   case "TCA": tri= "AGT"; break
                   case "TCC": tri= "AGG"; break
                   case "TCG": tri= "AGC"; break
                   case "TCT": tri= "AGA"; break
                   case "TGA": tri= "ACT"; break
                   case "TGC": tri= "ACG"; break
                   case "TGG": tri= "ACC"; break
                   case "TGT": tri= "ACA"; break
                   case "TTA": tri= "AAT"; break
                   case "TTC": tri= "AAG"; break
                   case "TTG": tri= "AAC"; break
                   case "TTT": tri= "AAA"; break
                 }
                 print tri;  # No Variant_ID but ordered
              }';
}

[[ ! -s $I4 ]] && echo2 "$(date "+%T %D") Building Trinucleotide input:  $(basename $I4)"  && tri_in  "$1"  > "$I4";
[[ ! -s $O4 ]] && echo2 "$(date "+%T %D") Building Trinucleotide output: $(basename $O4)"  && tri_out "$I4" > "$O4";

#--- 5. GC content     ---------------------------------------------------
I5=${ODIR}/${TAG}.i.gc
O5=${ODIR}/${TAG}.o.gc

function gc_content_in() {
    $AWK -F'.' '{ print $1"\t"($2 -51)"\t"($2 +50) }' $1;
}
function gc_content_out() {
    $BED nuc -fi $REFG -bed $1 | $AWK -F'\t' 'NR>1{ print $5 }';  # This 'bedtools nuc' output comes with a header label => skip. $5 == "5_pct_gc"
}

[[ ! -s $I5 ]] && echo2 "$(date "+%T %D") Building GC_content input:  $(basename $I5)" && gc_content_in  "$1"  > "$I5";
[[ ! -s $O5 ]] && echo2 "$(date "+%T %D") Building GC_content output: $(basename $O5)" && gc_content_out "$I5" > "$O5";


#--- 6. GIAB features -----------------------
I6=${ODIR}/${TAG}.i.giab
O6=${ODIR}/${TAG}.o.giab

function giab_in() {
    $AWK -F'.' '{ print $1"\t"$2 -1"\t"$2 }' $1;  # change into bed
}
function giab_out() {
   T6=${ODIR}/${TAG}.t.giab;

   # Example output of $BED intersect:
   # X 2698767 2698768 X 2118238 2736927 All.simplerepeatsnocov,VQSRv2.18_filterABQD_sorted,VQSRv2.18_filterAlign_sorted,VQSRv2.18_filterConflicting,VQSRv2.18_filterMap,VQSRv2.18_filterSSE,VQSRv2.18_filterlt2Datasets,superdupsmerged_all_sort 618689
   $BED intersect -a $1 -b $GIAB -wb | cut -f 1,3,7 |\
        $AWK 'BEGIN{ FS="\t"; OFS="\t";
                     n["All.simplerepeatsnocov"]=1; n["decoy.bed"]=2; n["superdupsmerged_all_sort"]=3;
                     n["Systematic.Sequencing.Errors"]=4; n["VQSRv2.18_filterABQD_sorted"]=5;
                     n["VQSRv2.18_filterAlign_sorted"]=6; n["VQSRv2.18_filterConflicting"]=7;
                     n["VQSRv2.18_filterlt2Datasets"]=8;  n["VQSRv2.18_filterMap"]=9;
                     n["VQSRv2.18_filterSSE"]=10;
              };
              {  chr=$1; pos=$2; id=chr"."pos; giab=$3;
                 for (i=1; i<=10; i++) { out[i]=0 };  # output is 0/1
                 tot = split(giab, fn, ",");          # $3 has GIAB annotation list in CSV
                 for(x in fn){ out[ n[fn[x]] ]=1 };   # Mark annotated names in position
                 printf("%s\t", id);
                 for (i=1; i<=10; i++) { printf("%d ", out[i]) }; print tot;  # Note total at the end
               }' > $T6;

    $AWK -v f=$T6 'BEGIN{ FS="\t"; OFS="\t";
                      while (getline < f) { giab[$1] = $2 };  # note FS is tab, not space
                   };
                   { chr=$1; sPos=$2; ePos=$3; id=chr"."ePos; # from $I6, not $INPUT
                     str = "0 0 0 0 0 0 0 0 0 0 0";
                     if (id in giab) { str = giab[id] };
                     print id, str;
                   }' $1 | tr ' ' '\t';

    # remove temporary file
    /bin/rm -rf $T6;
}

[[ ! -s $I6 ]] && echo2 "$(date "+%T %D") Building GIAB input:  $(basename $I6)" && giab_in  "$1"  > "$I6";
[[ ! -s $O6 ]] && echo2 "$(date "+%T %D") Building GIAB output: $(basename $O6)" && giab_out "$I6" > "$O6";

#--- 7. isNA features -----------------------
O1=${ODIR}/${TAG}.o.anv  && [[ ! -s $O1 ]] && echo2 "Cannot find ANNOVAR output $O1" && exit 1;
O2=${ODIR}/${TAG}.o.gatk && [[ ! -s $O2 ]] && echo2 "Cannot find GATK    output $O2" && exit 1;
O7=${ODIR}/${TAG}.o.isNA

# These features depend on ANNOVAR and GATK outputs:
#          1          2                       3                               4          5                 6            7    8       9                 10
# ANNOVAR: AbpartsTCR DnaseUwdukeGm12878UniPk EncodeCaltechRnaSeqGm12878R2x75 RecombRate ReplicationTiming SimpleRepeat Rmsk SegDups Top10multiallelic SAMPLE_ID (col. 6-15)
#       11         12            13            14        15        16          17 18    19    20 21           22 23              24 25
# GATK: VARIANT_ID SAMPLE_AD_REF SAMPLE_AD_ALT SAMPLE_DP SAMPLE_GQ SAMPLE_ADDP DP ABHet ABHom AN BaseQRankSum FS InbreedingCoeff MQ MQRankSum
#       26  27                  28  29                  30 31             32  33     34
#       NDA NEGATIVE_TRAIN_SITE OND POSITIVE_TRAIN_SITE QD ReadPosRankSum SOR VQSLOD IG

function isNA_out() {
    $AWK 'BEGIN{ FS="\t"; OFS="\t" };
          {  id = $11;
             isIndel=0; isDnaseNA=0; isEncodeNA=0; isRecombRateNA=0; isReplicationTimingNA=0; isABHetNA=0; isABHomNA=0; isBaseQRankSumNA=0; isInbreedingNA=0; isMQRankSumNA=0; isReadPosRankSumNA=0;
             split(id, a, "."); if (length(a[3])!=length(a[4])) { isIndel = 1 };
             if (a[5] != $10) { printf("Annovar and Gatk output sample id mismatch: %s vs. %s\n", $10, a[5]) > "/dev/stderr"; exit 1 };
             if ($2  == "NA") { isDnaseNA             = 1 };
             if ($3  == "NA") { isEncodeNA            = 1 };
             if ($4  == "NA") { isRecombRateNA        = 1 };
             if ($5  == "NA") { isReplicationTimingNA = 1 };
             if ($18 == "NA") { isABHetNA             = 1 };
             if ($19 == "NA") { isABHomNA             = 1 };
             if ($21 == "NA") { isBaseQRankSumNA      = 1 };
             if ($23 == "NA") { isInbreedingNA        = 1 };
             if ($25 == "NA") { isMQRankSumNA         = 1 };
             if ($31 == "NA") { isReadPosRankSumNA    = 1 };
             print id, isIndel, isDnaseNA, isEncodeNA, isRecombRateNA, isReplicationTimingNA, isABHetNA, isABHomNA, isBaseQRankSumNA, isInbreedingNA, isMQRankSumNA, isReadPosRankSumNA;
          }' <(paste <(cut -f6-15 $O1) $O2);
}

[[ ! -s $O7 ]] && echo2 "$(date "+%T %D") Building isNA output: $(basename $O7)" && isNA_out "$1" > "$O7";

#--- 8. nSNV features -----------------------
O8=${ODIR}/${TAG}.o.nSNV

# Count number of SNVs per sample, without considering twin pairs or TRUE variants yet.
function nSNV_out() {
    $AWK 'BEGIN{ FS="\t"; OFS="\t" };
          NR==FNR { split($1, a, "."); id=a[5];             # 1st read - count
            if (!(id in nSNV)) { nSNV[id] = 0 };
            if (length(a[3])==length(a[4])) { nSNV[id]++ };
          };
          NR!=FNR { split($1, a, "."); id=a[5];             # 2nd read - print
            print $1, nSNV[id];
          }' $1 $1
}

[[ ! -s $O8 ]] && echo2 "$(date "+%T %D") Building nSNV output: $(basename $O8)" && nSNV_out "$1" > "$O8";
