### 1. Before running scripts

- All scripts are assumed to be in the same directory.
- Make sure all data files specified in `setAnnotationEnv.sh` are in place.
- Default output directory is the current working directory: `$(pwd)`. You can change this in `setAnnotationEnv.sh`.

### 2. Input variant file for annotation

- Input file needs to have two columns, without header: "Variant_ID" and "Classification", in this order.
- Other columns will be ignored.
- "Variant_ID" format: chrom.pos.ref.alt.sample_id (e.g, `X.12345.AAT.A.AU1000201`).
- "Classification" format: either `TRUE` (==1) or `FALSE` (==0).


### 3. Main script

```bash
   bash /Your/Script/Path/getAnnotation.sh $Your_Input_File $Annotation_Type
```

- "Annotation_Type": `train`, `test`, or `rdnv`, which specifies what flat_db file to use for annotation.
- If the input file name is `test.var`, the annotated output file name will be `test.var.out`.


### 4. Workflow

- In `getAnnotation.sh`:

    + `setAnnotationEnv.sh`: set functions, directries and data files common to all sub-scripts.
    + `getAnnotation.annovar.sh`: make Annovar-related intermediate output file (`$O1`).
    + `getAnnotation.gatk.sh`: make Gatk and per-sample-count output files (`$O2` and `$O3`).
    + `getAnnotation.other.sh`: make intermediate output files for other features (`$O4` to `$O8`).
    <br>
    
    + `getAnnotation.adjust.perSampleCounts.sh`: recalculates #IG, #TCR, and #SNV if needed. 
    <br>
    
    + These sub-scripts are divided for debugging purposes, and can be run individually.
<br>

- `makeOwnFlatDb.sh`: extract annotation information from raw flat db files.
