#!/bin/bash

#SBATCH -o slurm-%x_%A.out   
#SBATCH --mem=1m

outputFileINV=simpleINV.bed
outputFileINS=simpleINS.bed
outputFileDEL=simpleDEL.bed
jointOutputFile=simpleSVsByType.txt


#loop over all the chromosomes 
for i in {1..7}
do
	chrom="chr"$i"H"
	echo "chrom = $chrom"
	
	echo "extract simple INV"
	#the last BED file to be produced (after addition of the last line to the graph) contains the final set of SVs
	awk '$6==1 && $5==2 && $7==$8' ../../$chrom/SVs.bubble.HOR_4224.75.bed | cut -f 1-8 >> $outputFileINV

	echo "extract simple INS"
	awk '$6==0 && $5==2 && $2==$3' ../../$chrom/SVs.bubble.HOR_4224.75.bed | cut -f 1-8 >> $outputFileINS
	
	echo "extract simple DEL"
	awk '$6==0 && $5==2 && $2<$3' ../../$chrom/SVs.bubble.HOR_4224.75.bed | cut -f 1-8 >> $outputFileDEL

done

echo "label data"
#add a column with an ID for the type of SV to the end of each line
sed -i "s/$/\tINV/" $outputFileINV
sed -i "s/$/\tINS/" $outputFileINS
sed -i "s/$/\tDEL/" $outputFileDEL

echo "concatenate the files"
cat $outputFileINV $outputFileINS $outputFileDEL > $jointOutputFile

#the "#" character in the chromosome name causes problems in R - change this
sed -i "s/Morex_V3#1#//" $jointOutputFile

echo "workflow complete"


