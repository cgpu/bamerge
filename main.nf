// set threadmem equal to total memory divided by number of threads
int threads    = Runtime.getRuntime().availableProcessors()
threadmem      = (((Runtime.getRuntime().maxMemory() * 4) / threads) as nextflow.util.MemoryUnit)

// More memory for samtools processes
threadmem_more = 4 * threadmem

// Added soft-coded method but hard-coded value of cpu-sage percentage for compute intensive process
// ToDo: Expose the hard-coded value as parameter if needed in the future for user to allocate resources at will

// Declaring percentage of total cpus (aka 'threads' var) to be allocated to compute intensive process
cpu_percentage = 1

// Multiplying & converting java.math.BigDecimal object to java.lang.Integer
// Check object type with 'my_object.getClass()' method
// More info here: https://www.geeksforgeeks.org/bigdecimal-intvalue-method-in-java/
cpus_to_use_samtools    = (cpu_percentage * threads).intValue()

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

    // Allocate cpus to be utilised in this process
    cpus cpus_to_use_samtools

    input:
    set val(shared_sample_id), file('*.bam') from input_files_channel_samtools_

    output:
    file "${shared_sample_id}.merged.bam" into nowhere_channel_samtools

    when: params.tool.toLowerCase().contains("samtools")

    script:
    """
    samtools merge "${shared_sample_id}.merged.bam" *.bam 
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
