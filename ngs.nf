nextflow.enable.dsl = 2
params.out = "${launchDir}"
params.storedir = "${baseDir}/cache"
params.url = null
//nextflow run ngs.nf -profile singularity

process downloadFile {
    publishDir "${params.out}/fasta", mode: "copy", overwrite: true
    storeDir params.storedir

    output:
        path "M21012.fasta"
    """
    # The accession M21012 is used - please adapt this to your needs,
    wget "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=M21012.1&rettype=fasta" -O M21012.fasta
    # adapt"{params.out}/fasta" to direct the reference file with folder containing the test files
    """
}

process combinefastafiles {
  publishDir "${params.out}/output", mode: "copy", overwrite: true
    storeDir params.storedir
    input:
        path inputfile
    output:
      path "all.fasta"
    """
    cat ${launchDir}/fasta/*.fasta > all.fasta
    """
}
//cat fasta/*.fasta > fasta/all.fasta

process mafft {
  publishDir "${params.out}/output", mode: "copy", overwrite: true
  container "https://depot.galaxyproject.org/singularity/mafft%3A7.515--hec16e2b_0"
    input:
      path fastafile
    output:
      path "mafft.fasta"
      """
      mafft ${fastafile} > mafft.fasta
      """
}
//mafft all.fasta > output/mafft_output.fasta



process trimal {
  publishDir "${params.out}/output", mode: "copy", overwrite: true
  container "https://depot.galaxyproject.org/singularity/trimal%3A1.4.1--h9f5acd7_6"
  input:
    path infile
  output:
    path "*"
    """
    trimal -in ${infile} -out trimal.fasta -htmlout trimal.html -automated1
    """
}


//output: path "*.fastq"

//(base) cq@bioinfobox:~/nextflow/ngs/work/07/8441fb033222334ff7de945f209429$ cat .command.sh
//#!/bin/bash -ue
//trimal -in mafft.fasta -out trimal_output.fasta -fasta -type -format


//readal -in ${infile} -type -format # Gets information from a given alignment
//readal -in mafft.fasta -out trimal_output.fasta -fasta -type -format
//## Input filename	'mafft.fasta'
//## Input file format	fasta
//## Input file aligned	YES
//## Input file datatype	nucleotides:dna_degenerate_codes
// trimal -in ${infile} -out trimal.fasta -htmlout trimal.html -automated1

workflow {
  ref_test_fasta_channel = downloadFile()
  combined_fasta_channel = combinefastafiles(ref_test_fasta_channel)
  mafft_aligned_fasta_channel = mafft(combined_fasta_channel)
  trimal(mafft_aligned_fasta_channel)
}
