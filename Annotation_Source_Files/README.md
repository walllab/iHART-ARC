# Annotation Source Files README <br>

**File:** Human_immunoglobulin_genes_HGNClist.txt <br>
**Feature Name(s):** (1) Number of IG variants, (2) Immunoglobulin genes (IG) <br>
**Description:** <br>
(1)	Number of variants per sample that fall within immunoglobulin genes <br>
(2)	Binary variable indicating that a variant falls within an immunoglobulin gene <br>
**Source:** <br>
http://imgt.org/genedb/GENElect?query=4.2+&species=Homo+sapiens <br>

**File:** hg19_abpartsTCR.txt <br>
**Feature Name(s):** (1) Number of antibody parts and TCR variants, (2) Antibody parts and T cell receptor genes <br>
**Description:** <br>
(1)	Number of variants per sample that fall within regions subject to somatic V(D)J recombination (parts of antibodies and T cell receptor genes) <br>
(2)	Binary variable indicating that a variant falls within a region subject to somatic V(D)J recombination (parts of antibodies and T cell receptor genes) <br>
**Source:** <br>
http://bit.ly/1PDkVPQ (PMID:27018473, Web Resources) <br>

**File:** hg19_recombRate.txt <br>
**Feature Name(s):** Recombination rate <br>
**Description:** <br>
Sex-averaged recombination rate based on the deCODE genetic map <br>
**Source:** UCSC Genome Browser <br>
http://rohsdb.cmb.usc.edu/GBshape/cgi-bin/hgTables?db=hg19&hgta_group=map&hgta_track=recombRate&hgta_table=recombRate&hgta_doSchema=describe+table+schema <br>

**File:** hg19_simpleRepeat.txt <br>
**Feature Name(s):** Simple repeats <br>
**Description:** <br>
Entropy based on base composition of simple tandem repeats located by Tandem Repeats Finder <br>
**Source:** UCSC Genome Browser <br>
http://rohsdb.cmb.usc.edu/GBshape/cgi-bin/hgTables?db=hg19&hgta_group=map&hgta_track=simpleRepeat&hgta_table=simpleRepeat&hgta_doSchema=describe+table+schema <br>

**File:** hg19_top10multiallelic.txt <br>
**Feature Name(s):** Highly multiallelic regions <br>
**Description:** <br>
Frequency of multi-allelic sites in ExAC per kbp region, for the top ten most multi-allelic regions <br>
**Source:** <br>
https://macarthurlab.org/2016/03/17/reproduce-all-the-figures-a-users-guide-to-exac-part-2/#multi-allelic-enriched-regions <br>

**File:** hg19_DnaseUwdukeGm12878UniPk.txt <br>
**Feature Name(s):** DNase hypersensitivity <br>
**Description:** <br>
Average signal enrichment for ENCODE/Analysis GM12878 DNase I hypersensitivity peaks <br>
**Source:** UCSC Genome Browser <br>
http://rohsdb.cmb.usc.edu/GBshape/cgi-bin/hgTables?db=hg19&hgta_group=map&hgta_track=wgEncodeAwgDnaseUwdukeGm12878UniPk&hgta_table=wgEncodeAwgDnaseUwdukeGm12878UniPk&hgta_doSchema=describe+table+schema <br>

**File:** hg19_ReplicationTiming.txt <br>
**Feature Name(s):** Replication timing <br>
**Description:** <br>
DNA replication timing (the ratio of sequencing read depths from S- and G1-phase cells; z-score units) <br>
**Source:** <br>
http://mccarrolllab.com/wp-content/uploads/2015/03/Koren-et-al-Table-S2.zip <br>

**File:** hg19_genomicSuperDups.bed <br>
**Feature Name(s):** Segmental duplications <br>
**Description:** <br>
Binary variable indicating that the variant intersects a Segmental Dups sequence <br>
**Source:** UCSC Genome Browser <br>
http://rohsdb.cmb.usc.edu/GBshape/cgi-bin/hgTables?db=hg19&hgta_group=map&hgta_track=genomicSuperDups&hgta_table=genomicSuperDups&hgta_doSchema=describe+table+schema <br>

**File:** hg19_rmsk.bed <br>
**Feature Name(s):** Repeat masker <br>
**Description:** <br>
Binary variable indicating that the variant intersects a RepeatMasker sequence <br>
**Source:** UCSC Genome Browser <br>
http://rohsdb.cmb.usc.edu/GBshape/cgi-bin/hgTables?%20db=hg19&hgta_group=map&hgta_track=rmsk&hgta_table=rmsk&hgta_doSchema=describe+table+schema <br>

