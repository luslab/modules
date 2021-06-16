#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { AUGUSTUS_GFF2GB } from '../../../../software/augustus/gff2gb/main.nf' addParams( options: [:] )

workflow test_augustus_gff2gb {
    
    input = [ [ id:'test', single_end:false ], // meta map
              file(params.test_data['sarscov2']['illumina']['test_paired_end_bam'], checkIfExists: true) ]

    AUGUSTUS_GFF2GB ( input )
}
