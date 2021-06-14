// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

def VERSION = '3.4.0'

process AUGUSTUS_NEWSPECIES {
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

    output:
    path "config/"      , emit: augustus_model
    val species
    path "*.version.txt", emit: version

    script:
    def software = getSoftwareName(task.process)

    """
    # Copy config files out of the location in the AUGUSTUS image.
    mkdir config
    cp -a /usr/local/config/cgp       config
    cp -a /usr/local/config/extrinsic config
    cp -a /usr/local/config/model     config
    cp -a /usr/local/config/profile   config

    # Copy the generic templating files out of the location in the AUGUSTUS image.
    mkdir -p config/species/generic
    cp -a /usr/local/config/species/generic config/species
    # Then, set environmental variable to ensure the new_species.pl script writes
    # the new species model to the current working directory instead of
    # /usr/local/config/.
    AUGUSTUS_CONFIG_PATH=\$(pwd)/config

    new_species.pl \\
        --species=$species

    echo $VERSION >${software}.version.txt
    """
}
