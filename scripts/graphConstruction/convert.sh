#!/bin/bash

#SBATCH --mem=15G
#SBATCH -o slurm-%x_%A_%a.out 
#SBATCH --cpus-per-task=12
#SBATCH --partition short
#SBATCH --array=1-7

graphDir=$1

chrom="chr"$SLURM_ARRAY_TASK_ID"H"

inputGFA=$graphDir/$chrom/$chrom.withPaths.gfa

source activate vg

echo "convert minigraph GFA file for chrom $chrom to vg format"
date
vg convert \
--gfa-in \
--vg-out \
--threads $SLURM_CPUS_PER_TASK \
$inputGFA \
> $chrom.vg

echo "done"
date
