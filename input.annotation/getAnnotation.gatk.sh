#!/bin/bash

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" # Find script path, assuming all scripts are in the same directory
source ${SRC}/setAnnotationEnv.sh $1;

# own FLAT db file has chr, pos, ref, alt, id, format, gt, info

#--- Step 2. GATK  ---------------------------------------------------
O2=${ODIR}/${TAG}.o.gatk       # Updated output file

# AC, AF, MLEAC, MLEAF, ExcessHet will NOT be used in training or testing: removed.
# This function depends on (own) $FLAT and (original) $ABHET files.
function gatk_out() {
    $AWK -v f=$FLAT -v h=$ABHET -v g=$IG_LIST \
        'BEGIN{
          FS="\t"; $OFS="\t";
          while (getline < f) { id=$1"."$2"."$3"."$4"."$5;
                                format[id]=$6; genotype[id]=$7; info[id]=$8;};
          while (getline < h) { abhet[$1"."$2"."$3"."$4] = $NF }; # without sample id
          while (getline < g) { ig_list[$1] = 1 };
          n["Variant_ID"]=1;
          n["SAMPLE_AD_REF"]=2; n["SAMPLE_AD_ALT"]=3; n["SAMPLE_DP"]=4; n["SAMPLE_GQ"]=5; n["SAMPLE_ADDP"]=6; # Store column name/order
          n["DP"]=7; n["ABHet"]=8; n["ABHom"]=9; n["AN"]=10; n["BaseQRankSum"]=11;
          n["FS"]=12; n["InbreedingCoeff"]=13; n["MQ"]=14; n["MQRankSum"]=15;
          n["NDA"]=16; n["NEGATIVE_TRAIN_SITE"]=17; n["OND"]=18;
          n["POSITIVE_TRAIN_SITE"]=19; n["QD"]=20; n["ReadPosRankSum"]=21; n["SOR"]=22; n["VQSLOD"]=23; n["IG"]=24; nc=24;# nc=number of columns
        };
        { split($1,a,"."); id = a[1]"."a[2]"."a[3]"."a[4];
          if (! ($1 in info)) { print "Cannot find "$1            > "/dev/stderr"; exit };
          if (! (id in abhet)){ print "Cannot find "id" in abhet" > "/dev/stderr"; exit };    # ABHet value might not be there
          for (i=1;i<=nc;i++) { o[i] = "NA" };                                                # Set default output values per column

          len=split(info[$1],a,";"); for (x in a) { split(a[x],b,"="); o[n[b[1]]]=b[2] };     # Get variant annotation
          split(genotype[$1],gt,":"); split(format[$1],fmt,":");                              # Split sample annotation, fmt order might vary
          for (x in fmt) {
              switch (fmt[x]) {
                 case "AD":
                    split(gt[x],ad,",");
                    o[n["SAMPLE_AD_REF"]]= ad[1]; o[n["SAMPLE_AD_ALT"]]= ad[2];      # Split AD_REF and AD_ALT
                    o[n["SAMPLE_DP"]]    = ad[1] + ad[2];                            # Set sample DP as AD_REF + AD_ALT, as DP maybe "." in some cases
                    o[n["SAMPLE_ADDP"]]  = ad[2] / (ad[1] + ad[2]); break            # Calculate SAMPLE_AD/DP = SAMPLE_AD_ALT/SAMPLE_DP
                 case "GQ":
                    o[n["SAMPLE_GQ"]]= gt[x]; break;
              }
          }
          if (o[n["POSITIVE_TRAIN_SITE"]]=="NA") { o[n["POSITIVE_TRAIN_SITE"]] = 0 } else { o[n["POSITIVE_TRAIN_SITE"]] = 1 };
          if (o[n["NEGATIVE_TRAIN_SITE"]]=="NA") { o[n["NEGATIVE_TRAIN_SITE"]] = 0 } else { o[n["NEGATIVE_TRAIN_SITE"]] = 1 };
          if (o[n["OND"]]=="NA")                 { o[n["OND"]] = 0 };

          # Update abhet
          if (id in abhet) { o[n["ABHet"]] = abhet[id] };

          # Update VEP info => gene name => IG region variant or not (1/0)
          split(a[len],vep,"|")
          if (length(vep[4])>0 && vep[4] in ig_list) { o[n["IG"]] = 1} else { o[n["IG"]] = 0 };

          printf("%s\t",$1);                                         # Print Variant_ID
          for (i=2;i<nc;i++) { printf("%s\t",o[i]); }; print o[nc];  # Print GATK annotation
          system("");                                                # flush
        }' $1
}

[[ ! -s $O2 ]] && echo2 "$(date "+%T %D") Building GATK output: $(basename $O2)" && gatk_out "$1" > "$O2";

#--- 3. abparts/IG variant counts per sample ------------------------------
O1=${ODIR}/${TAG}.o.anv  && [[ ! -s $O1 ]] && echo2 "Cannot find ANNOVAR output $O1" && exit 1;
O2=${ODIR}/${TAG}.o.gatk && [[ ! -s $O2 ]] && echo2 "Cannot find GATK    output $O2" && exit 1;
O3=${ODIR}/${TAG}.o.ig_ab

# These counts depend on ANNOVAR (step 1) and GATK (step 2) output files.
# "num_vars_in_abparts" will NOT be used in training or testing => removed.
function count_ig_and_abparts() {
    $AWK -v o1=$O1 -v o2=$O2 'BEGIN{ FS="\t"; OFS="\t"
           while (getline < o1) {                  id=$NF;  if ($6 ==1){ ab_count[id]++ } };
           while (getline < o2) { split($1,i,"."); id=i[5]; if ($NF==1){ ig_count[id]++ } };
         };
         { split($1,i,"."); id=i[5];
           num_ig_variants = (id in ig_count)? ig_count[id] : 0;
           num_ab_variants = (id in ab_count)? ab_count[id] : 0;
           print $1, num_ig_variants, num_ab_variants;
         }' $1;
}

[[ ! -s $O3 ]] && echo2 "$(date "+%T %D") Building IG_Abparts_count output: $(basename $O3)" && count_ig_and_abparts "$1" > "$O3";
