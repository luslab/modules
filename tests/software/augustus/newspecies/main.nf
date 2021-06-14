#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { AUGUSTUS_NEWSPECIES } from '../../../../software/augustus/newspecies/main.nf' addParams( options: [:] )

workflow test_augustus_newspecies {

    input = 'sars_cov_2'

    AUGUSTUS_NEWSPECIES ( input )
}
