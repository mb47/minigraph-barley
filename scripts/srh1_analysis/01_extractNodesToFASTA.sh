#!/bin/bash

#SBATCH -o slurm-%x_%A.out 
#SBATCH --mem=1g
#SBATCH -p short


gfaFile=minigraph_76lines_combinedGraph.gfa

prefix=minigraph_76lines_combinedGraph_nodes

echo "extract nodes"
date

grep "^S"  $gfaFile \
| cut -f1,2,3 \
| sed 's/S\t/>/g'  \
| tr '\t' '\n' \
> $prefix.fasta

echo "done converting"
date

echo "count number of nodes extracted:"
grep -c ">" $prefix.fasta

echo "build BLAST DB"
date
source activate blast
makeblastdb -in $prefix.fasta -dbtype nucl

echo "done"
date