// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process HIFIASM {
    tag "$meta.id"
    label 'process_high'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), publish_id:'') }

    conda (params.enable_conda ? "bioconda::hifiasm=0.14" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/hifiasm:0.14--h8b12597_0"
    } else {
        container "quay.io/biocontainers/hifiasm:0.14--h8b12597_0"
    }

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*.asm.p_ctg.gfa") , emit: primary_contigs
    tuple val(meta), path("*.asm.a_ctg.gfa") , emit: alternate_contigs
    path  "*.version.txt"                    , emit: version

    script:
    // Add soft-links to original FastQs for consistent naming in pipeline
    def software = getSoftwareName(task.process)
    def prefix   = options.suffix ? "${meta.id}.${options.suffix}" : "${meta.id}"

    """
    [ ! -f  ${prefix}.fastq.gz ] && ln -s ${reads} ${prefix}.fastq.gz
    hifiasm $options.args -o ${prefix}.asm -t $task.cpus ${prefix}.fastq.gz
    hifiasm --version > ${software}.version.txt || exit 0
    """
}
