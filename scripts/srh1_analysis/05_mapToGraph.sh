#!/bin/bash

#SBATCH --partition=medium
#SBATCH --array=1-8
#SBATCH --mem=75g
#SBATCH -o slurm-%x_%A_%a.out 
#SBATCH --cpus-per-task=32

datadir=$1

accessions[1]=SAMEA110188926
accessions[2]=SAMEA110188973
accessions[3]=SAMEA110188974
accessions[4]=SAMEA110189204
accessions[5]=SAMEA110189409
accessions[6]=SAMEA110189484
accessions[7]=SAMEA110189575
accessions[8]=SAMEA110189649

sample=${accessions[SLURM_ARRAY_TASK_ID]}

R1File=$sample.R1.fastq
R2File=$sample.R2.fastq

#the graph file we want to map to
indexFileDir=$2
gbzFile=minigraph_76lines_combinedGraph.giraffe.gbz
distFile=minigraph_76lines_combinedGraph.dist
minFile=minigraph_76lines_combinedGraph.min

#do all the work locally on the node scratch space
workingDir=`pwd`
cd $TMPDIR

echo "job is running on $HOSTNAME"
echo "TMPDIR = $TMPDIR"
echo "processing sample $sample"

echo "copy data to local scratch space"
date
cp -v $datadir/$R1File .
cp -v $datadir/$R2File .

source activate vg

echo -e "\nmap reads with giraffe"
date
vg giraffe \
--threads $SLURM_CPUS_PER_TASK  \
--gbz-name $indexFileDir/$gbzFile \
--minimizer-name $indexFileDir/$minFile \
--dist-name $indexFileDir/$distFile \
--fastq-in $R1File \
--fastq-in $R2File \
> $sample.gam

echo "compute stats for GAM file"
date
vg stats -a $sample.gam > $sample.gam.stats

echo "copy result files back to working dir"
date
cp $sample.gam* $workingDir


# DONE ####################################################
echo -e "\nworkflow complete"
date










