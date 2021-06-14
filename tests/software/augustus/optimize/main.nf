#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { AUGUSTUS_OPTIMIZE } from '../../../../software/augustus/optimize/main.nf' addParams( options: [:] )

workflow test_augustus_optimize {
    
    input = file(params.test_data['sarscov2']['illumina']['test_single_end_bam'], checkIfExists: true)

    AUGUSTUS_OPTIMIZE ( input )
}
