// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

def VERSION = '3.4.0'

process AUGUSTUS_OPTIMIZE {
    tag '$augustus'
    label 'process_medium'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:[:], publish_by_meta:[]) }

    conda (params.enable_conda ? "bioconda::augustus=3.4.0" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/augustus:3.4.0--pl5262hb677c0c_1"
    } else {
        container "quay.io/biocontainers/augustus:3.4.0--pl5262hb677c0c_1"
    }

    input:
    path augustus_model
    val species
    path genbank

    output:
    path "config/"                   , emit: augustus_model
    val species
    path "*.optimized_metaparams.txt", emit: txt
    path "*.version.txt"             , emit: version

    script:
    def software = getSoftwareName(task.process)

    """
    AUGUSTUS_CONFIG_PATH=$augustus_model

    # This script optimizes the metaparameters of the AUGUSTUS model.
    # This should only be ran on the training set, not any old genbank file.
    optimize_augustus.pl \\
        $options.args \\
        --cpus=$task.cpus \\
        --species=$species \\
        $genbank > ${prefix}.optimized_metaparams.txt

    echo $VERSION >${software}.version.txt
    """
}
