#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { AUGUSTUS_BAM2HINTS } from '../../../../software/augustus/bam2hints/main.nf' addParams( options: [:] )

workflow test_augustus_bam2hints {
    
    input = file(params.test_data['sarscov2']['illumina']['test_single_end_bam'], checkIfExists: true)

    AUGUSTUS_BAM2HINTS ( input )
}
