#!/bin/bash

#SBATCH --mem=40g
#SBATCH -o slurm-%x_%A.out  
#SBATCH --cpus-per-task=12

numPermutations=50

prefix=minigraph_76lines_combinedGraph

source activate pggb

echo "convert vg formatted graph to gfa"
date
vg convert \
--threads $SLURM_CPUS_PER_TASK \
--gfa-out \
$prefix.mod.vg \
> $prefix.gfa

echo "convert GFA to OG format"
date
odgi build \
--threads $SLURM_CPUS_PER_TASK \
--gfa $prefix.gfa \
--out $prefix.og

echo "done"
date
