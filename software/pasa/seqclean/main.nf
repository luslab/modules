// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process PASA_SEQCLEAN {
    tag "$meta.id"
    label 'process_low'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:meta, publish_by_meta:['id']) }

    conda (params.enable_conda ? "bioconda::pasa=2.4.1" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/pasa:2.4.1--h1b792b2_1"
    } else {
        container "quay.io/biocontainers/pasa:2.4.1--h1b792b2_1"
    }

    input:
    tuple val(meta), path(transcripts)

    output:
    tuple val(meta), path("*.clean"), emit: fasta
    tuple val(meta), path("*.cln")  , emit: txt
    path "*.version.txt"            , emit: version

    script:
    def software = getSoftwareName(task.process)
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    """
    # seqclean will crash mysteriously if $USER is not set!
    USER="needs-to-be-set" /usr/local/opt/pasa-2.4.1/bin/seqclean \\
        $transcripts \\
        -c $task.cpus

    # seqclean does not have a --version switch of its own
    echo \$(/usr/local/opt/pasa-2.4.1/Launch_PASA_pipeline.pl --version 2>&1) | sed 's/^PASA version: //' > ${software}.version.txt
    """
}
