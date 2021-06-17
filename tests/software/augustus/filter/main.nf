#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { UNTAR          } from '../../../../software/untar/main.nf'               addParams( options: [:] )
include { AUGUSTUS_FILTER } from '../../../../software/augustus/filter/main.nf' addParams( options: [:] )

workflow test_augustus_filter {
    augustus_model = file('https://raw.githubusercontent.com/mjmansfi/test-datasets/modules/data/genomics/sarscov2/genome/db/augustus/config.tar.gz', checkIfExists: true)
    UNTAR( augustus_model )
    model = UNTAR.out.untar.collect().map{ row -> ['sars_cov_2', row[0] ] }

    input = [ [ id:'test' ], // meta map
              file('https://raw.githubusercontent.com/mjmansfi/test-datasets/modules/data/genomics/sarscov2/genome/genome.genbank', checkIfExists: true)
            ]

    AUGUSTUS_FILTER ( input, model )
}
