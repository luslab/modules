// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process HIFIASM {
    tag "$meta.id"
    label 'process_high'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), publish_id:meta.id) }

    conda (params.enable_conda ? "bioconda::hifiasm=0.14" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/hifiasm:0.14--h2e03b76_1"
    } else {
        container "quay.io/biocontainers/hifiasm:0.14--h2e03b76_1"
    }

    input:
    tuple val(meta), path(reads)
    path hic_reads
    path paternal_kmer_dump
    path maternal_kmer_dump
    val use_hic_reads
    val use_parental_kmers

    output:
    tuple val(meta), path("*.r_utg.gfa")        , emit: raw_unitigs
    tuple val(meta), path("*.p_utg.gfa")        , emit: processed_unitigs, optional: true
    tuple val(meta), path("*.asm.p_ctg.gfa")    , emit: primary_contigs, optional: true
    tuple val(meta), path("*.asm.a_ctg.gfa")    , emit: alternate_contigs, optional: true
    tuple val(meta), path("*.hap1.p_ctg.gfa")   , emit: paternal_contigs, optional: true
    tuple val(meta), path("*.hap2.p_ctg.gfa")   , emit: maternal_contigs, optional: true
    tuple val(meta), path("*.ec.bin")           , emit: corrected_reads
    tuple val(meta), path("*.ovlp.source.bin")  , emit: source_overlaps
    tuple val(meta), path("*.ovlp.reverse.bin") , emit: reverse_overlaps
    path  "*.version.txt"                       , emit: version

    script:
    def software = getSoftwareName(task.process)
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"

    if (use_hic_reads) {
        """
        # Adding soft-links to original FastQs for consistent naming in a workflow
        [ ! -f  ${prefix}.fastq.gz ] && ln -s ${reads} ${prefix}.fastq.gz

        hifiasm $options.args \\
            -o ${prefix}.asm \\
            -t $task.cpus \\
            --h1 ${hic_reads[0]} \\
            --h2 ${hic_reads[1]} \\
            ${prefix}.fastq.gz
        
        hifiasm --version > ${software}.version.txt || exit 0
        """
    } else if (use_parental_kmers) {
        """
        # Adding soft-links to original FastQs for consistent naming in a workflow
        [ ! -f  ${prefix}.fastq.gz ] && ln -s ${reads} ${prefix}.fastq.gz

        hifiasm $options.args \\
            -o ${prefix}.asm \\
            -t $task.cpus \\
            -1 $paternal_kmer_dump \\
            -2 $maternal_kmer_dump \\
            ${prefix}.fastq.gz
        
        hifiasm --version > ${software}.version.txt || exit 0
        """
    } else {
        """
        # Adding soft-links to original FastQs for consistent naming in a workflow
        [ ! -f  ${prefix}.fastq.gz ] && ln -s ${reads} ${prefix}.fastq.gz

        hifiasm $options.args \\
            -o ${prefix}.asm \\
            -t $task.cpus \\
            ${prefix}.fastq.gz

        hifiasm --version > ${software}.version.txt || exit 0
        """
    }
}
