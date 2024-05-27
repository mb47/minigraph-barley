#!/bin/bash

#SBATCH --partition=long
#SBATCH --mail-user=micha.bayer@hutton.ac.uk
#SBATCH --mail-type=END,FAIL
#SBATCH --array=1-5
#SBATCH --mem=50g
#SBATCH -o slurm-%x_%A_%a.out 
#SBATCH --cpus-per-task=32

# accessions and their files for download from the ENA
accessions[1]=ERR2766176
accessions[2]=SRR10200200
accessions[3]=SRR5197485
accessions[4]=SRR5197496
accessions[5]=SRR6281633

R1Files[1]=ftp.sra.ebi.ac.uk/vol1/fastq/ERR276/006/ERR2766176/ERR2766176_1.fastq.gz
R1Files[2]=ftp.sra.ebi.ac.uk/vol1/fastq/SRR102/000/SRR10200200/SRR10200200_1.fastq.gz
R1Files[3]=ftp.sra.ebi.ac.uk/vol1/fastq/SRR519/005/SRR5197485/SRR5197485_1.fastq.gz
R1Files[4]=ftp.sra.ebi.ac.uk/vol1/fastq/SRR519/006/SRR5197496/SRR5197496_1.fastq.gz
R1Files[5]=ftp.sra.ebi.ac.uk/vol1/fastq/SRR628/003/SRR6281633/SRR6281633_1.fastq.gz

R2Files[1]=ftp.sra.ebi.ac.uk/vol1/fastq/ERR276/006/ERR2766176/ERR2766176_2.fastq.gz
R2Files[2]=ftp.sra.ebi.ac.uk/vol1/fastq/SRR102/000/SRR10200200/SRR10200200_2.fastq.gz
R2Files[3]=ftp.sra.ebi.ac.uk/vol1/fastq/SRR519/005/SRR5197485/SRR5197485_2.fastq.gz
R2Files[4]=ftp.sra.ebi.ac.uk/vol1/fastq/SRR519/006/SRR5197496/SRR5197496_2.fastq.gz
R2Files[5]=ftp.sra.ebi.ac.uk/vol1/fastq/SRR628/003/SRR6281633/SRR6281633_2.fastq.gz


#linear reference sequence
refseq=./mapping_linearisedPanG/linearisedPanG/bpgv2_minigraph_linearisedRef.fasta

numMismatches=2

####################################################################
#STEP1: DATA DOWNLOAD
####################################################################

#do all the work locally on the node scratch space
workingDir=`pwd`
cd $TMPDIR

R1FileURL=${R1Files[SLURM_ARRAY_TASK_ID]}
R2FileURL=${R2Files[SLURM_ARRAY_TASK_ID]}

echo -e "\ndownloading R1 file from URL $R1FileURL"
date
R1FileName=`basename $R1FileURL`
echo "R1FileName = $R1FileName"
curl -o $R1FileName $R1FileURL

echo -e "\ndownloading R2 file from URL $R2FileURL"
date
R2FileName=`basename $R2FileURL`
echo "R2FileName = $R2FileName"
curl -o $R2FileName $R2FileURL

####################################################################
#STEP2: DECOMPRESS FILES
####################################################################

sample=${accessions[SLURM_ARRAY_TASK_ID]}

echo "uncompress R1 file"
date
pigz \
-c \
-d \
$R1FileName \
> $sample.R1.fastq

echo "uncompress R2 file"
date
pigz \
-c \
-d \
$R2FileName \
> $sample.R2.fastq


####################################################################
#STEP3: MAP READS TO LINEAR REFERENCE WITH BWA MEM
####################################################################

echo -e "\n========================================="
echo "mapping with BWA"
echo "start time `/bin/date`"
echo -e "========================================="
bwa mem \
$refseq \
$sample.R1.fastq \
$sample.R2.fastq \
-t $SLURM_CPUS_PER_TASK \
-R "@RG\tID:$sample\tSM:$sample\tPL:Illumina" \
2> $sample.bwa.log \
> $sample.sam

echo -e "\n========================================="
echo "convert SAM to BAM"
echo "start time `/bin/date`"
echo -e "========================================="
sambamba view \
--sam-input \
--format=bam \
-l 0 \
-t $SLURM_CPUS_PER_TASK \
-o $sample.unsorted.bam \
$sample.sam

echo -e "\n========================================="
echo "sort BAM"
echo "start time `/bin/date`"
echo -e "========================================="
sambamba sort \
--memory-limit=40GB  \
-t $SLURM_CPUS_PER_TASK \
-l 9 \
-o $sample.sorted.bam \
$sample.unsorted.bam 
	
echo -e "\n========================================="
echo "index final BAM file"
echo "start time `/bin/date`"
echo -e "========================================="
sambamba index \
-t $SLURM_CPUS_PER_TASK \
$sample.sorted.bam  

echo "generate stats"
date
samtools stats $sample.sorted.bam > $sample.sorted.bam.stats

echo -e "\nfilter for NM"
date
java \
utils.bam.FilterBAM_NM_CIGAR \
$sample.sam \
$sample.filtered.sam \
$numMismatches

echo -e "\nconvert filtered SAM to BAM"
date
samtools view \
-O BAM \
-o $sample.filtered.bam \
$sample.filtered.sam

echo -e "\nindex filtered BAM"
date
samtools index $sample.filtered.bam

echo -e "\ngenerate filtered BAM stats"
date
samtools stats $sample.filtered.bam > $sample.filtered.bam.stats

echo -e "\ncopy result files back to working dir"
date
cp $sample.sorted.bam* $workingDir
cp $sample.filtered.bam* $workingDir


# DONE ####################################################
echo -e "\nworkflow complete"
date










