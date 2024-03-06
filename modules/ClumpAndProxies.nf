#!/usr/bin/env nextflow

process ClumpAndProxies {
    label 'plink'

    input:
        tuple val(pheno), path(parsed_file), path(bed), path(bim), path(fam)

    output:
        path("${pheno}.proxies")

    script:
        """
        # Find if there are any significant results
        sig_results=\$(awk '\$2 < ${params.clump_p1}' ${parsed_file} | wc -l)

        if ((sig_results>0))

        then
            echo "There are sig. results!"

            plink --bfile ${bed.baseName} \\
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
        
            awk '{print \$3}' ${pheno}.clumped > ${pheno}_clumped.snplist
            echo "Data clumped"

            plink --bfile ${bed.baseName} \\
                --r2 \\
                --ld-window 1000000 \\
                --ld-window-kb 1000 \\
                --ld-window-r2 0.8 \\
                --ld-snp-list ${pheno}_clumped.snplist \\
                --extract ${params.extract} \\
                --out ${pheno} \\
                --threads 1 \\
                --memory 24000

            echo "Proxies calculated!"

            # Clean proxy file
            Rscript --vanilla ${baseDir}/bin/CleanClumps.R ${pheno}.ld ${pheno}
            echo "Files cleaned!"
        
        else

            echo "No clumps formed!"
            echo "pheno	lead_SNP\\tlead_SNP_chr\\tlead_SNP_bp\\tproxy_SNP\\tproxy_SNP_chr\\tproxy_SNP_bp\\tR2\\n">  ${pheno}.proxies

        fi

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