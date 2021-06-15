#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { UNTAR               } from '../../../../software/untar/main.nf'               addParams( options: [:] )
include { AUGUSTUS_PRETRAINED } from '../../../../software/augustus/pretrained/main.nf' addParams( options: [:] )

workflow test_augustus_pretrained {

    augustus_model = file('https://raw.githubusercontent.com/mjmansfi/test-datasets/modules/data/genomics/sarscov2/genome/db/augustus.tar.gz', checkIfExists: true)

    UNTAR( augustus_model )
    AUGUSTUS_PRETRAINED ( 'sars_cov_2', UNTAR.out.untar )
}
