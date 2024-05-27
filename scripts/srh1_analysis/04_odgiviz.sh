#!/bin/bash

#SBATCH -o slurm-%x_%A.out 
#SBATCH --mem=1g
#SBATCH -p short

prefix=subgraph_srh1Region

source activate odgi

echo "plot"
date
odgi viz \
--height=600 \
--width=1000 \
-i $prefix.opt.sorted.og \
-o $prefix.png \
--paths-to-display pathsOrderedBySRH1Phenotype.txt


echo "done"
date