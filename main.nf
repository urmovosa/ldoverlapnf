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

Channel
    .fromPath("${params.inputDir}/*.parquet.snappy", checkIfExists: true)
    .ifEmpty { exit 1, "Input directory is empty!" }
    .set { input_files_ch }


// Create a value channel for the parameters
params_ch = Channel.value(tuple(params.ref, params.clump_field, params.clump_p1, params.clump_p2, params.clump_r2, params.clump_kb, params.clump_snp_field, params.extract, params.outp_folder))
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
    //input_files_ch.view()
    PARSE_SUMSTATS(input_files_ch)

    parsed_files_ch = PARSE_SUMSTATS.out.view()

    //CLUMP_AND_PROXIES(parsed_files_ch, params)
}
