// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

def VERSION = '3.4.0'

process AUGUSTUS_COPYMODEL {
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
    tuple val(species), path("config/"), emit: augustus_model
    path "*.version.txt", emit: version

    script:
    def software = getSoftwareName(task.process)

    """
    # Copy the species files out of the location in the AUGUSTUS image. I have no idea how this will work with conda.
    # It looks like the AUGUSTUS config path is not even present in the bioconda installation?
    mkdir -p config/species/$species
    cp -r /usr/local/config/species/$species ./config/species/

    echo $VERSION >${software}.version.txt
    """
}
