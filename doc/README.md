### How to run the classifier on a new data set (using an existing classification model):

**Required inputs:**
1) Annotated transmission summary file of your RDNVs.
    - *Note: the pipeline does not support periods in child_id, so remove these at this step and manually add back to final result if needed.*
2) Recalculated ABHet file for your RDNVs. If you have a VCF trimmed down to your RDNV regions*, use: bmap_scripts/get_allele_balance/calculate_abhet_collapsing_duplicates.py --vcf <vcf> --output_dir <output_dir>. The pipeline expects this to be "unrenamed PAR", i.e. chromosomes should look like X and Y. If this needs adjusting, can potentially put it into `makeOwnAbHetFile.sh`.

**Annotation pipeline (genomeTools/ML/input.annotation):**
Steps 1-3 below convert files into a new format required by the pipeline scripts.
1) Make a version of the reference flat file that the pipeline understands.
    - bash makeOwnFlatDb.sh custom_data <input: standard flat file> <output: pipeline-specific flat file>
2) Make an annotation input that the pipeline understands
    - bash makeAnnotationInputFileFromOwnFlatDb.sh <input: pipeline-specific flat file> <output: annotation input file>
3) Make a version of the ABHet file that the pipeline understands.
    - bash makeOwnABHetFile.sh <input: ABHet file with 9 columns and header> <output: pipeline-specific ABHet file>
4) Put the paths to your pipeline-specific flat file (output of #1 above) and pipeline-specific ABHet file (output of #3 above) into the file data_config.sh.
5) Run the annotation pipeline. This produces many intermediate files as well as a final .out file in your working directory.
    - bash getAnnotation.sh <input: annotation input file (output of #2 above)> custom_data
    (The literal string "custom_data" tells the pipeline to use this mode.)
    - When this is finished running, I like to move all these data files into a separate directory for my project (instead of where all of the bash scripts live).

**Classification pipeline (genomeTools/ML):**
1) Move the RFmodel.pickle.gz for your existing model into the working directory of the Python scripts.
2) Run** python testRF.py <input: .out file from annotation pipeline> <output: RDNV classification>
    - **NB**: Running this on a large number of variants (> 100000?) can potentially crash your computer. One time we brought down the BMAP master node (cerebro-mp2) by doing this. If you think this might be an issue for you, use the `preimputation.py` script first and then run the above command with the `skip_imputation` argument.
3) You may wish to recombine your classification output file with a file that has variant ids in it.

----

*In case it helps, here are some tips on how I subset my VCFs to just the RDNV regions:

1) First I create a regions file to use with bcftools (tail -n +3 because my file had 2 header lines – your needs my vary; then use sed to unrename PAR because I am expecting to use bgzipped and tabixed VCFs in the next step): `cut -f -2 RDNV_flat_filtered_for_analysis.db | tail -n +3 | sed 's/^\(.\)PAR[12]\{0,1\}/\1/' > regions_unrenamed_PAR.txt`

2) Then use bcftools with the regions file to subset the gzipped VCFs, e.g. /ifs/collabs/geschwind/NGS/NGS_analyses/ACE_844/Thu_Feb_2_2017/Annotated_VCFs/2018-01-16/RDNVs/subset_to_RDNVs.sh

3) Then combine to one VCF (GATK CatVariants works), e.g. /ifs/collabs/geschwind/NGS/NGS_analyses/ACE_844/Thu_Feb_2_2017/Annotated_VCFs/2018-01-16/RDNVs/catvariants.sh

----

**As it stands, the sklearn.preprocessing.Imputer used by this script automatically drops columns when 100% of the values are missing (e.g. `ValueError: Length mismatch: Expected axis has 47 elements, new values have 49 elements`). It also struggles and will crash your machine if the input file is really big (not a problem when we were doing RDNVs, but a problem when we were doing Variants in Parents). If you run into this issue, use `preimputation.py` and then run testRF.py with the additional final argument `skip_imputation`.
