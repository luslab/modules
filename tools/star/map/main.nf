#!/usr/bin/env nextflow

// Include NfUtils
Class groovyClass = new GroovyClassLoader(getClass().getClassLoader()).parseClass(new File(params.classpath));
GroovyObject nfUtils = (GroovyObject) groovyClass.newInstance();

// Define internal params
module_name = 'star'

// Specify DSL2
nextflow.preview.dsl = 2

// Define default nextflow internals
params.internal_outdir = params.outdir
params.internal_process_name = 'star'

// STAR parameters
params.internal_custom_args = ''

// Check if globals need to 
nfUtils.check_internal_overrides(module_name, params)

// Trimming reusable component
process star {
    tag "${sample_id}"

    publishDir "${params.internal_outdir}/${params.internal_process_name}",
        mode: "copy", overwrite: true

    input:
      tuple val(sample_id), path(reads), path(star_index)

    output:
      tuple val(sample_id), path("*Aligned.*.out.*"), emit: bamFiles
      tuple val(sample_id), path("*SJ.out.tab"), emit: sjFiles
      tuple val(sample_id), path("*Log.final.out"), emit: finalLogFiles
      tuple val(sample_id), path("*Log.out"), emit: outLogFiles
      tuple val(sample_id), path("*Log.progress.out"), emit: progressLogFiles
      path "*Log.final.out", emit: report

    shell:
    
    // Set the main arguments
    star_args = ''
    star_args += "--genomeDir $star_index "
    star_args += "--readFilesIn $reads "

    // Combining the custom arguments and creating star args
    star_args += "$params.internal_custom_args "

    // Ouput prefix the files with the file name
    output_prefix = reads.simpleName

    // Set memory constraints
    avail_mem = task.memory ? "--limitGenomeGenerateRAM ${task.memory.toBytes() - 100000000}" : ''
    avail_mem += task.memory ? " --limitBAMsortRAM ${task.memory.toBytes() - 100000000}" : ''
    
    """
    STAR $star_args --runThreadN ${task.cpus} --outFileNamePrefix ${output_prefix}. $avail_mem
    """
}
