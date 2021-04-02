// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

// TODO nf-core: A module file SHOULD only define input and output files as command-line parameters.
//               All other parameters MUST be provided as a string i.e. "options.args"
//               where "params.options" is a Groovy Map that MUST be provided via the addParams section of the including workflow.
//               Any parameters that need to be evaluated in the context of a particular sample
//               e.g. single-end/paired-end data MUST also be defined and evaluated appropriately.
// TODO nf-core: Software that can be piped together SHOULD be added to separate module files
//               unless there is a run-time, storage advantage in implementing in this way
//               e.g. it's ok to have a single module for bwa to output BAM instead of SAM:
//                 bwa mem | samtools view -B -T ref.fasta
// TODO nf-core: Optional inputs are not currently supported by Nextflow. However, "fake files" MAY be used to work around this issue.

params.options = [:]
options        = initOptions(params.options)

process HIFIASM {
    tag "$meta.id"
    label 'process_high'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), publish_id:meta.id) }

    conda (params.enable_conda ? "bioconda::hifiasm=0.14" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/hifiasm:0.14--h2e03b76_1"
    } else {
        container "quay.io/biocontainers/hifiasm:0.14--h2e03b76_1"
    }

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*.r_utg.gfa")        , emit: raw_unitigs
    tuple val(meta), path("*.p_utg.gfa")        , emit: processed_unitigs, optional: true
    tuple val(meta), path("*.asm.p_ctg.gfa")    , emit: primary_contigs, optional: true
    tuple val(meta), path("*.asm.a_ctg.gfa")    , emit: alternate_contigs, optional: true
    tuple val(meta), path("*.hap1.p_ctg.gfa")   , emit: paternal_contigs, optional: true
    tuple val(meta), path("*.hap2.p_ctg.gfa")   , emit: maternal_contigs, optional: true
    tuple val(meta), path("*.ec.bin")           , emit: corrected_reads
    tuple val(meta), path("*.ovlp.source.bin")  , emit: source_overlaps
    tuple val(meta), path("*.ovlp.reverse.bin") , emit: reverse_overlaps
    path  "*.version.txt"                       , emit: version

    script:
    def software = getSoftwareName(task.process)
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"

    // Adding soft-links to original FastQs for consistent naming in a workflow
    """
    [ ! -f  ${prefix}.fastq.gz ] && ln -s ${reads} ${prefix}.fastq.gz


    hifiasm $options.args \\
        -o ${prefix}.asm \\
        -t $task.cpus \\
        ${prefix}.fastq.gz

    hifiasm --version > ${software}.version.txt || exit 0
    """
}
