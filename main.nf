// Input channel, fromPath it retrieves all objects of type 'file'
input_files_channel_ = Channel.fromPath(params.input_files_list)
                              .ifEmpty { exit 1, "Input BAM files .csv list file not found: ${params.input_files_list}" }
                              .splitCsv(sep: ',', skip: 1)
                              .map{ shared_sample_id, filepath -> [shared_sample_id,  file(filepath)] }
                              .groupTuple()
                              .into { input_files_channel_samtools_; input_files_channel_sambamba_}


process samtools_merge_bams {

    tag "$shared_sample_id"
    publishDir "results", mode: 'copy'    
    container 'lifebitai/samtools:latest'

    input:
    set val(shared_sample_id), file('*.bam') from input_files_channel_samtools_

    output:
    file "${shared_sample_id}.merged.bam" into nowhere_channel_samtools

    when: params.tool.toLowerCase().contains("samtools")

    script:
    """
    samtools merge "${shared_sample_id}.merged.bam" *sorted.bam 
    """
}

process sambamba_merge_bams {

    tag "$shared_sample_id"
    publishDir "results", mode: 'copy'
    container 'btrspg/sambamba:0.6.9-v1.0.1dev-prd'

    input:
    set val(shared_sample_id), file('*.bam') from input_files_channel_sambamba_

    output:
    file "${shared_sample_id}.merged.bam" into nowhere_channel_sambamba

    when: params.tool.toLowerCase().contains("sambamba")

    script:
    """
    sambamba merge "${shared_sample_id}.merged.bam" *.bam 
    """
}
