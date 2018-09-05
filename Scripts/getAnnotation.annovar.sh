#!/bin/bash

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" # Find script path, assuming all scripts are in the same directory
source ${SRC}/setAnnotationEnv.sh $1 $2;

#--- Step 1. Annovar ---------------------------------------------------
I1=${ODIR}/${TAG}.i.anv  # Input file for ANNOVAR
O1=${ODIR}/${TAG}.o.anv  # Column updated output file
L1=${ODIR}/${TAG}.l.anv  # ANNOVAR log

function annovar_in() {
#  $AWK -F'_' '{ print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t'$6 }' $1;  # This way will make all deletion variants invalid in Annovar.
   $AWK 'BEGIN{FS="\t"; OFS="\t"}
         { n=split($1,a,".");
           chr=a[1]; sPos=a[2]; ePos=a[2]; ref=a[3]; alt=a[4]; sample_id=a[5];
           if (n != 5) { print "SKIP: "$0 > "/dev/stderr"; next };                             # Skip line if wrong format
           if (length(ref) >1) { sPos+=1; ePos+=(length(ref)-1); ref=substr(ref,2); alt="-" }; # Update deletion
           if (length(alt) >1) { ref="-"; alt=substr(alt,2) };                                 # Update insertion
           print chr, sPos, ePos, ref, alt, sample_id;
          }' $1;
}
function annovar_out() {
   ANV_BED="hg19_abpartsTCR.txt,hg19_DnaseUwdukeGm12878UniPk.txt,hg19_EncodeCaltechRnaSeqGm12878R2x75.txt,hg19_recombRate.txt,hg19_ReplicationTiming.txt,hg19_simpleRepeat.txt,hg19_rmsk.bed,hg19_genomicSuperDups.bed,hg19_top10multiallelic.txt";
   ##CHANGED
   # ANV_OPT="--buildver hg19 --protocol bed,bed,bed,bed,bed,bed,bed,bed,bed --operation r,r,r,r,r,r,r,r,r --nastring NA --out $(pwd)/${TAG} -otherinfo -remove";    # need to include sample id, in order to count abparts per sample, later
   ANV_OPT="--buildver hg19 --protocol bed,bed,bed,bed,bed,bed,bed,bed,bed --operation r,r,r,r,r,r,r,r,r --nastring NA --out ${ODIR}/${TAG} -otherinfo -remove";
   $ANNOVAR $1 $ANV_DIR --bedfile $ANV_BED $ANV_OPT\
             --argument '-colsWanted 4,-colsWanted 4,-colsWanted 4,-colsWanted 4,-colsWanted 4,-colsWanted 4,-colsWanted 4,-colsWanted 4,-colsWanted 4' 2> $L1;  # Use 4th column value (only) in each bed file

   # Above ANNOVAR command will create this intermediate file.
   # T1=$(pwd)/${TAG}.hg19_multianno.txt && [[ ! -s $T1 ]] && echo2 "Cannot find ANNOVAR intermediate file $T1" && exit 1; ##CHANGED
   T1=${ODIR}/${TAG}.hg19_multianno.txt && [[ ! -s $T1 ]] && echo2 "Cannot find ANNOVAR intermediate file $T1" && exit 1;

   $AWK 'BEGIN{ FS="\t"; OFS="\t"};
         function min(l) { gsub(/NA,/,"",l); gsub(/,NA/,"",l); split(l,v,","); m=v[1]; for(x in v){ if(m>v[x]){m=v[x]} }; return m};   # input list may have NA => remove
         function max(l) { gsub(/NA,/,"",l); gsub(/,NA/,"",l); split(l,v,","); m=v[1]; for(x in v){ if(m<v[x]){m=v[x]} }; return m};
         NR==1{ next }; # skip header
         NR >1{ gsub(/Name=/,"");                                     # Remove "Name=" prefix
                if ($6  == "NA") { $6  = 0 } else { $6  = 1 };        # Update abparts output
                if ($7  == "NA") { $7  = 0 } else { $7  = max($7) };  # Get highest DnaseUwdukeGm12878UniPk value
                if ($8  == "NA") { $8  = 0 } else { $8  = max($8) };  # Get highest RnaSeq value
                if ($9  == "NA") { $9  = 0 } else { $9  = max($9) };  # Get highest recombRate value
                if ($11 == "NA") { $11 = 0 } else { $11 = min($11) }; # Get Lowest SimpleRepeat value
                if ($12 == "NA") { $12 = 0 } else { $12 = 1 };        # Update rmsk   - no_rmsk   (0) or any rmsk   (1)
                if ($13 == "NA") { $13 = 0 } else { $13 = 1 };        # Update SegDup - no_segdup (0) or any segdup (1)
                if ($14 == "NA") { $14 = 0 };                         # Update top10multiallelic

                # First five columns are chr,pos1,pos2,ref,alt, and the last column is sample_id
                # But did not try to make Variant_ID back here because one reference base is deleted in INDELs
                print $0;
         }' $T1;

   # Delete intermediate or log file
   /bin/rm $L1 $T1;
}

echo ${ODIR} "this is the directory"
touch "$I1"

[[ ! -s $I1 ]] && echo2 "$(date "+%T %D") Building ANNOVAR input:  $(basename $I1)" && annovar_in  "$1"  > "$I1";
[[ ! -s $O1 ]] && echo2 "$(date "+%T %D") Building ANNOVAR output: $(basename $O1)" && annovar_out "$I1" > "$O1";
