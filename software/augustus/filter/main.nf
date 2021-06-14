// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

def VERSION = '3.4.0'

process AUGUSTUS_FILTER {
    tag "$meta.id"
    label 'process_low'
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
    path model_txt

    output:
    tuple val(meta), path("*.filtered.genbank"), emit: genbank
    path "*.bad_genes.txt"      , emit: bad_genes_txt
    path "*.remaining_genes.txt", emit: remaining_genes_txt
    path "*.version.txt"        , emit: version

    script:
    def software = getSoftwareName(task.process)
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"

    """
    AUGUSTUS_CONFIG_PATH=$augustus_model

    # Get a list of bad genes so that they can be excluded.
    etraining \\
        --species=$species \\
        $genbank 2>&1 \\
        | grep "in sequence" \\
        | perl -pe 's/.*n sequence (\\S+):.*/\$1/' \\
        | sort -u > ${prefix}.bad_genes.txt

    # Exclude bad genes from the genbank file.
    filterGenes.pl \\
        ${prefix}.bad_genes.txt \\
        $model_txt > ${prefix}.filtered.genbank

    # Make sure that the filtered set does not exclude too many genes.
    grep \\
        -c LOCUS $genbank \\
        ${prefix}.filtered.genbank > ${prefix}.remaining_genes.txt

    echo $VERSION >${software}.version.txt
    """
}
