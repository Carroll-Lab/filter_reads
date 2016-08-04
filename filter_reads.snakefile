#Needs python=3.5 snakemake bowtie2 samtools picard fastx_toolkit
#conda create --name UQCbioinf16 python=3.5 snakemake bowtie2 samtools picard fastx_toolkit
#source activate UQCbioinf16
#raw fastq file in /seq_raw
#genome reference (fasta) in /genome

#Check adapter - could be TGGAATTCT or AGATCGGAAGAGCAC

IDS, = glob_wildcards("seq_raw/{id}.fastq")
refs, = glob_wildcards("genome/{ref}.fa")

rule all:
	input: 
		expand("filtered/{id}.{genome}.fa", id=IDS, genome=refs)

rule trim_collapse:
    input:
        "seq_raw/{id}.fastq"
    output:
        "clipped_fq/{id}_clipped.fastq"
    shell:
        "fastx_clipper -i {input} -a TGGAATTCT -c -l 18 -Q33 -o {output}"

rule index_ref:
	input:
		in_ref="genome/{genome}.fa"
	output: 
		outfa="genome/{genome}"
	run:
		shell("bowtie2-build -f {input.in_ref} {output.outfa}"),
		shell("touch {output.outfa}")

rule align:
	input:
		index = "genome/{genome}",
		fq = "clipped_fq/{id}_clipped.fastq"
	output:
		"aligned/{id}.{genome}.bam"
	threads: 12
	shell:
		"bowtie2 -x {input.index} -p {threads} -U {input.fq} | samtools view -@ {threads} -bS -F 4 - | samtools sort -@ {threads} - > {output}"

rule list_reads:
	input:
		"aligned/{id}.{genome}.bam"
	output:
		"mapped/{id}.{genome}.fastq"
	shell:
		"picard SamToFastq I={input} F={output}"


rule collapse:
	input:
		"mapped/{id}.{genome}.fastq"
	output:
		"filtered/{id}.{genome}.fa"
	shell:
		"fastq_to_fasta -Q33 -i {input}| fastx_collapser -o {output} -Q33"
