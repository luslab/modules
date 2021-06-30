// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process BEDTOOLS_GENOMECOV {
    tag "$meta.id"
    label 'process_medium'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:meta, publish_by_meta:['id']) }

    conda (params.enable_conda ? "bioconda::bedtools=2.30.0" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/bedtools:2.30.0--hc088bd4_0"
    } else {
        container "quay.io/biocontainers/bedtools:2.30.0--hc088bd4_0"
    }

    input:
    tuple val(meta), path(feature)
    path(chromosome_sizes)
    val output_extension

    output:
    tuple val(meta), path("*.${output_extension}"), emit: genomecov_out
    path  "*.version.txt"                         , emit: version

    script:
    def software = getSoftwareName(task.process)
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    if (feature.name =~ /\.bam/) {
        """
        bedtools \\
            genomecov \\
            -ibam $feature \\
            $options.args \\
            > ${prefix}.${output_extension}

        bedtools --version | sed -e "s/bedtools v//g" > ${software}.version.txt
        """
    } else {
        """
        bedtools \\
            genomecov \\
            -i $feature \\
            -g $chromosome_sizes \\
            $options.args \\
            > ${prefix}.${output_extension}

        bedtools --version | sed -e "s/bedtools v//g" > ${software}.version.txt
        """
    }
}
