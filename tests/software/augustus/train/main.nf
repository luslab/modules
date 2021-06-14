#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { AUGUSTUS_TRAIN } from '../../../../software/augustus/train/main.nf' addParams( options: [:] )

workflow test_augustus_train {
    
    input = [ [ id:'test', single_end:false ], // meta map
              file(params.test_data['sarscov2']['illumina']['test_paired_end_bam'], checkIfExists: true) ]

    AUGUSTUS_TRAIN ( input )
}
