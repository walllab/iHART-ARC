#!/bin/bash

# Recalculate nIG, nTCR, and nSNV: need to read whole input file twice to calculate them correctly.

# Count number of IG, AbpartsTCR, and SNV in TRUE calls per familly, then add per sample FALSE calls
awk 'BEGIN{ FS="\t"; OFS="\t" };
      NR==FNR{                    # 1st-read: count
        if (FNR==1) {
          for (i=1; i<=NF; i++) {
               if (toupper($i) == "ABPARTSTCR")     { aIdx = i }; # find index for raw features
               if (toupper($i) == "CLASSIFICATION") { cIdx = i };
               if (toupper($i) == "IG")             { iIdx = i };
          }
        }
        else {
            split($1,a,"."); iid=a[5]; fid=substr(iid,1,6);           # iid= individual id and fid= family id
            if (!(fid in nSNV_true)) {
               nSNV_true [fid]=0; nAB_true [fid]=0; nIG_true [fid]=0; # init arrays
               nSNV_false[iid]=0; nAB_false[iid]=0; nIG_false[iid]=0;
            };
            if ($(cIdx)=="TRUE") {
               if (length(a[3])==length(a[4])) { nSNV_true[fid]++ };  # TRUE calls = apply to all members in the family
               if ($(aIdx) !=0)                {  nAB_true[fid]++ };
               if ($(iIdx) !=0)                {  nIG_true[fid]++ };
            }
            else {
               if (length(a[3])==length(a[4])) { nSNV_false[iid]++ }; # FALSE calls = specific to the individual
               if ($(aIdx) !=0)                {  nAB_false[iid]++ };
               if ($(iIdx) !=0)                {  nIG_false[iid]++ };
            };
        };
     };
     NR!=FNR{                      # 2nd-read: print
        if (FNR==1) {
          for (i=1; i<=NF; i++) {
               if (toupper($i) == "NUM_VARS_IN_TCR_ABPARTS") { aIdx = i }; # find index for sample-wise count
               if (toupper($i) == "NUM_VARS_IN_IG")          { iIdx = i };
               if (toupper($i) == "NUM_SNV")                 { sIdx = i };
          }
          print $0;
        }
        else {
             split($1,a,"."); iid=a[5]; fid=substr(iid,1,6);
             $(aIdx) =  nAB_true[fid] +  nAB_false[iid];      # update counts
             $(iIdx) =  nIG_true[fid] +  nIG_false[iid];
             $(sIdx) = nSNV_true[fid] + nSNV_false[iid];
             print $0;
         }
     }' $1 $1
