#!/bin/bash

#SBATCH --mem=20G
#SBATCH --partition=short
#SBATCH --array=1-8
#SBATCH -o slurm-%x_%A_%a.out 

accessions[1]=SAMEA110188926
accessions[2]=SAMEA110188973
accessions[3]=SAMEA110188974
accessions[4]=SAMEA110189204
accessions[5]=SAMEA110189409
accessions[6]=SAMEA110189484
accessions[7]=SAMEA110189575
accessions[8]=SAMEA110189649

sample=${accessions[SLURM_ARRAY_TASK_ID]}

sortedGam=$sample.sorted.gam

graphDir=$1
xgFileWholeGraph=minigraph_76lines_combinedGraph.xg

region="Barke#1#chr5H#0:450000000-500000000" 

################################

echo "load vg"
date
source activate vg

mkdir $sample
cd $sample

echo "extract chunk from GAM file"
date
vg chunk \
-x $graphDir/$xgFileWholeGraph \
-a $sortedGam \
-g \
-p $region \
-c 10 \
> $sample.vg

echo "done"
date


