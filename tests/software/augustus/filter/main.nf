#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { AUGUSTUS_FILTER } from '../../../../software/augustus/filter/main.nf' addParams( options: [:] )

workflow test_augustus_filter {
    
    input = [ [ id:'test', single_end:false ], // meta map
              file(params.test_data['sarscov2']['illumina']['test_paired_end_bam'], checkIfExists: true) ]

    AUGUSTUS_FILTER ( input )
}
