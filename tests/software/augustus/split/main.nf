#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { AUGUSTUS_SPLIT } from '../../../../software/augustus/split/main.nf' addParams( options: [:] )

workflow test_augustus_split {
    
    input = file(params.test_data['sarscov2']['illumina']['test_single_end_bam'], checkIfExists: true)

    AUGUSTUS_SPLIT ( input )
}
