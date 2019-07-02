// Input channel, fromPath it retrieves all objects of type 'file'
input_files_channel_ = Channel.fromPath(params.annotation_filepath)
                              .ifEmpty { exit 1, "Annotation file not found: ${params.annotation_filepath}" }
                              .splitCsv(sep: ',', skip: 1)
                              .map{ unique_sample_id, filepath -> [unique_sample_id,  file(filepath)] }
                              .groupTuple()


process samtools_merge_bams {

    tag "$unique_sample_id"
    publishDir "results", mode: 'copy'    
    container 'lifebitai/samtools:latest'

    input:
    set val(unique_sample_id), file('*.bam') from input_files_channel_

    output:
    file "${unique_sample_id}.merged.bam" into nowhere_channel

    when: params.tool.toLowerCase().contains("samtools")

    script:
    """
    samtools merge "${unique_sample_id}.merged.bam" *sorted.bam 
    """
}

process sambamba_merge_bams {

    tag "$unique_sample_id"
    publishDir "results", mode: 'copy'
    container 'btrspg/sambamba:0.6.9-v1.0.1dev-prd'

    input:
    set val(unique_sample_id), file('*.bam') from input_files_channel_

    output:
    file "${unique_sample_id}.merged.bam" into nowhere_channel

    when: params.tool.toLowerCase().contains("sambamba")

    script:
    """
    sambamba merge "${unique_sample_id}.merged.bam" *.bam 
    """
}
