#!/usr/bin/env nextflow

process ParseSumstats {
   // conda 'environment.yml'
    tag "${file.baseName}"
    label 'R'  // Assuming 'R' label is defined in your nextflow.config for R-specific resources

    input:
        path(file)

    output:
        path("*_processed.txt")

    script:
    """
    Rscript --vanilla $baseDir/bin/parse.R $file
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
