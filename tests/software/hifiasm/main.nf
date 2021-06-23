#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { HIFIASM } from '../../../software/hifiasm/main.nf' addParams( options: [args:'-f0'] )

/* 
 * Test with long reads only
 */
workflow test_hifiasm_hifi_only {

    def input = []
    input = [ [ id:'test' ], // meta map
            [ file("${launchDir}/tests/data/genomics/homo_sapiens/fastq/SRR10382244_mapped_to_contig.fastq", checkIfExists: true) ] ]
    HIFIASM ( input )
}


