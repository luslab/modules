#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { AUGUSTUS_GFF2GB } from '../../../../software/augustus/gff2gb/main.nf' addParams( options: [:] )

workflow test_augustus_gff2gb {

    input = [ [ id:'test', single_end:false ], // meta map
              file(params.test_data['sarscov2']['genome']['genome_fasta'], checkIfExists: true) ]
    gxf = file(params.test_data['sarscov2']['genome']['genome_gff3'], checkIfExists: true)

    // The "flanking_size" value here was taken from the output of computeFlankingRegion.pl
    AUGUSTUS_GFF2GB ( input, gxf )
}
