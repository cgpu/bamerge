// Params to be migrated to nextflow.config file soon
params.annotation_filepath     = false

// Input channel, fromPath it retrieves all objects of type 'file'
input_input_files_channel_ = Channel.fromPath(params.annotation_filepath)
                                    .ifEmpty { exit 1, "Annotation file not found: ${params.annotation_filepath}" }
                                    .splitCsv(sep: ',', skip: 1)
                                    .map{ labNo, filename -> [labNo,  file(filename)] }
                                    .groupTuple()

// ToDo: Redirect stdout of all files in one sha256sum.txt output file using bash >> append operator
process merge_bams {

    tag "$labNo"
    publishDir "results", mode: 'copy'
    container 'lifebitai/samtools:latest'

    input:
    set val(labNo), file('*.bam') from input_input_files_channel_

    output:
    file "${labNo}.merged.bam" into nowhere_channel

    script:
    """
    samtools merge "${labNo}.merged.bam" *.bam 
    """
}

