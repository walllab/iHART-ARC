#This script converts the source ENCODE file from the UCSC Genome Browse 
#into a format that is appropriate for the pipeline. This is done by removing
#commented lines indicating the section of the chromosome from the file. 
#Usage: bash Make_EncodeFile.sh <input: ENCODE file> <output_dir: Output dir>
########################
#Arguments:
#[1] Input File: Absolute path to the ENCODE file
#[2] Output Dir: Absolute path to the output directory for the modified ENCODE file

WigFile=$1;
Output_dir=$2;
if [[ "$Output_Dir" == */ ]]
then
    Output_Dir=${Output_Dir%/}
else
    Output_Dir=$Output_Dir
fi
grep -v "#" $1 > $Output_dir/hg19_EncodeCaltechRnaSeqGm12878R2x75.txt;
