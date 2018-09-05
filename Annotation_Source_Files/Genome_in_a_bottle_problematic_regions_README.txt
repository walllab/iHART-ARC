# E.Ruzzo
# April 18th, 2016

Sites with systematic errors were identified in Goldfeder et al. Genome Medicine (2016). 
	- These sites were hom ref by Genome in a bottle, but had a genotype that was not hom ref by any sequencing platform that had reads containing a variant at this site
	- systematic error if all sequencing datasets from a platform had evidence for an incorrect genotype or if more than two sequencing datasets from a platform had evidence for an incorrect genotype

# Downloaded:
ftp://ftp-trace.ncbi.nlm.nih.gov/giab/ftp/data/NA12878/analysis/NIST_union_callsets_06172013/NISTIntegratedCalls_14datasets_131103_allcall_UGHapMerge_HomRef_VQSRv2.18_all_bias_nouncert_excludesimplerep_excludesegdups_excludedecoy_excludeRepSeqSTRs_noCNVs.vcf.gz

# File info:
header lines = 138 
variant lines = 39301 
variant lines with illumina bias = 39301 


Recommendation: Exclude all variant sites with an Illumina bias. 

## END ##
