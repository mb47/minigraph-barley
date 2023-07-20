#!/bin/bash

#SBATCH --partition=short
#SBATCH --mem=20g
#SBATCH -o slurm-%x_%A.out 
#SBATCH --cpus-per-task=8

graphDir=$1

source activate vg

graph=$graphDir/minigraph_76lines_combinedGraph.vg

echo "compute stats for $graph"
date
vg stats \
--threads $SLURM_CPUS_PER_TASK \
--size \
--verbose \
--node-count \
--edge-count \
--length \
$graph \
> $graph.vgstats

echo "done"
date
