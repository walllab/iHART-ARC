#!/bin/bash

TAG=$(basename $1);
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ODIR=$2 #Output directory.

#--- Aliases  --------
echo2() { printf "%s\n" "$*" >&2; }; #Print string to STDERR

#--- Directories, Tools & Files -----------------------------------

IG_LIST="" #Absolute path to Human_immunoglobulin_genes_HGNClist.txt file provided in the Annotation_Source_Files directory
GIAB="" #Absolute path to Genome_in_a_bottle_problematic_regions.bed file provided in the Annotation_Source_Files directory

ANNOVAR="" #Absolute path path to your preferred perl installation followed by an absolute path to the table_annovar.pl script from ANNOVAR, separated by a space
ANV_DIR=""; #Absolute path to Annotation_Source_Files directory
AWK="" #Absolute path to Gawk software directory
BED="" #Absolute path to BEDTools toolset directory 

REFG="" # Absolute path to Human Reference Genome hs37d5 file

source ${SRC}/data_config.sh
