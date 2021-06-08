#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { PASA_SEQCLEAN } from '../../../../software/pasa/seqclean/main.nf' addParams( options: [:] )

workflow test_pasa_pipeline {

    input = [ [ id:'test', single_end:false ], // meta map
              file(params.test_data['sarscov2']['genome']['transcriptome_fasta'], checkIfExists: true) ]

    PASA_SEQCLEAN ( input )
}
