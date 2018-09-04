#!/bin/bash

TAG=$(basename $1);
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ODIR=$2 #Output directory.

#--- Aliases  --------
echo2() { printf "%s\n" "$*" >&2; }; #Print string to STDERR

#--- Directories, Tools & Files -----------------------------------

MAIN="/ifs/collabs/geschwind"
IHART="$MAIN/NGS/NGS_analyses/iHART_genomes"
PROG="$MAIN/programs"
RDNV="$IHART/RDNVs"
ML="$RDNV/machineLearning_to_distinguish_LCLartifacts"

IG_LIST="$IHART/July2015_Analysis/Human_immunoglobulin_genes_HGNClist.txt" #Absolute path to Human_immunoglobulin_genes_HGNClist.txt file provided in the Annotation_Source_Files directory
GIAB="$MAIN/NGS/resources/Genome_in_a_bottle/Processed_Bed_Files/iHART_prob_genomic_regions_sorted_MERGED_REGIONS_sizes.bed" #Absolute path to Genome_in_a_bottle_problematic_regions.bed file provided in the Annotation_Source_Files directory

ANNOVAR="/usr/local/ActivePerl-5.18.4.1804/bin/perl $PROG/annovar_2015DEC14/table_annovar.pl" #Absolute path path to your preferred perl installation followed by an absolute path to the table_annovar.pl script from ANNOVAR
ANV_DIR="$ML/archive/humandb"; #Absolute path to Annotation_Source_Files directory
AWK="$PROG/gawk-4.1.4/gawk" #Absolute path to Gawk software directory
BED="$PROG/bedtools/bedtools2/bin/bedtools" #Absolute path to BEDTools toolset directory 

REFG="$MAIN/NGS/reference_genome/hs37d5.fa" # Absolute path to Human Reference Genome hs37d5 file

source ${SRC}/data_config.sh