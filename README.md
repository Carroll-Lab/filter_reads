# filter_reads
Snakemake workflow : retains small RNA reads that align to a reference sequence (ie. a genome + transgene)

Needs python=3.5 snakemake bowtie2 samtools picard fastx_toolkit
conda create --name UQCbioinf16 python=3.5 snakemake bowtie2 samtools picard fastx_toolkit
source activate UQCbioinf16
raw fastq file in /seq_raw
genome reference (fasta) in /genome

Check adapter - could be TGGAATTCT or AGATCGGAAGAGCAC
