#!/usr/bin/env nextflow
/* 
 * Enables Nextflow DSL 2
 */
nextflow.enable.dsl=2

//params.inputDir = ""
//params.outp_folder = ""
//params.ref = ""
params.clump_field = 'P'
params.clump_p1 = 5e-08
params.clump_p2 = 1
params.clump_r2 = 0.2
params.clump_kb = 250
params.clump_snp_field = 'SNP'
//params.extract = ""

// Include the modular workflows
include { PARSE_SUMSTATS } from './modules/ParseSumstats.nf'
include { CLUMP_AND_PROXIES } from './modules/ClumpAndProxies.nf'
include { OVERLAP_GWASCAT } from './modules/OverlapGwasCat.nf'
include { OVERLAP_OPENTARGETS } from './modules/OverlapOpenTargets.nf'

Channel
    .fromPath("${params.inputDir}/*.parquet.snappy", checkIfExists: true)
    .ifEmpty { exit 1, "Sumstats directory is empty!" }
    .set { input_files_ch }

  Channel
    .from(params.ref)
    .ifEmpty { exit 1, "Input plink prefix not found!" }
    .map { study -> [file("${study}.bed"), file("${study}.bim"), file("${study}.fam")]}
    .set { ref_ch }

Channel
    .fromPath("${params.extract}", checkIfExists: true)
    .ifEmpty { exit 1, "SNP list is empty!" }
    .set { snplist_ch }

Channel
    .fromPath("${params.gwascat}", checkIfExists: true)
    .ifEmpty { exit 1, "GWAS catalogue path is empty!" }
    .set { gwascat_ch }

Channel
    .fromPath("${params.opentargets}", checkIfExists: true)
    .ifEmpty { exit 1, "OpenTargets path is empty!" }
    .set { opentargets_ch }

// Create a value channel for the parameters
params_ch = Channel.value(tuple(params.ref, params.clump_field, params.clump_p1, params.clump_p2, params.clump_r2, params.clump_kb, params.clump_snp_field))
// Before calling the process or workflow
println("Input Directory: ${params.inputDir}")


log.info """=======================================================
DataQC v${workflow.manifest.version}"
======================================================="""
def summary = [:]
summary['Pipeline Name']            = 'LDoverlap'
summary['Pipeline Version']         = workflow.manifest.version
summary['Working dir']              = workflow.workDir
summary['Container Engine']         = workflow.containerEngine
if(workflow.containerEngine) summary['Container'] = workflow.container
summary['Current home']             = "$HOME"
summary['Current user']             = "$USER"
summary['Current path']             = "$PWD"
summary['Working dir']              = workflow.workDir
summary['Script dir']               = workflow.projectDir
summary['Config Profile']           = workflow.profile
log.info summary.collect { k,v -> "${k.padRight(21)}: $v" }.join("\n")
log.info "========================================="


workflow {

    PARSE_SUMSTATS(input_files_ch)

    parsed_files_ch = PARSE_SUMSTATS.out.combine(ref_ch)

    CLUMP_AND_PROXIES(parsed_files_ch)

    proxies_ch = CLUMP_AND_PROXIES.out.flatten().collectFile(name: 'Proxies.txt', keepHeader: true, sort: true)

    OVERLAP_GWASCAT(proxies_ch.combine(gwascat_ch))
    OVERLAP_OPENTARGETS(proxies_ch.combine(opentargets_ch))
}
