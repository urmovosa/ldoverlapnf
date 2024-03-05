#!/usr/bin/env nextflow

process ClumpAndProxies {
    label 'plink'
    input:
        tuple val(pheno), path(parsed_file)
        val params // Directly pass the params object

    output:
        path("${pheno}.snplist") into clumped_snplist_ch
        script:
    """
    plink --bfile ${params.ref} \\
        --clump ${parsed_file} \\
        --clump-field ${params.clump_field} \\
        --clump-p1 ${params.clump_p1} \\
        --clump-p2 ${params.clump_p2} \\
        --clump-r2 ${params.clump_r2} \\
        --clump-kb ${params.clump_kb} \\
        --clump-snp-field ${params.clump_snp_field} \\
        --extract ${params.extract} \\
        --out ${pheno} \\
        --threads 1 \\
        --memory 24000
    
    awk '{print \$3}' ${pheno}.clumped > ${pheno}.snplist
    echo "Data clumped"

     plink --bfile ${ref} \\
        --clump ${parsed_file} \\ # Corrected from processed_file to parsed_file
        --clump-field ${clump_field} \\
        --r2 \\
        --ld-window 1000000 \\
        --ld-window-kb 1000 \\
        --ld-window-r2 0.8 \\
        --ld-snp-list ${pheno}.snplist \\
        --out ${outp_folder}/${pheno} \\
        --threads 1 \\
        --memory 24000

    echo "Proxies calculated!"
    """
}

workflow CLUMP_AND_PROXIES {
    take:
    combined_ch

    main:
    clumped_snplist_ch = ClumpAndProxies(combined_ch)

    emit: 
    clumped_snplist_ch
}