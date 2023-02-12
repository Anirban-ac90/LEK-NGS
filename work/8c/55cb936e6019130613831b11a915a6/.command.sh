#!/bin/bash -ue
# The accession M21012 is used - please adapt this to your needs,
wget "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=M21012.1&rettype=fasta" -O M21012.fasta
# adapt"{params.out}/fasta" to direct the reference file with folder containing the test files
