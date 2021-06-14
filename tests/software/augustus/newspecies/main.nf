#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { AUGUSTUS_NEWSPECIES } from '../../../../software/augustus/newspecies/main.nf' addParams( options: [:] )

workflow test_augustus_newspecies {
    
    input = file(params.test_data['sarscov2']['illumina']['test_single_end_bam'], checkIfExists: true)

    AUGUSTUS_NEWSPECIES ( input )
}
