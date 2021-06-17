#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { AUGUSTUS_SPLIT } from '../../../../software/augustus/split/main.nf' addParams( options: [:] )

workflow test_augustus_split {

    input = [ [ id:'test' ], // meta map
              file('https://raw.githubusercontent.com/mjmansfi/test-datasets/modules/data/genomics/sarscov2/genome/genome.genbank', checkIfExists: true)
            ]

    AUGUSTUS_SPLIT ( input, '1' )
}
