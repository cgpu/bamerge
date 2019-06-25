// Input channel, fromPath it retrieves all objects of type 'file'
input_files_channel_ = Channel.fromPath(params.annotation_filepath)
                                    .ifEmpty { exit 1, "Annotation file not found: ${params.annotation_filepath}" }
                                    .splitCsv(sep: ',', skip: 1)
                                    .map{ labNo, filename -> [labNo,  file(filename)] }
                                    .groupTuple()

process samtools_merge_bams {

    tag "$labNo"
    publishDir "results", mode: 'copy'
    container 'lifebitai/samtools:latest'

    input:
    set val(labNo), file('*.bam') from input_files_channel_

    output:
    file "${labNo}.merged.bam" into nowhere_channel

    when: params.tool.toLowerCase().contains("samtools")

    script:
    """
    samtools merge "${labNo}.merged.bam" *.bam 
    """
}

process sambamba_merge_bams {

    tag "$labNo"
    publishDir "results", mode: 'copy'
    container 'lifebitai/samtools:latest'

    input:
    set val(labNo), file('*.bam') from input_files_channel_

    output:
    file "${labNo}.merged.bam" into nowhere_channel

    when: params.tool.toLowerCase().contains("sambamba")

    script:
    """
    sambamba-merge "${labNo}.merged.bam" *.bam 
    """
}
