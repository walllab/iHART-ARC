#This script converts the source RMSK file from the UCSC genome 
#annotation database into a format that is appropriate for the pipeline. 
#This is done by keeping only necessary columns genoName,genoStart,genoEnd, 
#and repClass (columns 6,7,8, and 12, respectively) from the source RMSK file.
#Usage: bash Make_RMSK.sh <input: RMSK file> <output_dir: Output dir>
########################
#Arguments:
#[1] Input File: Absolute path to the ENCODE file
#[2] Output Dir: Absolute path to the output directory for the modified ENCODE file

RMSKFile=$1;
Output_Dir=$2;
if [[ "$Output_Dir" == */ ]]
then
    Output_Dir=${Output_Dir%/}
else
    Output_Dir=$Output_Dir
fi
awk 'BEGIN{OFS="\t";}{print $6,$7,$8,$12}' $RMSKFile > $Output_Dir/hg19_rmsk.bed;