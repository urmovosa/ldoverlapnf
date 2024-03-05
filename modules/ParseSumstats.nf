#!/usr/bin/env nextflow

process ParseSumstats {
   // conda 'environment.yml'
    tag "${file.baseName}"
    label 'R'  // Assuming 'R' label is defined in your nextflow.config for R-specific resources

    input:
        path(file)

    output:
       tuple env(phenoname), path("*_processed.txt")

    script:
    """
    Rscript --vanilla ${baseDir}/bin/parse.R ${file}

    #Parse phenotype name
    phenoname=\$(ls *_processed* | cut -d '_' -f 1)
    """
}

workflow PARSE_SUMSTATS {
    take:
        data_ch  // Channel of .parquet.snappy files

    main:
        ParseSumstats(data_ch)

    emit:
        processed_files_ch = ParseSumstats.out
}
