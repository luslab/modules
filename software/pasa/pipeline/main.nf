// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process PASA_PIPELINE {
    tag "$meta.id"
    label 'process_medium'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), meta:meta, publish_by_meta:['id']) }

    conda (params.enable_conda ? "bioconda::pasa=2.4.1" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/pasa:2.4.1--h1b792b2_1"
    } else {
        container "quay.io/biocontainers/pasa:2.4.1--h1b792b2_1"
    }

    input:
    tuple val(meta), path(transcripts), path(genome)

    output:
    tuple val(meta), path("trainingSetComplete.gff3"), emit: gff3
    path "*.version.txt"                             , emit: version

    script:
    def software = getSoftwareName(task.process)
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    """
    # See:
    # Hoff, K. J., & Stanke, M. (2019). Predicting genes in single genomes with AUGUSTUS.
    # Current Protocols in Bioinformatics, 65, e57. doi: 10.1002/cpbi.57
    #
    # MIN_PERCENT_ALIGNED and MIN_AVG_PER_ID are far from defaults,
    # but that is what AUGUSTUS uses...
    printf "DATABASE=\$(pwd)/sqliteDatabase\\n"                                   > alignAssembly.config
    printf "validate_alignments_in_db.dbi:--MIN_PERCENT_ALIGNED=0.8\\n"          >> alignAssembly.config
    printf "validate_alignments_in_db.dbi:--MIN_AVG_PER_ID=0.9\\n"               >> alignAssembly.config
    printf "validate_alignments_in_db.dbi:--NUM_BP_PERFECT_SPLICE_BOUNDARY=0\\n" >> alignAssembly.config
    printf "subcluster_builder.dbi:-m=50\\n"                                     >> alignAssembly.config

    # Unfortunately seqclean crashes in Nextflow...
    # /usr/local/opt/pasa-2.4.1/bin/seqclean $transcripts -c $task.cpus # Produces ${transcripts}.clean and ${transcripts}.cln

    # Unfortunately, gmap crashes in Nextflow...
    /usr/local/opt/pasa-2.4.1/Launch_PASA_pipeline.pl \\
        --config alignAssembly.config                 \\
        --create                                      \\
        --run                                         \\
        --genome ${genome}                            \\
        --transcripts ${transcripts}                  \\
        --ALIGNERS blat                               \\
        --CPU $task.cpus                              \\
        $options.args

        #--transcripts ${transcripts}.clean            \\
        #-T -u $transcripts}                           \\
        # --ALIGNERS blat,gmap                         \\

    /usr/local/opt/pasa-2.4.1/scripts/pasa_asmbls_to_training_set.dbi       \\
        --pasa_transcripts_fasta sqliteDatabase.assemblies.fasta            \\
        --pasa_transcripts_gff3  sqliteDatabase.pasa_assemblies.gff3

    grep complete sqliteDatabase.assemblies.fasta.transdecoder.cds  \\
        | perl -pe 's/>(\\S+).*/\$1/'                               \\
        > complete.orfs

    # Original grep -P command does not run on busybox...
    #    | grep -P "(\\tCDS\\t|\\texon\\t)" \\
    grep -F -f complete.orfs sqliteDatabase.assemblies.fasta.transdecoder.genome.gff3 \\
        | awk '\$3 == "CDS" || \$3 == "exon"'                                         \\
        | perl -pe 's/cds\\.//; s/\\.exon\\d+//;'                                     \\
        > trainingSetComplete.gff3

    mv trainingSetComplete.gff3 trainingSetComplete.temp.gff3

    cat trainingSetComplete.temp.gff3                   \\
        | perl -pe 's/\\t\\S*(asmbl_\\d+).*/\\t\$1/'    \\
        | sort -n -k 4                                  \\
        | sort -s -k 9                                  \\
        | sort -s -k 1,1                                \\
        > trainingSetComplete.gff3

    echo \$(/usr/local/opt/pasa-2.4.1/Launch_PASA_pipeline.pl --version 2>&1) | sed 's/^PASA version: //' > ${software}.version.txt
    """
}
