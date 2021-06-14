#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { AUGUSTUS_COPYMODEL } from '../../../../software/augustus/copymodel/main.nf' addParams( options: [:] )

workflow test_augustus_copymodel {

    input = 'generic'

    AUGUSTUS_COPYMODEL ( input )
}
