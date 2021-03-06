README.md
======

## Artifact Removal by Classifier (ARC):

**Goal/Purpose:** <br>
Artifact Removal by Classifier (ARC) is a supervised random forest model designed to distinguish true rare *de novo* variants (RDNVs) from lymphoblastoid cell line (LCL) specific genetic aberrations or other types of artifacts, such as sequencing and mapping errors. 

**Background/Overview:** <br>
ARC was developed and published as part of the iHART project; please reference our [manuscript](https://www.biorxiv.org/content/early/2018/06/06/338855) for full details. We trained ARC on RDNVs identified in 76 pairs of fully phase-able monozygotic (MZ) twins with whole-genome sequence (WGS) data derived from LCL DNA, using 48 features representing intrinsic genomic properties, (e.g., GC content and properties associated with *de novo* hotspots), sample specific properties (e.g., genome-wide number of *de novo* SNVs), signatures of transformation of peripheral B lymphocytes by Epstein-Barr virus (e.g., number of *de novo* SNVs in immunoglobulin genes), or variant properties (e.g., GATK variant metrics). We subsequently tested ARC on RDNVs identified in 17 fully phase-able whole blood (WB) and matched LCL samples with WGS data. The resulting random forest classifier achieved an area under the receiver operating characteristic (ROC) curve of 0.99 and 0.98 in the training and test set, respectively. We selected a conservative ARC score threshold (0.4) that achieved a minimum precision and recall rate of &gt;0.9 and ~0.8, respectively, across all 10-folds of the training set cross validation; and achieved a precision and recall rate of &gt;0.9 and &gt;0.8, respectively, in the test set.
 
![PanelA](https://imgur.com/zRZgtrZ.png)

**Pipelines:** <br>
There are two pipelines required for ARC (both contained within this repository):
1.  Annotation
2.  Classification
 
**Assumptions made by the pipeline:** <br>
This pipeline assumes that you have Perl, Python, ANNOVAR, BEDTools, Gawk, and Reference Genome human_g1k_v37 available on your system. Please follow the URLs provided below to download any resources you may need. Please note that ARC was only tested using the version of each resource listed below.
* Perl:
Tested on Perl version 5.10.1.
The latest version of Perl (5.28.0) is available at https://www.perl.org/get.html.
* Python:
Tested on Python versions 2.7.6+ and 3.6.4+.
Multiple release versions of Python packages are available at https://www.python.org/downloads/. ***This pipeline assumes that you are running Python version 2.7 or later. In addition, Python libraries pandas, sklearn, scipy, and matplotlib are also required for the pipeline.***
* ANNOVAR:
Tested on ANNOVAR version 2015Dec14.
A link to the latest version of ANNOVAR (2018Apr16) is available at http://annovar.openbioinformatics.org/en/latest/user-guide/download/ (registration required).
* BEDTools: 
Tested on BEDTools version 2.20.1.
Instructions on how to install the latest version of BEDTools (2.25.0) are available at https://bedtools.readthedocs.io/en/latest/content/installation.html. 
* Gawk:
Tested on Gawk version 4.1.4.
Instructions on how to get and extract the latest version of the gawk distribution (4.2.1) are available at https://www.gnu.org/software/gawk/manual/html_node/Getting.html#Getting.
* Reference Genome:
Reference Genome hs37d5 is available at
http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/, under filename human_g1k_v37.fasta.gz.

The variants were identified using GATK (v3.2.2) and raw RDNVs were identified as described in our [manuscript](https://www.biorxiv.org/content/early/2018/06/06/338855). 
 
### Setup/How to get started: <br>
 **Step 1: Get the code** <br>
 
 Click on the green "Clone or Download" button on the top right hand corner. <br>
 
   **Option 1: Download** 
   1. Select "Download Zip". <br>
   2. Move this zipped folder to your desired folder. <br>

   **Option 2: Clone** 
   1. Copy the URL provided. <br>
   2. Navigate to the directory where you would like to copy the repository using the command line. <br>
   3. Clone the repository using the following command: <br>
   ```
   git clone <URL>
   ```
 **Step 2: Unzip Genome in a Bottle and Replication Timing Annotation Source files** <br>
 1. Navigate to the Annotation_Source_Files directory <br> 
 ```
 cd Annotation_Source_Files
 ```
 2. Unzip Genome in a Bottle file:
 ```
 gunzip Genome_in_a_bottle_problematic_regions.bed.gz
 ```
 3. Unzip Replication Timing file:
 ```
 gunzip hg19_ReplicationTiming.txt.gz
 ```
 **Step 3: Download and Modify Additional Annotation Source files** <br>
  **Download Signal from ENCODE/Caltech GM12878 RNA-seq**
  1. Navigate to the UCSC Genome Browser directory that contains the downloadable files associated with this ENCODE composite track: http://hgdownload.cse.ucsc.edu/goldenPath/hg19/encodeDCC/wgEncodeCaltechRnaSeq/
  2. Download filename wgEncodeCaltechRnaSeqGm12878R2x75Th1014Il200SigRep1V4.bigWig (“ENCODE file”)
  3. Download UCSCs BigWigToWig Tool: <br>
   a. Navigate to the UCSC Genome Browser Software directory: http://hgdownload.soe.ucsc.edu/admin/exe/ <br>
   b. Select your proper machine type <br>
   c. Download filename bigWigToWig <br> 
  4. Use the following command to convert the ENCODE file from bigWig format to wig format:
  ```
  ./bigWigToWig wgEncodeCaltechRnaSeqGm12878R2x75Th1014Il200SigRep1V4.bigWig wgEncodeCaltechRnaSeqGm12878R2x75Th1014Il200SigRep1V4.wig
  ``` 
 * Note: You may need to make bigWigToWig executable by using the following command: <br>
  ```
  chmod +x ./bigWigToWig
  ```
  5. Covert ENCODE file into a format that is appropriate for the pipeline <br>
   Usage:
   ```
   bash Make_EncodeFile.sh <input: ENCODE file> <output_dir: Output dir>
   ```
  6. Move the hg19_EncodeCaltechRnaSeqGm12878R2x75.txt file produced by the Make_EncodeFile.sh script to the Annotation_Source_Files directory

   **Download RepeatMasker sequence** <br>
   1. Navigate to the UCSC genome annotation database for the hg19 Human Reference Genome: http://hgdownload.cse.ucsc.edu/goldenPath/hg19/database/ 
   2. Download filename rmsk.txt.gz (“RMSK file”)
   3. Unzip the rmsk.txt.gz file
   ```
   gunzip rmsk.txt.gz
   ```
   4. Convert the unzipped RMSK file ("rmsk.txt") into a format that is appropriate for the pipeline
   Usage:
   ```
   bash Make_RMSK.sh <input: unzipped RMSK file> <output_dir: Output dir>
   ```
   5. Move the hg19_rmsk.bed file produced by the Make_RMSK.sh script to the Annotation_Source_Files directory. 
   
**Overview of the practice data** <br>
We provide a small set of RDNVs (n = 25) as practice data. We recommend running both pipelines: the annotation pipeline followed by the classification pipeline, on these practice data before applying ARC to your own data. These practice data include two files: a list of RDNVs and a VCF.

1.  A tab delimited list of RDNVs (“RDNV flat file”). <br>
The practice RDNV flat file is: iHART_25_denovo_variants_ARC_practice_data_RDNV_flat_file.db 
* The RDNV file should contain all identified *de novo* variants in all of your samples. 
* The required columns are: Chr, Position, Ref, Alt, child_id, Info, genotype, genotype_subfields, and subfield_format. <br>
  * Note: The pipeline does not support periods or other non-alphanumeric characters in child_id. 
 
Example of RDNV flat file:

```
Chr        Position        Endpos        Ref        Alt        esp6500siv2_all        ExAC_ALL        1000g2015aug_all        cg46        CADD        CADD_Phred        Polyphen2_HDIV_score        Polyphen2_HDIV_pred        Polyphen2_HVAR_score        Polyphen2_HVAR_pred        consequence        gene_symbol        family        child_id        is_aff        inheritance_type        Info        genotype        genotype_subfields        subfield_format        max_control_AF        HNP_AF        adjusted_hom_freq_PSP        adjusted_hom_freq_HNP        %PSP_samples_missing        %HNP_samples_missing        RDNV_category        GIAB_flag_count        HGNC_symbol        HGNC_mapping        %RVIS_ESP_0.1%        %RVIS_ExAC_0.01%        %RVIS_ExAC_0.05%popn        %RVIS_ExAC_0.1%popn        constraint_score        pLI        pRecessive        pNull        pHI        chrN:N-N        pph2_prediction        pph2_prob        
1        99034        NA        T        G        NA        NA        NA        NA        NA        NA        NA        NA        NA        NA        intron_variant&non_coding_transcript_variant        RP11-34P13.7        FamilyA        iHART1945        1        denovo        PASS;ABHet=0.694;ABHom=1;AC=2;AF=0;AN=4480;BaseQRankSum=1.49;DP=73656;ExcessHet=3.226;FS=0;InbreedingCoeff=-0.0075;MLEAC=2;MLEAF=0.0004378;MQ=52.6;MQ0=0;MQRankSum=0.225;NDA=5;QD=9.21;ReadPosRankSum=-1.091;SOR=0.523;VQSLOD=-4.97;VariantType=SNP;culprit=MQ;cytoBand=1p36.33;Func=ncRNA_intronic;Gene=RP11-34P13.7;genomicSuperDups=0.992727,chr1:235525;FATHMM_c=0.08231;FATHMM_nc=0.00333;CSQ=G|intron_variant&non_coding_transcript_variant|MODIFIER|RP11-34P13.7|ENSG00000238009|Transcript|ENST00000466430|lincRNA||2/3|ENST00000466430.1:n.264-6794A>C|||||||||-1|SNV|Clone_based_vega_gene||YES|||||||||||||||||||||||||||||||||||||||||        0/1        0.67:10,5:.:99:180,0,518        GT:AB:AD:DP:GQ:PL        0        0.0        NA        0.0        NA        2.81995661605        somatic        0        NA        NA        NA        NA        NA        NA        NA        NA        NA        NA        NA        NA        NA        NA        
1        12878589        NA        GT        G        NA        NA        NA        NA        NA        NA        NA        NA        NA        NA        downstream_gene_variant        RP5-845O24.8        FamilyB        iHART2634        1        denovo        PASS;AC=1;AF=0;AN=4600;BaseQRankSum=-0.169;DP=66478;ExcessHet=3.0103;FS=2.937;InbreedingCoeff=-0.0001;MLEAC=1;MLEAF=0.0002133;MQ=58.02;MQ0=0;MQRankSum=-0.659;NDA=1;QD=7.51;ReadPosRankSum=0.751;SOR=1.197;VQSLOD=-1.155;VariantType=DELETION.NumRepetitions_6.EventLength_1.RepeatExpansion_T;culprit=FS;cytoBand=1p36.21;Func=intergenic;Gene=PRAMEF1,RP5-845O24.8;GeneDetail=21813,3959;genomicSuperDups=0.955807,chr1:13210222;CSQ=-|downstream_gene_variant|MODIFIER|RP5-845O24.8|ENSG00000228338|Transcript|ENST00000438401|lincRNA|||||||||||3959|-1|deletion|Clone_based_vega_gene||YES|||||||||||||||||||||||||||||||||||||||||        0/1        21,16:.:99:341,0,523        GT:AD:DP:GQ:PL        0        0.0        NA        0.0        NA        0.108459869848        somatic        0        NA        NA        NA        NA        NA        NA        NA        NA        NA        NA        NA        NA        NA        NA        
3        194314892        NA        C        CTGTCTG        NA        NA        NA        NA        NA        NA        NA        NA        NA        NA        intron_variant        TMEM44        FamilyC        iHART1417        1        denovo        PASS;AC=1;AF=0;AN=4582;BaseQRankSum=-0.413;DP=88579;ExcessHet=4.2252;FS=3.88;InbreedingCoeff=-0.0038;MLEAC=1;MLEAF=0.0002141;MQ=62.8;MQ0=0;MQRankSum=-0.945;NDA=2;NEGATIVE_TRAIN_SITE;QD=11.41;ReadPosRankSum=-0.083;SOR=1.508;VQSLOD=-0.9498;VariantType=INSERTION.NOVEL_6;culprit=FS;cytoBand=3q29;Func=intronic;Gene=TMEM44;CSQ=TGTCTG|intron_variant|MODIFIER|TMEM44|ENSG00000145014|Transcript|ENST00000392432|protein_coding||10/10|ENST00000392432.2:c.1318-5525_1318-5524insCAGACA|||||||||-1|insertion|HGNC|25120|YES|||CCDS54699.1|ENSP00000376227|TMM44_HUMAN|Q96I73_HUMAN|UPI00015E0940||||||||||||||||||||||||||||||||||        0/1        9,5:.:99:222,0,402        GT:AD:DP:GQ:PL        0        0.0        NA        0.0        NA        0.867678958785        somatic        0        TMEM44        NA        96.84        68.34        76.25        34.77        -2.472364196        3.67048384751758e-05        0.567721303337738        0.432241991823787        0.0212399169818057        chr3:194308402-194354418        NA        NA      
```

2.  A VCF file. <br>
The practice VCF file is: iHART_25_denovo_variants_ARC_practice_data.vcf
* This VCF should contain variants from all of your samples (a multi-sample jointly genotyped VCF).
* This VCF should include variants from all chromosomes.
  * Again, please note that ARC expects hg19/b37 coordinates and that this VCF will include GATK variant information. 

Example of VCF file:

```
*Header lines excluded*
#CHROM        POS        ID        REF        ALT        QUAL        FILTER        INFO        FORMAT        iHART1327        iHART1010        iHART1121        iHART1265        iHART1718        iHART1672        iHART1417        iHART2055        iHART1945        iHART2158        iHART2253        iHART2268        iHART2292        iHART2116        iHART1970        iHART2341        iHART2344        iHART2424        iHART2634        iHART2690        iHART2951        iHART2726        iHART3069        iHART3081        iHART1015
1        99034        .        T        G        303.89        PASS        ABHet=0.694;ABHom=1;AC=2;AF=0;AN=4480;BaseQRankSum=1.49;DP=73656;ExcessHet=3.226;FS=0;InbreedingCoeff=-0.0075;MLEAC=2;MLEAF=0.0004378;MQ=52.6;MQ0=0;MQRankSum=0.225;NDA=5;QD=9.21;ReadPosRankSum=-1.091;SOR=0.523;VQSLOD=-4.97;VariantType=SNP;culprit=MQ;cytoBand=1p36.33;Func=ncRNA_intronic;Gene=RP11-34P13.7;genomicSuperDups=0.992727,chr1:235525;FATHMM_c=0.08231;FATHMM_nc=0.00333;CSQ=G|intron_variant&non_coding_transcript_variant|MODIFIER|RP11-34P13.7|ENSG00000238009|Transcript|ENST00000466430|lincRNA||2/3|ENST00000466430.1:n.264-6794A>C|||||||||-1|SNV|Clone_based_vega_gene||YES|||||||||||||||||||||||||||||||||||||||||        GT:AB:AD:DP:GQ:PL        0/0:.:14,0:14:32:0,32,405        0/0:.:9,0:9:24:0,24,360        0/0:.:9,0:9:24:0,24,360        0/0:.:34,0:34:69:0,69,1035        0/0:.:16,0:16:22:0,22,471        0/0:.:9,0:9:21:0,21,267        0/0:.:13,0:13:21:0,21,442        0/0:.:10,0:10:15:0,15,287        0/1:0.67:10,5:.:99:180,0,518        0/0:.:20,0:20:21:0,21,519        0/0:.:9,0:9:24:0,24,360        0/0:.:15,0:15:42:0,42,630        0/0:.:25,0:25:12:0,12,693        0/0:.:12,0:12:25:0,25,366        0/0:.:23,0:23:45:0,45,644        0/0:.:14,0:14:39:0,39,405        0/0:.:11,0:11:30:0,30,450        0/0:.:28,0:28:69:0,69,1035        0/0:.:25,0:25:60:0,60,900        0/0:.:26,0:26:66:0,66,990        0/0:.:37,0:37:45:0,45,1108        0/0:.:29,0:29:40:0,40,874        0/0:.:15,0:15:36:0,36,540        0/0:.:28,0:28:63:0,63,945        0/0:.:34,0:34:93:0,93,1395
1        12878589        .        GT        G        277.84        PASS        AC=1;AF=0;AN=4600;BaseQRankSum=-0.169;DP=66478;ExcessHet=3.0103;FS=2.937;InbreedingCoeff=-0.0001;MLEAC=1;MLEAF=0.0002133;MQ=58.02;MQ0=0;MQRankSum=-0.659;NDA=1;QD=7.51;ReadPosRankSum=0.751;SOR=1.197;VQSLOD=-1.155;VariantType=DELETION.NumRepetitions_6.EventLength_1.RepeatExpansion_T;culprit=FS;cytoBand=1p36.21;Func=intergenic;Gene=PRAMEF1,RP5-845O24.8;GeneDetail=21813,3959;genomicSuperDups=0.955807,chr1:13210222;CSQ=-|downstream_gene_variant|MODIFIER|RP5-845O24.8|ENSG00000228338|Transcript|ENST00000438401|lincRNA|||||||||||3959|-1|deletion|Clone_based_vega_gene||YES|||||||||||||||||||||||||||||||||||||||||        GT:AD:DP:GQ:PL        0/0:43,0:43:70:0,70,1329        0/0:32,0:32:69:0,69,972        0/0:27,0:27:61:0,61,823        0/0:29,0:29:62:0,62,868        0/0:29,0:29:63:0,63,882        0/0:22,0:22:60:0,60,659        0/0:30,0:30:63:0,63,839        0/0:29,0:29:60:0,60,906        0/0:30,0:30:75:0,75,949        0/0:26,0:26:61:0,61,829        0/0:21,0:21:60:0,60,900        0/0:33,0:33:72:0,72,994        0/0:30,0:30:64:0,64,904        0/0:30,0:30:64:0,64,970        0/0:26,0:26:63:0,63,817        0/0:33,0:33:77:0,77,999        0/0:24,0:24:60:0,60,921        0/0:36,0:36:70:0,70,1046        0/1:21,16:.:99:341,0,523        0/0:32,0:32:71:0,71,945        0/0:21,0:21:60:0,60,900        0/0:26,0:26:62:0,62,840        0/0:39,0:39:89:0,89,1164        0/0:27,0:27:63:0,63,853        0/0:29,0:29:69:0,69,905
3        194314892        .        C        CTGTCTG        159.72        PASS        AC=1;AF=0;AN=4582;BaseQRankSum=-0.413;DP=88579;ExcessHet=4.2252;FS=3.88;InbreedingCoeff=-0.0038;MLEAC=1;MLEAF=0.0002141;MQ=62.8;MQ0=0;MQRankSum=-0.945;NDA=2;NEGATIVE_TRAIN_SITE;QD=11.41;ReadPosRankSum=-0.083;SOR=1.508;VQSLOD=-0.9498;VariantType=INSERTION.NOVEL_6;culprit=FS;cytoBand=3q29;Func=intronic;Gene=TMEM44;CSQ=TGTCTG|intron_variant|MODIFIER|TMEM44|ENSG00000145014|Transcript|ENST00000392432|protein_coding||10/10|ENST00000392432.2:c.1318-5525_1318-5524insCAGACA|||||||||-1|insertion|HGNC|25120|YES|||CCDS54699.1|ENSP00000376227|TMM44_HUMAN|Q96I73_HUMAN|UPI00015E0940||||||||||||||||||||||||||||||||||        GT:AD:DP:GQ:PL        0/0:49,0:49:99:0,120,1800        0/0:41,0:41:99:0,111,1665        0/0:30,0:30:61:0,61,917        0/0:42,0:42:99:0,103,1321        0/0:37,0:37:69:0,69,1035        0/0:32,0:32:87:0,87,1305        0/1:9,5:.:99:222,0,402        0/0:33,0:33:65:0,65,963        0/0:26,0:26:61:0,61,819        0/0:27,0:27:60:0,60,811        0/0:22,0:22:60:0,60,900        0/0:33,0:33:81:0,81,1044        0/0:39,0:39:99:0,99,1258        0/0:48,0:48:99:0,108,1620        0/0:34,0:34:39:0,39,965        0/0:40,0:40:75:0,75,1125        0/0:29,0:29:52:0,52,853        0/0:36,0:36:64:0,64,1095        0/0:35,0:35:81:0,81,1215        0/0:50,0:50:99:0,108,1620        0/0:53,0:53:99:0,102,1530        0/0:40,0:40:84:0,84,1260        0/0:29,0:29:60:0,60,900        0/0:34,0:34:87:0,87,1305        0/0:39,0:39:87:0,87,1305
```

### Recalculate ABHet for all RDNVs: <br>

 **Purpose of ABHet recalculation:** <br>
 The ABHet annotation is not currently provided for indels by GATK. Using the ABHet formula (below), we manually calculate the ABHet value for all SNVs and indels. Critically, if your dataset includes duplicates or monozygotic twins, you should exclude one of the duplicates by providing a list of duplicate samples when recalculating ABHet. <br> 
 
   ![ABHet equation](http://latex.codecogs.com/gif.latex?ABHet%20%3D%20%5Cfrac%7B%20%5C%23REF%20%5C%20%5C%20reads%20%5C%20%5C%20from%20%5C%20%5C%20heterozygous%20%5C%20%5C%20samples%7D%7B%20%5C%23REF%20&plus;%20ALT%20%5C%20%5C%20reads%20%5C%20%5C%20from%20%5C%20%5C%20heterozygous%20%5C%20%5C%20samples%7D)

![PanelB](https://imgur.com/LJcXbFi.png)
Usage:
```
python calculate_abhet_collapsing_duplicates.py --vcf <VCF from which to calculate abhet> --output_dir <Output dir> [Optional: --variants, --samples_to_exclude_when_true] (The pipeline expects this to be "unrenamed PAR", i.e., sex chromosomes should be "X" and "Y".)
```
Options: 
  
--variants: provide a tab separated: chrom, pos, ref, alt, comma-separated list of TRUE variants. If empty, will use all variants in VCF.

--samples_to_exclude_when_true: list of samples (e.g. WB or MZ_twin) to exclude when concordant = TRUE). Variants found in these samples will be excluded.
 + Note: manual_abhet will match adjusted_abhet for SNVs when no samples to exclude are listed. 

* Note: This script takes in one multi-sample VCF file with all chromosomes included. 

Output (*VCF_file_name*_with_abhet_recalculation.txt):
```
chr        pos        snp_id        ref        alt        gatk_abhet        manual_abhet        samples_excluded        adjusted_abhet
1        99034        .        T        G        0.694        0.667        NA        0.667
1        12878589        .        GT        G        None        0.568        NA        0.568
3        194314892        .        C        CTGTCTG        None        0.643        NA        0.643
```

### Run the annotation pipeline: Steps 1-4 prepare your input files by reformatting to pipeline compatible formats. <br>
   + We have provided an "Output" directory to help organize the output from the annotation and classification pipeline. 
   + If you run into issues at any point in the annotation pipeline, please feel free to check out our Issues.md page for solutions.<br>
   
**Step 1: Make a version of the RDNV flat file that the pipeline understands.** <br>

  **Part 1: Specify Gawk directory in makeOwnFlatDb.sh (provided in the Scripts directory)** <br>
  ```
  vi makeOwnFlatDb.sh
  ```

  Set AWK variable (makeOwnFlatDb.sh, Line 3) to the absolute path of the Gawk software directory. <br>

  ```
  AWK="" #Insert absolute path to Gawk
  ```
  **Part 2: Run the makeOwnFlatDb.sh script** <br>
  ```
  bash makeOwnFlatDb.sh <input: RDNV flat file> <output_file: desired output file name and directory for pipeline-specific flat file>
  ```

  Output:
  ```
  1        99034        T        G        iHART1945        GT:AB:AD:DP:GQ:PL        0/1:0.67:10,5:.:99:180,0,518        PASS;ABHet=0.694;ABHom=1;AC=2;AF=0;AN=4480;BaseQRankSum=1.49;DP=73656;ExcessHet=3.226;FS=0;InbreedingCoeff=-0.0075;MLEAC=2;MLEAF=0.0004378;MQ=52.6;MQ0=0;MQRankSum=0.225;NDA=5;QD=9.21;ReadPosRankSum=-1.091;SOR=0.523;VQSLOD=-4.97;VariantType=SNP;culprit=MQ;cytoBand=1p36.33;Func=ncRNA_intronic;Gene=RP11-34P13.7;genomicSuperDups=0.992727,chr1:235525;FATHMM_c=0.08231;FATHMM_nc=0.00333;CSQ=G|intron_variant&non_coding_transcript_variant|MODIFIER|RP11-34P13.7|ENSG00000238009|Transcript|ENST00000466430|lincRNA||2/3|ENST00000466430.1:n.264-6794A>C|||||||||-1|SNV|Clone_based_vega_gene||YES|||||||||||||||||||||||||||||||||||||||||
  1        12878589        GT        G        iHART2634        GT:AD:DP:GQ:PL        0/1:21,16:.:99:341,0,523        PASS;AC=1;AF=0;AN=4600;BaseQRankSum=-0.169;DP=66478;ExcessHet=3.0103;FS=2.937;InbreedingCoeff=-0.0001;MLEAC=1;MLEAF=0.0002133;MQ=58.02;MQ0=0;MQRankSum=-0.659;NDA=1;QD=7.51;ReadPosRankSum=0.751;SOR=1.197;VQSLOD=-1.155;VariantType=DELETION.NumRepetitions_6.EventLength_1.RepeatExpansion_T;culprit=FS;cytoBand=1p36.21;Func=intergenic;Gene=PRAMEF1,RP5-845O24.8;GeneDetail=21813,3959;genomicSuperDups=0.955807,chr1:13210222;CSQ=-|downstream_gene_variant|MODIFIER|RP5-845O24.8|ENSG00000228338|Transcript|ENST00000438401|lincRNA|||||||||||3959|-1|deletion|Clone_based_vega_gene||YES|||||||||||||||||||||||||||||||||||||||||
  3        194314892        C        CTGTCTG        iHART1417        GT:AD:DP:GQ:PL        0/1:9,5:.:99:222,0,402        PASS;AC=1;AF=0;AN=4582;BaseQRankSum=-0.413;DP=88579;ExcessHet=4.2252;FS=3.88;InbreedingCoeff=-0.0038;MLEAC=1;MLEAF=0.0002141;MQ=62.8;MQ0=0;MQRankSum=-0.945;NDA=2;NEGATIVE_TRAIN_SITE;QD=11.41;ReadPosRankSum=-0.083;SOR=1.508;VQSLOD=-0.9498;VariantType=INSERTION.NOVEL_6;culprit=FS;cytoBand=3q29;Func=intronic;Gene=TMEM44;CSQ=TGTCTG|intron_variant|MODIFIER|TMEM44|ENSG00000145014|Transcript|ENST00000392432|protein_coding||10/10|ENST00000392432.2:c.1318-5525_1318-5524insCAGACA|||||||||-1|insertion|HGNC|25120|YES|||CCDS54699.1|ENSP00000376227|TMM44_HUMAN|Q96I73_HUMAN|UPI00015E0940||||||||||||||||||||||||||||||||||
  ```

  Description:
  This script creates a database from the RDNV flat file. The first step in creating an RDNV file that the annotation pipeline understands, is to remove the PAR annotation from the X & Y chromosome variants if these variants are labeled with ‘PAR’. This script then extracts the required columns from the RDNV flat file (Columns: Chr, Position, Ref, Alt, child_id, subfield_format, genotype: genotype_subfields, Info) and outputs a tab-delimited file with 8 columns. Additional columns present in the RDNV flat file are ignored, and the required columns are organized into the proper format for the pipeline. This output file will be referenced by the data_config.sh script in Step 4.
 
**Step 2: Create a Variant_ID for each variant.** <br>
Usage:
```
bash makeAnnotationInputFileFromOwnFlatDb.sh <input: pipeline-specific flat file> <output_file: desired output file name and directory for annotation input file>
```

Output:
```
1.99034.T.G.iHART1945        TRUE
1.12878589.GT.G.iHART2634        FALSE
3.194314892.C.CTGTCTG.iHART1417        FALSE
```
* Note: The Classification column is filled with FALSE everywhere except the first row in order to prevent the AUC calculation from crashing.
 
Description:
This script outputs a tab delimited file with 2 columns, Variant_ID and Classification. The Variant_ID is made up of the first 5 columns from the output of Step 1 delimited by periods rather than a tab (e.g., Chr.Pos.Ref.Alt.Child). The Classification column is ignored when running the existing ARC model on new data; when developing the ARC model this column was used to assign true vs. false variant status in the training and the test set. This output file (“Variant ID file”) will be used as the input for the getAnnotation.sh script in Step 5. 

**Step 3: Make a version of the ABHet file that the pipeline understands.** <br>
Usage:
```
bash makeOwnABHetFile.sh <input: ABHet file with 9 columns and header> <output_file: desired output file name and directory for pipeline-specific ABHet
file>
```

Output:
```
1        99034        T        G        0.667
1        12878589        GT        G        0.568
3        194314892        C        CTGTCTG        0.643
```

Description:
This script reformats the recalculated ABHet file with 9 columns into an ABHet file with no header and 5 columns (chr, pos, ref, alt, and adjusted_abhet) that are tab delimited. This output file will be used in the data_config.sh script in Step 4.
 
**Step 4: Manually input the paths for your pipeline-specific RDNV flat file (output of Step 1) and your pipeline-specific ABHet file (output of Step 3) into the data_config.sh script.**
```
vi data_config.sh
```
```
FLAT= # Absolute path to pipeline-specific RDNV flat file (output of Step 1)
ABHET= # Absolute path to pipeline-specific ABHet file (output of Step 3)
```
Description:
The purpose of this step is to change the data_config.sh script to have absolute paths to the pipeline formatted RDNV flat file and the pipeline formatted ABHet file. The data_config.sh script is called within the setAnnotationEnv.sh script which is part of the getAnnotation.sh script in Step 6. 

**Step 5: Manually assign variables in setAnnotationEnv.sh script, lines 12-20 with the absolute paths specified.**
```
vi setAnnotationEnv.sh
```
```
IG_LIST="" #Absolute path to Human_immunoglobulin_genes_HGNClist.txt file provided in the Annotation_Source_Files directory
GIAB="" #Absolute path to Genome_in_a_bottle_problematic_regions.bed file provided in the Annotation_Source_Files directory

ANNOVAR="" #Absolute path path to your preferred perl installation followed by an absolute path to the table_annovar.pl script from ANNOVAR, separated by a space
ANV_DIR=""; #Absolute path to Annotation_Source_Files directory
AWK="" #Absolute path to Gawk software directory
BED="" #Absolute path to BEDTools toolset directory 

REFG="" # Absolute path to Human Reference Genome hs37d5 file
```
Description:
The purpose of this step is to change the setAnnotationEnv.sh script to have absolute paths to the necessary directories, tools, and files for the getAnnotation.sh script in Step 6.

**Step 6: Run the annotation pipeline.** <br>
Usage:
```
bash getAnnotation.sh <input: annotation input file (output of Step 2 above)> <output_dir: output dir for annotation .out and intermediate files>
```
* Note: Be sure to provide absolute path to the annotation input file, since this absolute path is required by the getAnnotation.sh script. 
* Note: This produces many intermediate files as well as a final .out file in the output directory.
  
Output (annotation .out file):
```
Variant_ID        CLASSIFICATION        AbpartsTCR        DnaseUwdukeGm12878UniPk        EncodeCaltechRnaSeqGm12878R2x75        RecombRate        ReplicationTiming        SimpleRepeat        Rmsk        SegDups        Top10multiallelic        SAMPLE_AD_REF        SAMPLE_AD_ALT        SAMPLE_DP        SAMPLE_GQ        SAMPLE_ADDP        DP        ABHet        ABHom        AN        BaseQRankSum        FS        InbreedingCoeff        MQ        MQRankSum        NDA        NEGATIVE_TRAIN_SITE        OND        POSITIVE_TRAIN_SITE        QD        ReadPosRankSum        SOR        VQSLOD        IG        Num_vars_in_IG        Num_vars_in_TCR_abparts        Trinucleotide_context        PCT_GC_content_100bp        All.simplerepeatsnocov        Decoy.bed        Superdupsmerged_all_sort        Systematic.Sequencing.Errors        VQSRv2.18_filterABQD_sorted        VQSRv2.18_filterAlign_sorted        VQSRv2.18_filterConflicting        VQSRv2.18_filterlt2Datasets        VQSRv2.18_filterMap        VQSRv2.18_filterSSE        Num_uncertain_regions        isIndel        isDnaseNA        isEncodeNA        isRecombRateNA        isReplicationTimingNA        isABHetNA        isABHomNA        isBaseQRankSumNA        isInbreedingNA        isMQRankSumNA        isReadPosRankSumNA        Num_SNV
1.99034.T.G.iHART1945        TRUE        0        0        0        1.11575        NA        0.78        1        1        0        10        5        15        99        0.333333        73656        0.667        1        4480        1.49        0        -0.0075        52.6        0.225        5        0        0        0        9.21        -1.091        0.523        -4.97        0        0        0        AAT        0.148515        0        0        0        0        0        0        0        0        0        0        0        0        0        0        0        1        0        0        0        0        0        0        1
1.12878589.GT.G.iHART2634        FALSE        0        0        0        0.998319        NA        0        1        1        0        21        16        37        99        0.432432        66478        0.568        NA        4600        -0.169        2.937        -0.0001        58.02        -0.659        1        0        0        0        7.51        0.751        1.197        -1.155        0        0        0        ACA        0.405941        0        0        0        0        0        0        0        0        0        0        0        1        0        0        0        1        0        1        0        0        0        0        0
3.194314892.C.CTGTCTG.iHART1417        FALSE        0        0        1        2.45749        1.000989        1.49        1        0        0        9        5        14        99        0.357143        88579        0.643        NA        4582        -0.413        3.88        -0.0038        62.8        -0.945        2        1        0        0        11.41        -0.083        1.508        -0.9498        0        0        0        AGA        0.316832        0        0        0        0        0        0        0        0        0        0        0        1        0        0        0        0        0        1        0        0        0        0        0
```

Description:
This script annotates the Variant ID file with all ARC features and outputs the final .out file along with other intermediate files in the output directory. The getAnnotation.sh script calls five other scripts: (1) setAnnotationEnv.sh, (2) getAnnotation.annovar.sh, (3) getAnnotation.gatk.sh, (4) getAnnotation.other.sh, and (5) getAnnotation.adjust.perSampleCounts.sh. It also recalculates the per-sample count columns as needed. This output file is the Annotated Variant ID file and is the input for Step 7. 
 
### Run the classification pipeline: <br>
**Step 7: Run testRF.py.** <br>
Usage:
```
python testRF.py <input: Annotated Variant ID file> <output_file: desired output file name and directory for RDNV classification>
```

* NB: Running this script on a large number of variants (we estimate >100,000 variants) can potentially crash your computer. If you think this might be an issue for you, use the preimputation.py script first and then run the above command with the skip_imputation argument. <br>
      ```
      python preimputation.py --input_annotation <input: Annotated Variant ID file (from Step 5)> <output_file: desired output file name and directory for preimputed .out file from annotation pipeline>
      ``` 
 
Output:
```
        ARC_Score        Classification
0        0.089        1.0
1        0.505        0.0
2        0.076        0.0
3        0.318        0.0
```

Description:
The script calculates the ARC score, column name "ARC_Score", for each variant and generates a single indexed list of ARC scores. We recommend selecting a threshold of 0.4. We consider variants with an ARC score of &lt;0.4 likely to be sequencing or cell line artifacts and a score of &ge;0.4 to be true *de novo* variants. This script generates your “classification output file” which is used in Step 8.
 
**Step 8: Recombine the ARC scores from your RDNV Classification output file (output of Step 7) with your Variant ID file (output of Step 6).** <br>
Usage:
```
paste <(awk '{print $1}' <annotation .out file>) <(awk 'BEGIN{OFS = '\t'; print "ARC_Score"} (NR != 1) {print $2}' <classification output file>) > <output_file: desired output file name and directory for Classification output file with Variant ID>
```

Output:
```
Variant_ID  ARC_Score
1.99034.T.G.iHART1945 0.089
1.12878589.GT.G.iHART2634 0.505
3.194314892.C.CTGTCTG.iHART1417 0.076
```
