#!/usr/bin/env nextflow

// Specify DSL2
nextflow.preview.dsl = 2

// Local default params
params.internal_process_name = 'umitools_dedup'

// Process definition
process umitools_dedup {
    publishDir "${params.outdir}/${params.internal_process_name}",
        mode: "copy", overwrite: true

    container 'luslab/nf-modules-umitools:latest'

    input:
      tuple val(sample_id), path(bai), path(bam)
       
    output:
      tuple val(sample_id), path(bam), emit: dedupBam

    shell:

    // Init
    error_message = ""
    args_exist = "false"
    internal_prog = "umi_tools dedup "
    internal_args = ""

    // Check main args string exists and strip whitespace
    if(params.umitools_dedup_args) {
        internal_args = params.umitools_dedup_args
        internal_args = internal_args.trim() + " "
        args_exist = "true"
    }
    else {
        error_message = "params.umitools_dedup_args does not exist, please define to run this module."
    }

    """
    if ${args_exist}; then
        ${internal_prog}${internal_args}-I $bam 
    else
        echo "${error_message}" 1>&2
        exit 1
    fi
    """
}