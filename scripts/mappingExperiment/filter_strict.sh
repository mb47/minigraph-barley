#!/bin/bash

#SBATCH --partition=medium
#SBATCH --array=1-5
#SBATCH --mem=3g
#SBATCH -o slurm-%x_%A_%a.out 
#SBATCH --cpus-per-task=32

# accessions from the ENA
accessions[1]=ERR2766176
accessions[2]=SRR10200200
accessions[3]=SRR5197485
accessions[4]=SRR5197496
accessions[5]=SRR6281633

sample=${accessions[SLURM_ARRAY_TASK_ID]}
dataDir=$1
bamUnfiltered=$sample.sorted.bam

#do all the work locally on the node scratch space
workingDir=`pwd`
cd $TMPDIR

echo "job is running on $HOSTNAME"
echo "tmp dir = $TMPDIR"
echo "copy input BAM file to tmp dir"
date
cp $dataDir/$bamUnfiltered $TMPDIR


echo -e "\nfilter for NM"
date
sambamba view \
--nthreads=$SLURM_CPUS_PER_TASK  \
--format=bam \
-l 9 \
--filter="[NM] == 0" \
-o $sample.filtered.bam \
$bamUnfiltered

echo -e "\nindex filtered BAM"
date
samtools index -c $sample.filtered.bam

echo -e "\ngenerate filtered BAM stats"
date
samtools stats $sample.filtered.bam > $sample.filtered.bam.stats

echo -e "\ncopy result files back to working dir"
date
cp $sample.filtered.bam* $workingDir


# DONE ####################################################
echo -e "\nworkflow complete"
date










