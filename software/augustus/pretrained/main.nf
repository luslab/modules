// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

def VERSION = '3.4.0'

process AUGUSTUS_PRETRAINED {
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
    val species
    path augustus_species_model

    output:
    tuple val(species), path("config/"), emit: augustus_model
    path "*.version.txt", emit: version

    script:
    def software = getSoftwareName(task.process)

    """
    # Copy config files out of the location in the AUGUSTUS image.
    mkdir config
    cp -r /usr/local/config/cgp       config
    cp -r /usr/local/config/extrinsic config
    cp -r /usr/local/config/model     config
    cp -r /usr/local/config/profile   config

    mkdir -p config/species
    cp -r $augustus_species_model config/species/$species

    echo $VERSION >${software}.version.txt
    """
}
