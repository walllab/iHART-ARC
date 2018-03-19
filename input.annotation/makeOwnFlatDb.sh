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
    $AWK 'BEGIN{FS="\t"; OFS="\t"};
         !/^#/ && !/^chr/ && !/^Chr/ {
            sub(/PAR.*/,"",$1);  # change PAR annotation
            print $1, $2, $4, $5, $19, $25, $23":"$24, $22
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
