// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

def VERSION = '3.4.0'

process AUGUSTUS_TRAIN {
    tag "$meta.id"
    label 'process_medium'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:meta, publish_by_meta:['id']) }

    conda (params.enable_conda ? "bioconda::augustus=3.4.0" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/augustus:3.4.0--pl5262hb677c0c_1"
    } else {
        container "quay.io/biocontainers/augustus:3.4.0--pl5262hb677c0c_1"
    }

    input:
    tuple val(meta), path(genbank)
    tuple val(species), path(augustus_model)

    output:
    tuple val(species), path("config/"), emit: augustus_model
    path "*.model.txt"      , emit: model_txt
    path "*.non_standard_genes.txt", emit: nonstandard_txt
    path "*.stop_codon_freq.txt", emit: stop_txt
    path "*.version.txt"    , emit: version

    script:
    def software = getSoftwareName(task.process)
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"

    """
    export AUGUSTUS_CONFIG_PATH=\$(pwd)/config

    # Train a model.
    etraining --species=$species $genbank > ${prefix}.model.txt

    # Note non-standard gene structures.
    # N.B. - The funny grep syntax is to prevent raising exit code 1 on no match.
    cat ${prefix}.model.txt \\
        | { grep -c "Variable stopCodonExcludedFromCDS set right" || true; } \\
        > ${prefix}.non_standard_genes.txt

    # Note stop codon frequencies.
    tail -n 6  ${prefix}.model.txt \\
        | head -n 3 \\
        > ${prefix}.stop_codon_freq.txt

    echo $VERSION >${software}.version.txt
    """
}
