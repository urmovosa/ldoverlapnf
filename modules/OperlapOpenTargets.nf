#!/usr/bin/env nextflow

process OverlapOpenTargets {
    //tag "${file.baseName}"
    label 'R'  // Assuming 'R' label is defined in your nextflow.config for R-specific resources

    publishDir "${params.OutputDir}", mode: 'copy', overwrite: true, pattern: "*Opentargets_*.txt"

    input:
        tuple path(file), path(gwascat)

    output:
        tuple path("Opentargets_overlap_summary.txt"), path("clumps_proxies_Opentargets_overlap_detailed.txt"), path("GWAS_catalogue_overlap_novel.txt")

    script:
    """
    Rscript --vanilla ${baseDir}/bin/OverlapOpentargets.R ${file} ${gwascat}
    """
}

workflow OVERLAP_OPENTARGETS {
    take:
        data_ch  // Channel of .parquet.snappy files

    main:
        OverlapOpenTargets(data_ch)

    emit:
        gwascat_output_ch = OverlapOpenTargets.out
}
