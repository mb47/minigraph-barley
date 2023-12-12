#!/bin/bash

#script for comparing overlap between SVs called by Minigraph and Assemblytics

#SBATCH -o slurm-%x_%A.out   
#SBATCH -p short 

#the spatial overlap required between two SVs for being considered as equivalent - 70%
overlapFraction=0.7

datadirMinigraph=$1

inputFileAssemblytics=MorexV3_WBDC_184.Assemblytics_structural_variants.bed

accession=WBDC_184

outputFile="stats_MinigraphVsAssemblytics.txt"

#write a header for the output file
echo -e "chrom\tnumDelsMG\tnumDelsAS\tnumDelsIntersection\tnumInsMG\tnumInsAS\tnumInsIntersection" > $outputFile

echo "compare SVs from Minigraph and Assemblytics"
date

echo "using overlap fraction of $overlapFraction"

#iterate over all chromosomes
for i in {1..7}
do	
	chrom="chr"$i"H"
	echo -e "\nprocess chromosome $chrom"
	
	echo "extract deletions from Assemblytics"
	grep $chrom $inputFileAssemblytics | grep Deletion | cut -f 1-3 | sort -k1,1 -k2,2n > $chrom.$accession.Deletion.Assemblytics.sorted.bed

	echo "extract insertions from Assemblytics"
	grep $chrom $inputFileAssemblytics | grep Insertion | cut -f 1-3 | sort -k1,1 -k2,2n > $chrom.$accession.Insertion.Assemblytics.sorted.bed

	#this step creates an artificial set of insertion coordinates for the purpose of spatial and positional comparison
	#the resulting BED file contains 1) chrom, 2) start coordinate of the insertion in the reference and 3) end = start coordinate plus size of insertion in the sample
	#this allows us to compare both the position and size of the predicted insertion in one go
	echo "format insertions from Assemblytics for comparison"
	grep $chrom $inputFileAssemblytics | grep Insertion | cut -f 1,2,5 | sort -k1,1 -k2,2n | awk '{print $1"\t"$2"\t"$2+$3}' > $chrom.$accession.formatted.Insertion.Assemblytics.sorted.bed

	###########################################################
	
	inputFileMinigraph=$datadirMinigraph/$chrom/SVs.bubble.WBDC_184.1.bed
	
	echo "extract deletions from Minigraph"
	awk '$6==0 && $5==2 && $2<$3' $inputFileMinigraph | cut -f 1-3 | sed "s/Morex_V3#1#//" > $chrom.$accession.Deletion.Minigraph.sorted.bed

	echo "extract insertions from Minigraph"
	awk '$6==0 && $5==2 && $2==$3' $inputFileMinigraph | cut -f 1-3 | sed "s/Morex_V3#1#//" > $chrom.$accession.Insertion.Minigraph.sorted.bed

	#see above for explanation 
	echo "format insertions from Minigraph for comparison"
	awk '$6==0 && $5==2 && $2==$3' $inputFileMinigraph | cut -f 1,2,8 | sed "s/Morex_V3#1#//"  | awk '{print $1"\t"$2"\t"$2+$3}' > $chrom.$accession.formatted.Insertion.Minigraph.sorted.bed

	###########################################################

	echo -e "intersect deletions"

	bedtools intersect \
	-sorted \
	-wa \
	-f $overlapFraction \
	-r \
	-a $chrom.$accession.Deletion.Minigraph.sorted.bed \
	-b $chrom.$accession.Deletion.Assemblytics.sorted.bed \
	> $chrom.intersection.Deletions.bed

	###########################################################

	echo -e "intersect insertions"

	bedtools intersect \
	-sorted \
	-wa \
	-f $overlapFraction \
	-r \
	-a $chrom.$accession.formatted.Insertion.Minigraph.sorted.bed \
	-b $chrom.$accession.formatted.Insertion.Assemblytics.sorted.bed \
	> $chrom.intersection.Insertions.bed

	echo "extract numbers"
	numDelsMG=`wc -l $chrom.$accession.Deletion.Minigraph.sorted.bed | cut -f 1 -d " "`
	numDelsAS=`wc -l $chrom.$accession.Deletion.Assemblytics.sorted.bed | cut -f 1 -d " "`
	numDelsIntersection=`wc -l $chrom.intersection.Deletions.bed | cut -f 1 -d " "`

	numInsMG=`wc -l $chrom.$accession.Insertion.Minigraph.sorted.bed | cut -f 1 -d " "`
	numInsAS=`wc -l $chrom.$accession.Insertion.Assemblytics.sorted.bed | cut -f 1 -d " "`
	numInsIntersection=`wc -l $chrom.intersection.Insertions.bed | cut -f 1 -d " "`
	
	echo "output numbers to file"
	echo -e "$chrom\t$numDelsMG\t$numDelsAS\t$numDelsIntersection\t$numInsMG\t$numInsAS\t$numInsIntersection" >> $outputFile

done 

###########################################################

echo -e "\nworkflow complete"
date
