#!/bin/bash

#SBATCH --mem=100m
#SBATCH -o slurm-%x_%A.out 
#SBATCH -p short

echo "concatenate FASTA files"
date

outputFASTA=bpgv2_minigraph_linearisedRef.fasta

cat *.fasta > $outputFASTA

echo "extract sequence stats"
seqkit stats $outputFASTA > $outputFASTA.stats

echo "done"
date