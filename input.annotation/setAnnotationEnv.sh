#!/bin/bash

TAG=$(basename $1);
ODIR=$(pwd);            # output directory.

#--- Aliases  --------
echo2() { printf "%s\n" "$*" >&2; }; # print string to STDERR

#--- Directories, Tools & Files -----------------------------------
if [[ $(hostname -f) == sh* ]]; then
    SERVER="SHERLOCK"

    IHART="$PI_SCRATCH/DATA/iHART";
    BIN="$PI_HOME/bin";
    REF="$PI_HOME/reference";
    ML="$IHART/ML_input_outputs/test.jjung";

    FLAT_TRAIN="$ML/flat.db.train"
    FLAT_TEST="$ML/flat.db.test"
    FLAT_RDNV="$ML/flat.db.rdnv"

    ABHET_TRAIN="$ML/abhet.train"
    ABHET_TEST="$ML/abhet.test"
    ABHET_RDNV="$ML/abhet.rdnv"

    IG_LIST="$ML/ig_gene.list"
    GIAB="$ML/giab.bed"

    ANNOVAR="$IHART/vcf/annovar.160201/table_annovar.pl"
    ANV_DIR="$IHART/vcf/annovar.160201/humandb";
    AWK="$BIN/awk"
    BED="$BIN/bedtools"
    BCFTOOLS="$BIN/bcftools"
    REFG="$REF/human_g1k_v37.fasta";
else
    SERVER="BMAP";   # UCLA BMAP Server

    MAIN="/ifs/collabs/geschwind"
    IHART="$MAIN/NGS/NGS_analyses/iHART_genomes"
    PROG="$MAIN/programs"
    RDNV="$IHART/RDNVs"
    ML="$RDNV/machineLearning_to_distinguish_LCLartifacts"
    ANNO_DIR="$MAIN/jjung/ms1_RDNV/output/annotation"

    FLAT_TRAIN="$ANNO_DIR/flat.db.train" # built from $RDNV/Annotated_FlatFiles_DeNovos_2017-03-04/MZtwins_AllVariants_AbsentInControls/manuscript1.inherited_patterns-counts.noGL.noVQSRfailed.V2.flat_filtered_for_analysis.db
    FLAT_TEST="$ANNO_DIR/flat.db.test"   # built from $IHART/Transmission_Summary/Manuscript1/2017_04_15_ms1_withLCLs/34_samples/Transmission_Summary_ms1_withLCLs.renamePAR.noMULTIALLELIC.noVQSRfailed.flat.chr*_34_samples_annotated_for_analysis.db
    FLAT_RDNV="$ANNO_DIR/flat.db.rdnv"   # built from $RDNV/Annotated_FlatFiles_DeNovos_2017-03-04/manuscript1.inherited_patterns-counts.noGL.noVQSRfailed.V2.flat_filtered_for_analysis.db

    ABHET_TRAIN="$ANNO_DIR/abhet.train"  # built from $ML/final_training_file/traning_set_variants_with_abhet_recalculation_PARnotrenamed_2017-04-28.txt
    ABHET_TEST="$ANNO_DIR/abhet.test"    # built from $ML/final_test_file/test_set_variants_with_abhet_recalculation_PARnotrenamed_2017-04-28.txt
    ABHET_RDNV="$ANNO_DIR/abhet.rdnv"    # built from $RDNV/Annotated_FlatFiles_DeNovos_2017-03-04/ms1_denovos_with_abhet.txt

    IG_LIST="$IHART/July2015_Analysis/Human_immunoglobulin_genes_HGNClist.txt"
    GIAB="$MAIN/NGS/resources/Genome_in_a_bottle/Processed_Bed_Files/iHART_prob_genomic_regions_sorted_MERGED_REGIONS_sizes.bed"

    ANNOVAR="/usr/local/ActivePerl-5.18.4.1804/bin/perl $PROG/annovar_2015DEC14/table_annovar.pl"
    ANV_DIR="$ML/archive/humandb";
    AWK="$PROG/gawk-4.1.4/gawk"                  # Default v3.1.3 doesn't work with switch statement
    BED="$PROG/bedtools/bedtools2/bin/bedtools"
    BCFTOOLS="$PROG/bcftools/bcftools"
    REFG="$MAIN/NGS/reference_genome/hs37d5.fa"
fi

# Use different $FLAT and $ABHET files per $OPT
case "$OPT" in
    "train")
        FLAT=$FLAT_TRAIN;
        ABHET=$ABHET_TRAIN;
        ;;
    "test")
        FLAT=$FLAT_TEST;
        ABHET=$ABHET_TEST;
        ;;
    "rdnv")
        FLAT=$FLAT_RDNV;
        ABHET=$ABHET_RDNV;
        ;;
    "custom_data")
        source data_config.sh
        ;;
    * )
        echo2 "Option $OPT was not recognized." && exit 1;
        ;;
esac
