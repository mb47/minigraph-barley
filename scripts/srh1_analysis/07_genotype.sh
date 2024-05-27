#!/bin/bash

#SBATCH --mem=3g
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


gamFile=chunk_0_Barke#1#chr5H#0_449993002_500007959.gam

echo "load vg"
date
source activate vg

cd $sample

echo "compute a compressed coverage index from the alignment"
date
vg pack \
--xg $sample.vg \
--gam $gamFile \
-Q 5 \
-o $sample.graph.pack


echo "run the genotyper over the coverage index"
date
vg call \
-k $sample.graph.pack \
--ref-path Barke#1#chr5H#0 \
$sample.vg \
> $sample.vcf


echo "done"
date


