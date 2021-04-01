#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { HIFIASM } from '../../../software/hifiasm/main.nf' addParams( options: [[args:'-f0'] )

/* 
 * Test with long reads only
 */
// Test dataset is first 5 reads from one run of the HG002 human genome:
// fastq-dump --stdout SRR10382244 | head -n 20 > test.fastq
workflow test_hifiasm_hifi_only {

    def input = []
    input = [ [ id:'test' ], // meta map
              [ file("${launchDir}/tests/data/genomics/homo_sapiens/fastq/test.fastq.gz", checkIfExists: true) ] ]
    HIFIASM ( input )
