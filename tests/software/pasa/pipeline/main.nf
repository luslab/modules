#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { PASA_PIPELINE } from '../../../../software/pasa/pipeline/main.nf' addParams( options: [:] )

workflow test_pasa_pipeline {

    input = [ [ id:'test', single_end:false ], // meta map
              file("https://github.com/nf-core/test-datasets/raw/modules/data/genomics/homo_sapiens/genome/transcriptome.fasta", checkIfExists: true),
              file("https://github.com/nf-core/test-datasets/raw/modules/data/genomics/homo_sapiens/genome/genome.fasta", checkIfExists: true) ]

    PASA_PIPELINE ( input )
}
