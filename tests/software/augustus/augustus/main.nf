#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { UNTAR             } from '../../../../software/untar/main.nf'             addParams( options: [:] )
include { AUGUSTUS_AUGUSTUS } from '../../../../software/augustus/augustus/main.nf' addParams( options: [:] )

workflow test_augustus_augustus {
    augustus_model = file('https://raw.githubusercontent.com/mjmansfi/test-datasets/modules/data/genomics/sarscov2/genome/db/augustus/config.tar.gz', checkIfExists: true)
    UNTAR( augustus_model )
    model = UNTAR.out.untar.collect().map{ row -> ['sars_cov_2', row[0] ] }

    input = [ [ id:'test', single_end:false ], // meta map
              file(params.test_data['sarscov2']['genome']['genome_fasta'], checkIfExists: true) ]

    AUGUSTUS_AUGUSTUS ( input, model )
}
