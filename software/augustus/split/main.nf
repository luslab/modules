// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

def VERSION = '3.4.0'

process AUGUSTUS_SPLIT {
    tag '$augustus'
    label 'process_low'
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
    path genbank
    val split_size

    output:
    path "*.train.genbank", emit: train_genbank
    path "*.test.genbank" , emit: test_genbank
    path "*.version.txt"  , emit: version

    script:
    def software = getSoftwareName(task.process)

    """
    AUGUSTUS_CONFIG_PATH=$augustus_model

    randomSplit.pl \\
        ${prefix}.initial_model.filtered.genbank \\
        $split_size

    mv ${prefix}.genbank.test  ${prefix}.test.genbank
    mv ${prefix}.genbank.train ${prefix}.train.genbank

    echo $VERSION >${software}.version.txt
    """
}
