// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

def VERSION = '3.4.0'

process AUGUSTUS_GFF2GB {
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
    tuple val(meta), path(fasta)
    path gxf

    output:
    tuple val(meta), path("*.genbank"), emit: genbank
    path "*.flanking_size.txt"        , emit: txt
    path "*.version.txt"              , emit: version

    script:
    def software = getSoftwareName(task.process)
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"

    """
    computeFlankingRegion.pl \\
        $gxf > ${prefix}.flanking_size.txt

    # This command excises the value needed from computeFlankingRegion.pl
    FLANKINGSIZE=\$(tail -n 1 *.flanking_size.txt | cut -d \" \" -f 5)

    gff2gbSmallDNA.pl \\
        $gxf \\
        $fasta \\
        \$FLANKINGSIZE \\
        ${prefix}.genbank

    echo $VERSION >${software}.version.txt
    """
}
