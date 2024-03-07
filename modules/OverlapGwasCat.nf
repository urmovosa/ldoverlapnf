#!/usr/bin/env nextflow

process OverlapGwasCat {
    //tag "${file.baseName}"
    label 'R'  // Assuming 'R' label is defined in your nextflow.config for R-specific resources

    publishDir "${params.outputDir}", mode: 'copy', overwrite: true, pattern: "*_catalogue_*.txt"

    input:
        tuple path(file), path(gwascat)

    output:
        tuple path("GWAS_catalogue_overlap_summary.txt"), path("clumps_proxies_GWAS_catalogue_overlap_detailed.txt"), path("GWAS_catalogue_overlap_novel.txt")

    script:
    """
    Rscript --vanilla ${baseDir}/bin/OverlapGwasCatalogue.R ${file} ${gwascat}
    """
}

workflow OVERLAP_GWASCAT {
    take:
        data_ch  // Channel of .parquet.snappy files

    main:
        OverlapGwasCat(data_ch)

    emit:
        gwascat_output_ch = OverlapGwasCat.out
}
