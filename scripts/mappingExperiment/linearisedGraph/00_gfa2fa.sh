#!/bin/bash

#SBATCH --mem=4g
#SBATCH -o slurm-%x_%A_%a.out 
#SBATCH -p short
#SBATCH --array=1-7

dataDir=$1

chrom="chr"$SLURM_ARRAY_TASK_ID"H"

rgfaFile=$dataDir/$chrom/$chrom.rgfa

###############################################

echo "process chromosome $chrom"

outputFASTA=$chrom.fasta

echo "extract graph to FASTA format"
date

gfatools gfa2fa \
-s $rgfaFile \
> $outputFASTA

echo "extract sequence stats"
seqkit stats $outputFASTA > $outputFASTA.stats

echo "done"
date
