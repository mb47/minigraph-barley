#!/bin/bash

#SBATCH --mem=20g
#SBATCH -o slurm-%x_%A.out 
#SBATCH -p long

inputFASTA=bpgv2_minigraph_linearisedRef.fasta

echo "index FASTA file"
date

bwa index $inputFASTA

echo "done"
date
