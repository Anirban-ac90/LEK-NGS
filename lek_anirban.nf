nextflow.enable.dsl = 2
params.out = "${launchDir}"
params.storedir = "${baseDir}/cache"
params.url = null
//nextflow run ngs.nf -profile singularity

// Download the reference file
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
// Command in shell - wget "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=M21012.1&rettype=fasta

// Combining the 5 given fasta files with the reference genome file
process combinefastafiles {
  publishDir "${params.out}/output", mode: "copy", overwrite: true
    storeDir params.storedir
    input:
        path inputfile
    output:
      path "combined.fasta"
    """
    cat ${launchDir}/fasta/*.fasta > combined.fasta
    """
}
// Command in shell - cat fasta/*.fasta > fasta/all.fasta

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
// Command in shell - mafft all.fasta > output/mafft_output.fasta



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

//Command in shell - trimal -in ${infile} -out trimal.fasta -htmlout trimal.html -automated1
// The above command works perfectly fine in Singularity shell but not in command line as TRIMAL is not installed in our virtual machine, but MAFFT is installed
// So, we need to run it with -profile singularity command
// For example - nextflow run lek_anirban.nf -profile singularity

workflow {
  ref_fasta_channel = downloadFile()
  combined_fasta_channel = combinefastafiles(ref_fasta_channel)
  mafft_fasta_channel = mafft(combined_fasta_channel)
  trimal(mafft_fasta_channel)
}
