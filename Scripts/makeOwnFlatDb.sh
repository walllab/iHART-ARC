#!/bin/bash
# This script is intended to run on ULCA BMAP servers.

MAIN="/ifs/collabs/geschwind"
RDNV="$MAIN/NGS/NGS_analyses/iHART_genomes/RDNVs";
FLAT="$RDNV/Annotated_FlatFiles_DeNovos_2017-03-04";

FLAT_TRAIN="$FLAT/MZtwins_AllVariants_AbsentInControls/manuscript1.inherited_patterns-counts.noGL.noVQSRfailed.V2.flat_filtered_for_analysis.db";
FLAT_RDNVS="$FLAT/manuscript1.inherited_patterns-counts.noGL.noVQSRfailed.V2.flat_filtered_for_analysis.db"

FLAT_TEST_DIR="$MAIN/NGS/NGS_analyses/iHART_genomes/Transmission_Summary/Manuscript1/2017_04_15_ms1_withLCLs/34_samples"

AWK="$MAIN/programs/gawk-4.1.4/gawk" # Default v3.1.3 doesn't work with switch statement


function make_flat_db_file() {
    $AWK 'BEGIN{FS="\t"; OFS="\t"};
         $21 == "denovo"&& !/^#/ && !/^chr/ && !/^Chr/ {
            sub(/PAR.*/,"",$1);  # change PAR annotation
            print $1, $2, $4, $5, $19, $25, $23":"$24, $22
         }' $1
}

function make_flat_db_file_custom() {
# don't limit to denovos in case we're doing variants in parents...
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
     }' $1
}

case "$1" in
    "train")
        make_flat_db_file $FLAT_TRAIN > ./flat.db.train;
        ;;
    "test")
        echo -n "" > ./flat.db.test;
        for chr in {1..22} X Y; do
            FLAT_TEST="$FLAT_TEST_DIR/Transmission_Summary_ms1_withLCLs.renamePAR.noMULTIALLELIC.noVQSRfailed.flat.chr${chr}_34_samples_annotated_for_analysis.db"
            make_flat_db_file $FLAT_TEST >> ./flat.db.test;
        done
        ;;
    "rdnv")
        make_flat_db_file $FLAT_RDNVS > ./flat.db.rdnv;
        ;;
    "custom_data")
        make_flat_db_file_custom "$2" > "$3"
esac