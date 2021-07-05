#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { TANTAN as TANTAN_FASTA } from '../../../software/tantan/main.nf' addParams( options: [:] )
include { TANTAN as TANTAN_BED }   from '../../../software/tantan/main.nf' addParams( options: [args:"-f4"] )

workflow test_tantan_fasta {
    
    input = [ [ id:'test', single_end:false ], // meta map
              file(params.test_data['sarscov2']['genome']['genome_fasta'], checkIfExists: true) ]

    TANTAN_FASTA ( input )
}

workflow test_tantan_bed {
    
    input = [ [ id:'test', single_end:false ], // meta map
              file(params.test_data['sarscov2']['genome']['genome_fasta'], checkIfExists: true) ]

    TANTAN_BED ( input )
}
