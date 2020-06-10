#!/usr/bin/env nextflow

// Include NfUtils
params.internal_classpath = "star/groovy/NfUtils.groovy"
Class groovyClass = new GroovyClassLoader(getClass().getClassLoader()).parseClass(new File(params.internal_classpath));
GroovyObject nfUtils = (GroovyObject) groovyClass.newInstance();

// Define internal params
module_name = 'map'

// Specify DSL2
nextflow.preview.dsl = 2

// Define default nextflow internals
params.internal_outdir = 'results'
params.internal_process_name = 'map'

// STAR parameters
params.internal_custom_args = ''

// Check if globals need to 
nfUtils.check_internal_overrides(module_name, params)

//--outfile name prefix
// Set to sample ID
params.internal_outfile_prefix_sampleid = true

//Switch for paired-end files 
params.internal_paired_end = false

// Trimming reusable component
process map {
    tag "${sample_id}"

    publishDir "star/map/${params.internal_outdir}/${params.internal_process_name}",
        mode: "copy", overwrite: true

    input:
      tuple val(sample_id), path(reads), /*path(reads2),*/ path(star_index)

    output:
      //tuple val(sample_id), path("*Aligned.*.out.*"), emit: bamFiles //output in work directory is sam format -> emit: samFiles?, and replace path by .sam*
      tuple val(sample_id), path("*.sam"), emit: samFiles
      tuple val(sample_id), path("*SJ.out.tab"), emit: sjFiles
      tuple val(sample_id), path("*Log.final.out"), emit: finalLogFiles
      tuple val(sample_id), path("*Log.out"), emit: outLogFiles
      tuple val(sample_id), path("*Log.progress.out"), emit: progressLogFiles
      path "*Log.final.out", emit: report

    shell:
    
    // Set the main arguments
    if (params.internal_paired_end){
      star_args = "--genomeDir $star_index --readFilesIn $reads $reads2 "
    } else {
      star_args = "--genomeDir $star_index --readFilesIn $reads "
    }

    // Combining the custom arguments and creating star args
    if (params.internal_custom_args){
      star_args += "$params.internal_custom_args "
    }

    //RunThread param
     star_args += "--runThreadN $task.cpus "

    //outfile name prefix
    if (params.internal_outfile_prefix_sampleid){
      star_args += "--outFileNamePrefix ${sample_id}. "
    }

    // Set memory constraints
    avail_mem = task.memory ? "--limitGenomeGenerateRAM ${task.memory.toBytes() - 100000000}" : ''
    avail_mem += task.memory ? " --limitBAMsortRAM ${task.memory.toBytes() - 100000000}" : ''
    star_args += avail_mem

    println star_args
    
    """
    STAR $star_args
    """
}
//STAR $star_args --runThreadN ${task.cpus} --outFileNamePrefix ${output_prefix}. $avail_mem