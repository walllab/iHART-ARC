#!/bin/bash

AWK="$MAIN/programs/gawk-4.1.4/gawk" # Insert absolute bath to Gawk

#Chr, Position, Ref, Alt, child_id, Info, genotype, genotype_subfields, and subfield_format
cols_list="Chr,Position,Ref,Alt,child_id,Info,genotype,genotype_subfields,subfield_format"

for col in `echo $cols_list | tr ',' '\n'`; do
    pos=`head -n1 $1 | tr "\t" "\n" | grep -wn $col | cut -d: -f1`;
    eval "${col}_pos=$pos";
done;

$AWK -v a=$Chr_pos -v b=$Position_pos -v c=$Ref_pos -v d=$Alt_pos -v e=$child_id_pos -v f=$Info_pos -v g=$genotype_pos -v h=$genotype_subfields_pos -v i=$subfield_format_pos 'BEGIN{FS="\t"; OFS="\t"};
 !/^#/ && !/^chr/ && !/^Chr/ {
    sub(/PAR.*/,"",$1);  # change PAR annotation
    print $a, $b, $c, $d, $e, $i, $g":"$h, $f
 }' $1 > $2
