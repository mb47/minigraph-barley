#!/bin/bash

#SBATCH --partition=short
#SBATCH --array=1-7
#SBATCH --mem=4g
#SBATCH -o slurm-%x_%A_%a.out 
#SBATCH --cpus-per-task=8

graphDir=$1

source activate vg

graph=$graphDir/"chr"$SLURM_ARRAY_TASK_ID"H.vg"

echo "compute stats for $graph"
date
vg stats \
--size \
--verbose \
--node-count \
--edge-count \
--length \
$graph \
> $graph.vgstats

echo "done"
date
