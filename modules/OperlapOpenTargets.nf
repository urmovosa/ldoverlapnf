#!/usr/bin/env nextflow

process OverlapOpenTargets {
    //tag "${file.baseName}"
    label 'R'  // Assuming 'R' label is defined in your nextflow.config for R-specific resources

    publishDir "${params.outputDir}", mode: 'copy', overwrite: true, pattern: "*OpenTargets_*.txt"

    input:
        tuple path(file), path(opentargets)

    output:
        tuple path("OpenTargets_overlap_summary.txt"), path("clumps_proxies_OpenTargets_overlap_detailed.txt"), path("OpenTargets_overlap_novel.txt")

    script:
    """
    Rscript --vanilla ${baseDir}/bin/OverlapOpenTargets.R ${file} ${opentargets}
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
