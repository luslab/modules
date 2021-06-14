#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { AUGUSTUS_COPYMODEL } from '../../../../software/augustus/copymodel/main.nf' addParams( options: [:] )

workflow test_augustus_copymodel {
    
    input = file(params.test_data['sarscov2']['illumina']['test_single_end_bam'], checkIfExists: true)

    AUGUSTUS_COPYMODEL ( input )
}