**File:** hg19_EncodeCaltechRnaSeqGm12878R2x75.txt <br>
**Feature Name(s):** Transcription in LCL <br>
**Description:** <br>
Signal from ENCODE/Caltech GM12878 RNA-seq <br>
**Source:** UCSC Genome Browser <br>
## Detailed List of Annotations
Below is a table providing the ranking, name, metric type, description, and source of each variant annotation. <br>

| RFECV_Ranking| Current figure name| Metric type| Description| Reference|
| --- | --- | --- | --- | --- |
| 1| Number of de novo (DN) SNVs| Sample| Number of rare de novo single nucleotide variants called in this sample| "De novo single nucleotide variants identified, as described in ""Inheritance classifications"" (Methods), and absent in the publicly available databases, UCLA internal controls, and Healthy Non-Phaseable (HNP) samples (Methods). "|
| 1| Sample ALT AD to DP ratio| Variant by sample| Ratio of alt allele depth to total depth in this sample| GATK|
| 1| ABHet| Variant by cohort| Ratio of ref allele reads to all reads, heterozygotes only| GATK|
| 1| Quality by depth (QD)| Variant by cohort| Ratio of GATK QUAL score to total depth among samples having the alt allele| GATK|
| 2| Variant quality (VQSLOD)| Variant by cohort| Log odds of being a true variant under GATK's VQSR model| GATK|
| 3| Alternate allele depth (ALT AD)| Variant by sample| Number of reads supporting the alt allele in this sample| GATK|
| 4| Mapping quality rank sum| Variant by cohort| Mann-Whitney U-based z-score for the difference in mapping quality between ref and alt reads| GATK|
| 5| Read position rank sum| Variant by cohort| Mann-Whitney U-based z-score for the difference in read position between ref and alt reads| GATK|
| 6| Number of antibody parts and TCR variants| Sample| Number of variants in regions subject to somatic V(D)J recombination in this sample| http://bit.ly/1PDkVPQ (PMID:27018473, Web Resources)|
| 7| Depth (DP)| Variant by cohort| Total number of reads supporting the reported alleles| GATK|
| 8| Reference allele depth| Variant by sample| Number of unfiltered reads supporting the ref allele in this sample| GATK|
| 9| Base quality rank sum| Variant by cohort| Mann-Whitney U-based z-score for the difference in base quality between ref and alt reads| GATK|
| 10| Number of IG variants| Sample| Number of variants in regions part of immunoglobulin genes in this sample| http://imgt.org/genedb/GENElect?query=4.2+&species=Homo+sapiens|
| 11| Strand bias (SOR)| Variant by cohort| Strand bias estimated by the Symmetric Odds Ratio test| GATK|
| 12| Immunoglobulin genes (IG)| Genome| Binary variable indicating that the region is part of an immunoglobulin gene| http://imgt.org/genedb/GENElect?query=4.2+&species=Homo+sapiens|
| 13| Antibody parts and T cell receptor genes| Genome| Binary variable indicating that the region is subject to somatic V(D)J recombination| http://bit.ly/1PDkVPQ (PMID:27018473, Web Resources)|
| 14| Recombination rate| Genome| Sex-averaged recombination rate based on the deCODE genetic map| UCSC Genome Browser (http://rohsdb.cmb.usc.edu/GBshape/cgi-bin/hgTables?db=hg19&hgta_group=map&hgta_track=recombRate&hgta_table=recombRate&hgta_doSchema=describe+table+schema)|
| 15| Sample depth (DP)| Variant by sample| Number of reads supporting the reported alleles in this sample| GATK|
| 16| GC content| Genome| Proportion of GC content (50 bp upstream and 50 bp downstream the variant site)| custom (bedtools nuc)|
| 17| Strand bias (FS)| Variant by cohort| Strand bias estimated using Fisher's Exact Test| GATK|
| 18| Trinucleotide context| Genome| Strand-normalized trinucleotide context of the variant's start position| custom (bedtools getfasta)|
| 19| Inbreeding coefficient| Variant by cohort| Inbreeding coefficient estimated from comparison against Hardy-Weinberg equilibrium| GATK|
| 20| ABHet is NA| Variant by cohort| Binary variable indicating that the given feature is N/A| -|
| 21| Mapping quality| Variant by cohort| Root mean square of the mapping quality of all informative reads| GATK|
| 22| Allele number (AN)| Variant by cohort| Total number of alleles in called genotypes| GATK|
| 23| Is Indel| Variant by cohort| Binary variable indicating that the variant is an indel| GATK|
| 24| ABHom| Variant by cohort| Ratio of ref or alt allele reads to all reads, homozygotes only| GATK|
| 25| Transcription in LCL| Genome| Signal from ENCODE/Caltech GM12878 RNA-seq| UCSC Genome Browser (http://rohsdb.cmb.usc.edu/GBshape/cgi-bin/hgTables?db=hg19&hgta_group=map&hgta_track=wgEncodeCaltechRnaSeqGm12878R2x75Th1014Il200SigRep1V4&hgta_table=wgEncodeCaltechRnaSeqGm12878R2x75Th1014Il200SigRep1V4&hgta_doSchema=describe+table+schema)|
| 26| Number of alternate alleles discovered (NDA)| Variant by cohort| Number of alternate alleles originally discovered| GATK|
| 27| Simple repeats| Genome| Entropy based on base composition of simple tandem repeats located by Tandem Repeats Finder| UCSC Genome Browser (http://rohsdb.cmb.usc.edu/GBshape/cgi-bin/hgTables?db=hg19&hgta_group=map&hgta_track=simpleRepeat&hgta_table=simpleRepeat&hgta_doSchema=describe+table+schema)|
| 28| Sample genotype quality (GQ)| Variant by sample| Phred-scaled confidence of the assigned genotype over the second most likely genotype| GATK|
| 29| Repeat masker| Genome| Binary variable indicating that the variant intersects a RepeatMasker sequence| UCSC Genome Browser (http://rohsdb.cmb.usc.edu/GBshape/cgi-bin/hgTables?db=hg19&hgta_group=map&hgta_track=rmsk&hgta_table=rmsk&hgta_doSchema=describe+table+schema)|
| 30| Overall non-diploid ratio (OND)| Variant by cohort| Ratio of reads other than the genotyped alleles to all reads| GATK|
| 31| Inbreeding coefficient is NA| Variant by cohort| Binary variable indicating that the given feature is N/A| -|
| 32| Negative train site| Variant by cohort| Binary variable indicating a negative site used to train GATK's VQSR model| GATK|
| 33| ABHom is NA| Variant by cohort| Binary variable indicating that the given feature is N/A| -|
| 34| Recombination rate is NA| Genome| Binary variable indicating that the given feature is N/A| -|
| 35| DNase hypersensitivity| Genome| Average signal enrichment for ENCODE/Analysis GM12878 DNase I hypersensitivity peaks| UCSC Genome Browser (http://rohsdb.cmb.usc.edu/GBshape/cgi-bin/hgTables?db=hg19&hgta_group=map&hgta_track=wgEncodeAwgDnaseUwdukeGm12878UniPk&hgta_table=wgEncodeAwgDnaseUwdukeGm12878UniPk&hgta_doSchema=describe+table+schema)|
| 36| Base quality rank sum is NA| Variant by cohort| Binary variable indicating that the given feature is N/A| -|
| 37| Mapping quality rank sum is NA| Variant by cohort| Binary variable indicating that the given feature is N/A| -|
| 38| DNase hypersensitivity is NA| Genome| Binary variable indicating that the given feature is N/A| -|
| 39| Read position rank sum is NA| Variant by cohort| Binary variable indicating that the given feature is N/A| -|
| 40| Positive train site| Variant by cohort| Binary variable indicating a positive site used to train GATK's VQSR model| GATK|
| 41| Segmental duplications| Genome| Binary variable indicating that the variant intersects a Segmental Dups sequence| UCSC Genome Browser (http://rohsdb.cmb.usc.edu/GBshape/cgi-bin/hgTables?db=hg19&hgta_group=map&hgta_track=genomicSuperDups&hgta_table=genomicSuperDups&hgta_doSchema=describe+table+schema)|
| 42| Replication timing| Genome| DNA replication timing (the ratio of sequencing read depths from S- and G1-phase cells; z-score units)| http://mccarrolllab.com/wp-content/uploads/2015/03/Koren-et-al-Table-S2.zip|
| 43| Replication timing is NA| Genome| Binary variable indicating that the given feature is N/A| -|
| 44| Highly multiallelic regions| Genome| Frequency of multi-allelic sites in ExAC per kbp region, for the top ten most multi-allelic regions| https://macarthurlab.org/2016/03/17/reproduce-all-the-figures-a-users-guide-to-exac-part-2/#multi-allelic-enriched-regions|
| 45| Transcription in LCL is NA| Genome| Binary variable indicating that the given feature is N/A| -
